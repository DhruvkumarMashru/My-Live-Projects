import re
import datetime
from typing import Dict, List, Any, Tuple
from app.services.metadata_service import SYNONYM_DICT

class ValidationService:
    def _clean_token(self, text: str) -> str:
        s = re.sub(r'[^a-zA-Z0-9]', '', str(text)).lower()
        return SYNONYM_DICT.get(s, s)

    def _calculate_similarity(self, ex_header: str, db_col_name: str) -> int:
        clean_ex = self._clean_token(ex_header)
        clean_db = self._clean_token(db_col_name)

        if clean_ex == clean_db:
            return 100
        if clean_ex in clean_db or clean_db in clean_ex:
            return 88

        # Token set match
        ex_tokens = [self._clean_token(t) for t in re.findall(r'[A-Z][a-z0-9]*|[a-z0-9]+', ex_header)]
        db_tokens = [self._clean_token(t) for t in re.findall(r'[A-Z][a-z0-9]*|[a-z0-9]+', db_col_name)]

        common = set(ex_tokens).intersection(set(db_tokens))
        if common:
            return min(85, int(len(common) / max(len(ex_tokens), len(db_tokens)) * 100))

        return 0

    def map_columns(self, excel_headers: List[str], db_columns: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        mappings = []
        db_col_names = {c["column"]: c for c in db_columns}
        
        for ex_header in excel_headers:
            best_match = None
            best_score = 0
            
            for col_name, col_info in db_col_names.items():
                score = self._calculate_similarity(ex_header, col_name)
                if score > best_score:
                    best_score = score
                    best_match = col_name
                        
            status = "MATCHED" if best_score >= 80 else ("WARNING" if best_score >= 60 else "UNMATCHED")
            mappings.append({
                "excel_column": ex_header,
                "db_column": best_match,
                "confidence": best_score,
                "status": status
            })
            
        return mappings

    def _parse_date_string(self, val_str: str) -> Tuple[bool, str]:
        s = val_str.strip()
        # ISO YYYY-MM-DD
        if re.match(r'^\d{4}-\d{2}-\d{2}(?:\s+\d{2}:\d{2}:\d{2})?$', s):
            return True, s
        # Indian DD/MM/YYYY or DD-MM-YYYY
        m_ind = re.match(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$', s)
        if m_ind:
            d, m, y = m_ind.groups()
            return True, f"{y}-{int(m):02d}-{int(d):02d}"
        # US MM/DD/YYYY
        m_us = re.match(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$', s)
        if m_us:
            m, d, y = m_us.groups()
            if len(y) == 2: y = "20" + y
            return True, f"{y}-{int(m):02d}-{int(d):02d}"
        return False, s

    def validate_rows(self, rows: List[Dict[str, Any]], column_mappings: List[Dict[str, Any]], db_columns: List[Dict[str, Any]]) -> Dict[str, Any]:
        col_meta = {c["column"]: c for c in db_columns}
        active_mapping = {m["excel_column"]: m["db_column"] for m in column_mappings if m.get("db_column")}
        
        validated_rows = []
        valid_count = 0
        warning_count = 0
        error_count = 0
        
        seen_keys = set()
        
        for idx, row in enumerate(rows, start=1):
            row_errors = []
            row_warnings = []
            mapped_record = {}
            
            for ex_col, val in row.items():
                db_col = active_mapping.get(ex_col)
                if not db_col or db_col not in col_meta:
                    continue
                    
                meta = col_meta[db_col]
                dtype = meta.get("type", "varchar").lower()
                nullable = meta.get("nullable", "YES") == "YES"
                max_len = meta.get("length")
                
                if (val is None or str(val).strip() == "") and not nullable:
                    row_errors.append(f"Field '{ex_col}' (maps to {db_col}) is mandatory and cannot be empty.")
                    mapped_record[db_col] = None
                    continue
                    
                if val is not None and str(val).strip() != "":
                    s_val = str(val).strip()
                    if max_len and max_len > 0 and len(s_val) > max_len and "text" not in dtype:
                        row_warnings.append(f"Field '{ex_col}' length ({len(s_val)}) exceeds DB limit ({max_len}). Will be truncated.")
                        s_val = s_val[:max_len]
                        
                    if "int" in dtype or "bigint" in dtype or "smallint" in dtype or "tinyint" in dtype:
                        try:
                            mapped_record[db_col] = int(float(s_val))
                        except ValueError:
                            row_errors.append(f"Field '{ex_col}' must be a valid integer, got '{s_val}'.")
                    elif "decimal" in dtype or "numeric" in dtype or "float" in dtype or "money" in dtype:
                        try:
                            mapped_record[db_col] = float(s_val)
                        except ValueError:
                            row_errors.append(f"Field '{ex_col}' must be a valid decimal number, got '{s_val}'.")
                    elif "date" in dtype or "time" in dtype:
                        is_valid_dt, parsed_dt = self._parse_date_string(s_val)
                        if not is_valid_dt:
                            row_warnings.append(f"Field '{ex_col}' date format unverified ('{s_val}').")
                        mapped_record[db_col] = parsed_dt
                    else:
                        mapped_record[db_col] = s_val
                else:
                    mapped_record[db_col] = None
                    
            key_val = str(mapped_record.get("SupplierCode") or mapped_record.get("Code") or mapped_record.get("ID") or mapped_record.get("StudentId") or "")
            if key_val and key_val in seen_keys:
                row_warnings.append(f"Duplicate entry detected in file for key '{key_val}'.")
            elif key_val:
                seen_keys.add(key_val)
                
            status = "VALID"
            if row_errors:
                status = "ERROR"
                error_count += 1
            elif row_warnings:
                status = "WARNING"
                warning_count += 1
            else:
                valid_count += 1
                
            validated_rows.append({
                "row_number": idx,
                "status": status,
                "data": mapped_record,
                "original": row,
                "errors": row_errors,
                "warnings": row_warnings
            })
            
        return {
            "total_rows": len(rows),
            "valid_count": valid_count,
            "warning_count": warning_count,
            "error_count": error_count,
            "rows": validated_rows
        }

validation_service = ValidationService()
