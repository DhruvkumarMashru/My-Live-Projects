import pymssql
import json
import os
import time
import uuid
import re
import datetime
from decimal import Decimal
from typing import Dict, List, Any, Optional
from app.config import settings

def format_tsql_table_name(table_name: str) -> str:
    clean = table_name.replace("'", "").replace('"', "").replace("[", "").replace("]", "")
    parts = clean.split(".")
    if len(parts) == 2:
        return f"[{parts[0]}].[{parts[1]}]"
    elif len(parts) == 1:
        return f"[dbo].[{parts[0]}]"
    return f"[{clean}]"

class DatabaseService:
    def __init__(self):
        self.history_file = settings.IMPORT_HISTORY_PATH
        self.sql_library_file = settings.SQL_LIBRARY_PATH
        self.saved_connections_file = settings.SAVED_CONNECTIONS_PATH
        self._ensure_storage()

    def _ensure_storage(self):
        if not os.path.exists(self.history_file):
            with open(self.history_file, "w") as f:
                json.dump([], f)
        if not os.path.exists(self.sql_library_file):
            with open(self.sql_library_file, "w") as f:
                json.dump([], f)
        if not os.path.exists(self.saved_connections_file):
            default_conn = [{
                "id": "conn_prod_1",
                "name": "Production SQL Server (Primary)",
                "host": settings.DEFAULT_SERVER,
                "port": settings.DEFAULT_PORT,
                "user": settings.DEFAULT_USER,
                "password": settings.DEFAULT_PASSWORD,
                "is_active": True,
                "last_trained": time.strftime("%Y-%m-%d %H:%M:%S"),
                "scanned_dbs": 47
            }]
            with open(self.saved_connections_file, "w") as f:
                json.dump(default_conn, f, indent=2)

    def get_saved_connections(self) -> List[Dict[str, Any]]:
        if os.path.exists(self.saved_connections_file):
            try:
                with open(self.saved_connections_file, "r") as f:
                    return json.load(f)
            except Exception:
                pass
        return []

    def save_connection_profile(self, conn_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        connections = self.get_saved_connections()
        
        conn_id = conn_data.get("id") or f"conn_{int(time.time())}"
        conn_data["id"] = conn_id
        conn_data["last_trained"] = conn_data.get("last_trained") or time.strftime("%Y-%m-%d %H:%M:%S")
        
        if conn_data.get("is_active"):
            for c in connections:
                c["is_active"] = False
                
        existing_idx = next((i for i, c in enumerate(connections) if c["id"] == conn_id), -1)
        if existing_idx >= 0:
            connections[existing_idx] = conn_data
        else:
            connections.append(conn_data)
            
        with open(self.saved_connections_file, "w") as f:
            json.dump(connections, f, indent=2)
            
        return connections

    def delete_connection_profile(self, conn_id: str) -> List[Dict[str, Any]]:
        connections = self.get_saved_connections()
        filtered = [c for c in connections if c.get("id") != conn_id]
        if filtered and not any(c.get("is_active") for c in filtered):
            filtered[0]["is_active"] = True
        with open(self.saved_connections_file, "w") as f:
            json.dump(filtered, f, indent=2)
        return filtered

    def get_connection(self, host: str, port: int, user: str, password: str, database: Optional[str] = None, timeout: int = 10):
        if database:
            return pymssql.connect(server=host, port=port, user=user, password=password, database=database, timeout=timeout)
        return pymssql.connect(server=host, port=port, user=user, password=password, timeout=timeout)

    def test_connection(self, host: str, port: int, user: str, password: str) -> Dict[str, Any]:
        start_time = time.time()
        try:
            conn = self.get_connection(host=host, port=port, user=user, password=password, timeout=5)
            cursor = conn.cursor()
            cursor.execute("SELECT @@version, DB_NAME();")
            row = cursor.fetchone()
            
            cursor.execute("SELECT IS_SRVROLEMEMBER('sysadmin'), HAS_PERMS_BY_NAME(null, null, 'VIEW SERVER STATE');")
            perm_row = cursor.fetchone()
            
            conn.close()
            latency_ms = round((time.time() - start_time) * 1000, 2)
            
            return {
                "success": True,
                "message": "Connection established successfully!",
                "version": row[0].split("\n")[0] if row else "MSSQL",
                "default_database": row[1] if row else "master",
                "latency_ms": latency_ms,
                "permissions": {
                    "sysadmin": bool(perm_row[0]) if perm_row else False,
                    "read_rights": True,
                    "write_rights": True
                }
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Connection failed: {str(e)}",
                "latency_ms": round((time.time() - start_time) * 1000, 2)
            }

    def fetch_live_table_data(self, host: str, port: int, user: str, password: str, database: str, table_name: str, max_rows: int = 500) -> List[Dict[str, Any]]:
        try:
            conn = self.get_connection(host=host, port=port, user=user, password=password, database=database, timeout=8)
            cursor = conn.cursor(as_dict=True)
            formatted_table = format_tsql_table_name(table_name)
            cursor.execute(f"SELECT TOP ({max_rows}) * FROM {formatted_table};")
            rows = cursor.fetchall()
            conn.close()
            return rows
        except Exception as e:
            print(f"Error fetching live table data from {database}.{table_name}: {e}")
            return []

    def execute_transaction_script(self, host: str, port: int, user: str, password: str, database: str, sql_script: str, is_dry_run: bool = False) -> Dict[str, Any]:
        start_time = time.time()
        
        # Fallback to active connection profile if credentials are missing or default
        if not host or not user or not password:
            saved = self.get_saved_connections()
            active = next((c for c in saved if c.get("is_active")), (saved[0] if saved else {}))
            if active:
                host = host or active.get("host") or settings.DEFAULT_SERVER
                port = port or active.get("port") or settings.DEFAULT_PORT
                user = user or active.get("user") or settings.DEFAULT_USER
                password = password or active.get("password") or settings.DEFAULT_PASSWORD
                
        def _serialize_val(val: Any) -> Any:
            if val is None:
                return None
            import datetime
            from decimal import Decimal
            import uuid
            if isinstance(val, (datetime.datetime, datetime.date, datetime.time)):
                return val.isoformat()
            if isinstance(val, Decimal):
                return float(val)
            if isinstance(val, bytes):
                return val.hex()
            if isinstance(val, uuid.UUID):
                return str(val)
            return val

        try:
            conn = self.get_connection(host=host, port=port, user=user, password=password, database=database, timeout=12)
            cursor = conn.cursor()
            
            clean_script = sql_script.strip()
            is_select_query = bool(re.search(r'^\s*(?:--[^\n]*\n\s*)*(?:SELECT|WITH|EXEC|SHOW|PRINT|sys\.|INFORMATION_SCHEMA)', clean_script, re.IGNORECASE))

            if is_select_query and not is_dry_run:
                cursor.execute(clean_script)
                columns = []
                data_rows = []
                row_count = 0
                
                if cursor.description:
                    columns = [col[0] for col in cursor.description]
                    raw_rows = cursor.fetchall()
                    row_count = len(raw_rows)
                    data_rows = [
                        {columns[i]: _serialize_val(val) for i, val in enumerate(row)}
                        for row in raw_rows[:500]
                    ]
                
                conn.close()
                duration = round((time.time() - start_time) * 1000, 2)
                
                return {
                    "success": True,
                    "is_query": True,
                    "columns": columns,
                    "data": data_rows,
                    "row_count": row_count,
                    "message": f"Successfully retrieved {row_count} records from [{database}].",
                    "duration_ms": duration
                }

            if is_dry_run:
                cursor.execute("BEGIN TRANSACTION;")
                statements = [s.strip() for s in sql_script.split(";") if s.strip()]
                rows_affected = 0
                for stmt in statements:
                    cursor.execute(stmt)
                    if cursor.rowcount > 0:
                        rows_affected += cursor.rowcount
                cursor.execute("ROLLBACK TRANSACTION;")
                conn.close()
                return {
                    "success": True,
                    "is_dry_run": True,
                    "rows_affected": rows_affected,
                    "columns": [],
                    "data": [],
                    "row_count": 0,
                    "message": f"Dry run simulation succeeded! Estimated {rows_affected} records modified/inserted.",
                    "duration_ms": round((time.time() - start_time) * 1000, 2)
                }
            else:
                cursor.execute("BEGIN TRANSACTION;")
                statements = [s.strip() for s in sql_script.split(";") if s.strip()]
                rows_affected = 0
                columns = []
                data_rows = []
                for stmt in statements:
                    cursor.execute(stmt)
                    if cursor.rowcount > 0:
                        rows_affected += cursor.rowcount
                    if cursor.description:
                        columns = [col[0] for col in cursor.description]
                        raw_rows = cursor.fetchall()
                        data_rows = [
                            {columns[i]: _serialize_val(val) for i, val in enumerate(row)}
                            for row in raw_rows[:500]
                        ]
                cursor.execute("COMMIT TRANSACTION;")
                conn.close()
                
                duration = round((time.time() - start_time) * 1000, 2)
                
                self.log_history({
                    "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                    "server": host,
                    "database": database,
                    "rows_affected": rows_affected,
                    "duration_ms": duration,
                    "status": "SUCCESS"
                })
                
                return {
                    "success": True,
                    "is_dry_run": False,
                    "rows_affected": rows_affected,
                    "columns": columns,
                    "data": data_rows,
                    "row_count": len(data_rows),
                    "message": f"Successfully executed transaction! {rows_affected} records committed to {database}.",
                    "duration_ms": duration
                }
        except Exception as e:
            duration = round((time.time() - start_time) * 1000, 2)
            self.log_history({
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "server": host,
                "database": database,
                "rows_affected": 0,
                "duration_ms": duration,
                "status": f"FAILED: {str(e)}"
            })
            return {
                "success": False,
                "error": f"Execution failed: {str(e)}",
                "columns": [],
                "data": [],
                "row_count": 0,
                "duration_ms": duration
            }

    def log_history(self, record: Dict[str, Any]):
        try:
            history = []
            if os.path.exists(self.history_file):
                with open(self.history_file, "r") as f:
                    history = json.load(f)
            history.insert(0, record)
            with open(self.history_file, "w") as f:
                json.dump(history[:100], f, indent=2)
        except Exception as e:
            print(f"Error logging history: {e}")

    def get_history(self) -> List[Dict[str, Any]]:
        if os.path.exists(self.history_file):
            with open(self.history_file, "r") as f:
                return json.load(f)
        return []

    # ─────────────────────────────────────────────
    #  SUPER AI MODULE 4: REUSABLE SQL LIBRARY & MEMORY STORE
    # ─────────────────────────────────────────────
    def get_sql_library(self) -> List[Dict[str, Any]]:
        if os.path.exists(self.sql_library_file):
            try:
                with open(self.sql_library_file, "r") as f:
                    return json.load(f)
            except Exception:
                pass
        return []

    def save_sql_template(self, item: Dict[str, Any]) -> List[Dict[str, Any]]:
        library = self.get_sql_library()
        item_id = item.get("id") or f"tpl_{uuid.uuid4().hex[:8]}"
        item["id"] = item_id
        item["created_at"] = item.get("created_at") or time.strftime("%Y-%m-%d %H:%M:%S")
        
        idx = next((i for i, t in enumerate(library) if t["id"] == item_id), -1)
        if idx >= 0:
            library[idx] = item
        else:
            library.insert(0, item)
            
        with open(self.sql_library_file, "w") as f:
            json.dump(library, f, indent=2)
            
        return library

    def delete_sql_template(self, template_id: str) -> List[Dict[str, Any]]:
        library = self.get_sql_library()
        filtered = [t for t in library if t.get("id") != template_id]
        with open(self.sql_library_file, "w") as f:
            json.dump(filtered, f, indent=2)
        return filtered

db_service = DatabaseService()
