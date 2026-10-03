import datetime
from typing import Dict, List, Any

class SQLGenerator:
    def format_value(self, val: Any, col_meta: Dict[str, Any]) -> str:
        if val is None or str(val).strip() == "":
            return "NULL"
            
        dtype = col_meta.get("type", "varchar").lower()
        
        if "int" in dtype or "bigint" in dtype or "smallint" in dtype or "tinyint" in dtype:
            try:
                return str(int(val))
            except:
                return "0"
        elif "decimal" in dtype or "numeric" in dtype or "float" in dtype or "money" in dtype:
            try:
                return str(float(val))
            except:
                return "0.00"
        elif "bit" in dtype or "bool" in dtype:
            s = str(val).lower()
            if s in ['1', 'true', 'yes', 'y']:
                return "1"
            return "0"
        else:
            s_val = str(val).replace("'", "''")
            if "nvarchar" in dtype or "nchar" in dtype or "ntext" in dtype:
                return f"N'{s_val}'"
            return f"'{s_val}'"

    def generate_bulk_insert(
        self, 
        schema_table: str, 
        db_columns: List[Dict[str, Any]], 
        validated_rows: List[Dict[str, Any]], 
        batch_size: int = 100,
        enable_upsert: bool = False
    ) -> Dict[str, Any]:
        importable_rows = [r for r in validated_rows if r["status"] in ["VALID", "WARNING"]]
        
        if not importable_rows:
            return {
                "success": False,
                "error": "No valid rows available to generate SQL.",
                "sql": ""
            }
            
        col_lookup = {c["column"]: c for c in db_columns}
        sample_data = importable_rows[0]["data"]
        cols = [c for c in sample_data.keys() if c in col_lookup]
        
        if not cols:
            return {
                "success": False,
                "error": "No matching database columns detected for insert.",
                "sql": ""
            }

        # Check for Identity PK column
        clean_tbl_name = schema_table.split(".")[-1].replace("[", "").replace("]", "").replace("'", "").lower()
        has_identity_col = any(c.lower() in ["id", f"{clean_tbl_name}id", "studentid", "codeid"] or (c.lower().endswith("id") and clean_tbl_name in c.lower() or "student" in clean_tbl_name and "student" in c.lower()) for c in cols)
        col_names_joined = ", ".join([f"[{c}]" for c in cols])
        sql_batches = []

        identity_on = f"SET IDENTITY_INSERT {schema_table} ON;\n" if has_identity_col else ""
        identity_off = f"\nSET IDENTITY_INSERT {schema_table} OFF;" if has_identity_col else ""
        
        for i in range(0, len(importable_rows), batch_size):
            batch = importable_rows[i:i + batch_size]
            value_rows = []
            
            for row in batch:
                row_data = row["data"]
                val_strs = [self.format_value(row_data.get(c), col_lookup[c]) for c in cols]
                value_rows.append(f"  ({', '.join(val_strs)})")
                
            batch_sql = f"INSERT INTO {schema_table} ({col_names_joined})\nVALUES\n" + ",\n".join(value_rows) + ";"
            sql_batches.append(batch_sql)
            
        final_script = (
            f"-- ==========================================================\n"
            f"-- DK's SQL Buddy Auto-Generated Bulk Insert Script\n"
            f"-- Target Table: {schema_table}\n"
            f"-- Records: {len(importable_rows)} rows | Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
            f"-- ==========================================================\n\n"
            f"SET NOCOUNT ON;\n"
            f"BEGIN TRANSACTION;\n\n"
            f"{identity_on}"
            + "\n\n".join(sql_batches) +
            f"{identity_off}\n\n"
            f"COMMIT TRANSACTION;\n"
            f"-- Transaction Completed Successfully\n"
        )
        
        return {
            "success": True,
            "record_count": len(importable_rows),
            "target_table": schema_table,
            "has_identity_column": has_identity_col,
            "sql": final_script
        }

sql_generator = SQLGenerator()
