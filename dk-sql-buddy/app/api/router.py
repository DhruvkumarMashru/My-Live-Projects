from fastapi import APIRouter, File, UploadFile, Form, HTTPException, Response, Request, Depends
from pydantic import BaseModel
from typing import Dict, List, Any, Optional
import json, os, uuid, shutil
from datetime import datetime

from app.config import settings
from app.services.metadata_service import metadata_service
from app.services.db_service import db_service
from app.services.excel_service import excel_service
from app.services.validation_service import validation_service
from app.services.sql_generator import sql_generator
from app.auth.auth_service import (
    verify_password, create_session_token, get_current_user,
    require_auth, require_admin, hash_password
)
from app.auth.user_store import (
    load_users, get_user_by_username, get_user_by_id,
    create_user, update_user, delete_user, safe_user, seed_default_admin
)

router = APIRouter(prefix="/api")

# ─────────────────────────────────────────────
#  AUTH ENDPOINTS
# ─────────────────────────────────────────────

class LoginRequest(BaseModel):
    username: str
    password: str

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

class CreateUserRequest(BaseModel):
    username: str
    display_name: str
    email: str
    password: str
    role: str = "user"

class UpdateUserRequest(BaseModel):
    display_name: Optional[str] = None
    email: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None

@router.post("/auth/login")
def login(body: LoginRequest, response: Response):
    user = get_user_by_username(body.username)
    if not user or not verify_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid username or password")
    if not user.get("is_active", True):
        raise HTTPException(status_code=403, detail="Account is disabled")
    token = create_session_token(user["id"])
    response.set_cookie(
        key="dksb_session", value=token,
        httponly=True, max_age=86400 * 7, samesite="lax"
    )
    return {"success": True, "user": safe_user(user)}

@router.post("/auth/logout")
def logout(response: Response):
    response.delete_cookie("dksb_session")
    return {"success": True}

@router.get("/auth/me")
def me(request: Request):
    user = get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return safe_user(user)

@router.put("/auth/change-password")
def change_password(body: ChangePasswordRequest, request: Request):
    user = get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    if not verify_password(body.old_password, user["password_hash"]):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    if len(body.new_password) < 6:
        raise HTTPException(status_code=400, detail="New password must be at least 6 characters")
    update_user(user["id"], password_hash=hash_password(body.new_password), must_change_password=False)
    return {"success": True, "message": "Password changed successfully"}

@router.put("/auth/update-profile")
def update_profile(request: Request, display_name: str = Form(...), email: str = Form(...)):
    user = get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    updated = update_user(user["id"], display_name=display_name, email=email)
    return {"success": True, "user": safe_user(updated)}

@router.post("/auth/upload-avatar")
async def upload_avatar(request: Request, file: UploadFile = File(...)):
    user = get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    if file.content_type not in ["image/jpeg", "image/png", "image/gif", "image/webp"]:
        raise HTTPException(status_code=400, detail="Only JPEG, PNG, GIF, or WebP images allowed")
    if user.get("avatar"):
        old_path = os.path.join(os.path.dirname(settings.USERS_PATH), "static", user["avatar"])
        if os.path.exists(old_path):
            os.remove(old_path)
    ext = file.filename.split(".")[-1].lower()
    filename = f"{uuid.uuid4()}.{ext}"
    save_path = os.path.join(settings.AVATARS_PATH, filename)
    with open(save_path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    avatar_rel = f"avatars/{filename}"
    updated = update_user(user["id"], avatar=avatar_rel)
    return {"success": True, "avatar_url": f"/static/{avatar_rel}", "user": safe_user(updated)}

@router.delete("/auth/delete-avatar")
def delete_avatar(request: Request):
    user = get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    if user.get("avatar"):
        old_path = os.path.join(os.path.dirname(settings.USERS_PATH), "static", user["avatar"])
        if os.path.exists(old_path):
            os.remove(old_path)
    update_user(user["id"], avatar=None)
    return {"success": True}

# ─────────────────────────────────────────────
#  USER MANAGEMENT (Admin Only)
# ─────────────────────────────────────────────

@router.get("/users")
def list_users(request: Request):
    require_admin(request)
    return [safe_user(u) for u in load_users()]

@router.post("/users")
def create_new_user(body: CreateUserRequest, request: Request):
    require_admin(request)
    if body.role not in ["admin", "manager", "user"]:
        raise HTTPException(status_code=400, detail="Role must be admin, manager, or user")
    try:
        user = create_user(body.username, body.display_name, body.email, body.password, body.role)
        return {"success": True, "user": safe_user(user)}
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))

@router.put("/users/{user_id}")
def edit_user(user_id: str, body: UpdateUserRequest, request: Request):
    require_admin(request)
    kwargs = {k: v for k, v in body.dict().items() if v is not None}
    if "role" in kwargs and kwargs["role"] not in ["admin", "manager", "user"]:
        raise HTTPException(status_code=400, detail="Invalid role")
    updated = update_user(user_id, **kwargs)
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    return {"success": True, "user": safe_user(updated)}

@router.delete("/users/{user_id}")
def remove_user(user_id: str, request: Request):
    current = get_current_user(request)
    require_admin(request)
    if current and current["id"] == user_id:
        raise HTTPException(status_code=400, detail="Cannot delete your own account")
    if not delete_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    return {"success": True}

@router.put("/users/{user_id}/reset-password")
def admin_reset_password(user_id: str, request: Request, new_password: str = Form(...)):
    require_admin(request)
    if len(new_password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")
    updated = update_user(user_id, password_hash=hash_password(new_password), must_change_password=True)
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    return {"success": True, "message": "Password reset. User must change on next login."}

# Models
class ConnectionRequest(BaseModel):
    name: Optional[str] = "Default Connection"
    host: str = settings.DEFAULT_SERVER
    port: int = settings.DEFAULT_PORT
    user: str = settings.DEFAULT_USER
    password: str = settings.DEFAULT_PASSWORD
    use_cache: bool = True
    train_schema: bool = False

class AISearchRequest(BaseModel):
    prompt: str
    db_name: Optional[str] = None

class OptimizeRequest(BaseModel):
    sql_script: str
    db_name: Optional[str] = None

class RescanRequest(BaseModel):
    force_refresh: bool = True
    db_name: Optional[str] = None

class ValidateRequest(BaseModel):
    excel_headers: List[str]
    column_mappings: List[Dict[str, Any]]
    rows: List[Dict[str, Any]]
    db_name: str
    table_name: str

class ExecuteRequest(BaseModel):
    host: str = settings.DEFAULT_SERVER
    port: int = settings.DEFAULT_PORT
    user: str = settings.DEFAULT_USER
    password: str = settings.DEFAULT_PASSWORD
    database: str
    sql_script: str
    is_dry_run: bool = False

class LibraryItemRequest(BaseModel):
    title: str
    description: Optional[str] = ""
    database: str
    sql_script: str
    category: Optional[str] = "General"

# Endpoints
@router.post("/connect/test")
def test_connection(req: ConnectionRequest):
    result = db_service.test_connection(
        host=req.host,
        port=req.port,
        user=req.user,
        password=req.password
    )
    return result

@router.get("/connect/saved")
def get_saved_connections():
    return db_service.get_saved_connections()

@router.post("/connect/save")
def save_connection(profile: Dict[str, Any]):
    return db_service.save_connection_profile(profile)

@router.delete("/connect/saved/{conn_id}")
def delete_connection(conn_id: str):
    return db_service.delete_connection_profile(conn_id)

@router.get("/metadata/summary")
def get_metadata_summary():
    return metadata_service.get_summary()

@router.post("/metadata/rescan")
def rescan_metadata(req: Optional[RescanRequest] = None):
    force_refresh = req.force_refresh if req else True
    target_db = req.db_name if req else None
    return metadata_service.trigger_rescan_and_train(force_refresh=force_refresh, target_db=target_db)

@router.get("/metadata/scan-progress")
def get_scan_progress():
    return metadata_service.get_scan_progress()

@router.get("/metadata/databases")
def get_databases():
    return list(metadata_service.metadata.keys())

@router.get("/metadata/tables/{db_name}")
def get_tables(db_name: str):
    if db_name in metadata_service.metadata:
        tables = metadata_service.metadata[db_name].get("tables", {})
        res = []
        for tbl_full, cols in tables.items():
            res.append({
                "table_full": tbl_full,
                "table_name": tbl_full.split(".")[-1],
                "schema": tbl_full.split(".")[0] if "." in tbl_full else "dbo",
                "column_count": len(cols)
            })
        return res
    return []

@router.get("/metadata/table-details")
def get_table_details(db_name: str, table_name: str):
    details = metadata_service.get_table_details(db_name, table_name)
    if not details:
        raise HTTPException(status_code=404, detail="Table structure not found.")
    return details

@router.post("/ai/suggest-tables")
def ai_suggest_tables(req: AISearchRequest):
    suggestions = metadata_service.ai_suggest_tables(req.prompt, req.db_name)
    return {
        "query": req.prompt,
        "database": req.db_name,
        "suggestions": suggestions
    }

class ChatRequest(BaseModel):
    prompt: str
    db_name: Optional[str] = None
    history: Optional[List[Dict[str, Any]]] = None

class PastedJoinRequest(BaseModel):
    pasted_sql: str
    db_name: Optional[str] = None

@router.post("/ai/chat")
def ai_chat(req: ChatRequest):
    return metadata_service.ai_chat_copilot(req.prompt, req.db_name, req.history)

@router.post("/ai/join-pasted-queries")
def join_pasted_queries(req: PastedJoinRequest):
    return metadata_service.join_pasted_queries(req.pasted_sql, req.db_name)

# ─────────────────────────────────────────────
#  SUPER AI ENDPOINTS
# ─────────────────────────────────────────────

@router.post("/ai/query-studio")
def ai_query_studio(req: AISearchRequest):
    return metadata_service.ai_build_aggregation_query(req.prompt, req.db_name)

@router.get("/ai/data-health")
def ai_data_health(db_name: str, table_name: str):
    res = metadata_service.audit_table_data_health(db_name, table_name)
    if not res.get("success"):
        raise HTTPException(status_code=404, detail=res.get("error", "Table not found"))
    return res

@router.post("/ai/optimize-query")
def ai_optimize_query(req: OptimizeRequest):
    return metadata_service.analyze_query_performance_and_indexes(req.sql_script, req.db_name)

@router.get("/library")
def get_sql_library():
    return db_service.get_sql_library()

@router.post("/library")
def save_sql_library_item(item: LibraryItemRequest):
    return db_service.save_sql_template(item.dict())

@router.delete("/library/{item_id}")
def delete_sql_library_item(item_id: str):
    return db_service.delete_sql_template(item_id)

@router.post("/excel/template")
def download_excel_template(db_name: str = Form(...), table_name: str = Form(...)):
    details = metadata_service.get_table_details(db_name, table_name)
    if not details:
        raise HTTPException(status_code=404, detail="Table metadata not found.")
        
    excel_bytes = excel_service.create_template(table_name, details["columns"])
    clean_filename = f"{db_name}_{table_name.replace('.', '_')}_Template.xlsx"
    
    return Response(
        content=excel_bytes,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={clean_filename}"}
    )

@router.post("/excel/preview-data")
def preview_table_data(
    db_name: str = Form(...),
    table_name: str = Form(...),
    host: str = Form(settings.DEFAULT_SERVER),
    port: int = Form(settings.DEFAULT_PORT),
    user: str = Form(settings.DEFAULT_USER),
    password: str = Form(settings.DEFAULT_PASSWORD)
):
    details = metadata_service.get_table_details(db_name, table_name)
    if not details:
        raise HTTPException(status_code=404, detail="Table metadata not found.")
        
    live_rows = db_service.fetch_live_table_data(host, port, user, password, db_name, table_name, max_rows=100)
    col_names = [c["column"] for c in details["columns"]]

    if not live_rows:
        sample_row_1 = {}
        sample_row_2 = {}
        for idx, col_obj in enumerate(details["columns"]):
            cname = col_obj["column"]
            ctype = col_obj["type"].lower()
            if "int" in ctype or "numeric" in ctype or "decimal" in ctype:
                sample_row_1[cname] = 1001 + idx
                sample_row_2[cname] = 1002 + idx
            elif "date" in ctype or "time" in ctype:
                sample_row_1[cname] = "2026-08-01"
                sample_row_2[cname] = "2026-08-10"
            else:
                sample_row_1[cname] = f"Sample_{cname}_A"
                sample_row_2[cname] = f"Sample_{cname}_B"
        live_rows = [sample_row_1, sample_row_2]
    
    return {
        "success": True,
        "database": db_name,
        "table": table_name,
        "columns": col_names,
        "row_count": len(live_rows),
        "data": live_rows
    }

@router.post("/excel/export-data")
def export_table_data(
    db_name: str = Form(...),
    table_name: str = Form(...),
    host: str = Form(settings.DEFAULT_SERVER),
    port: int = Form(settings.DEFAULT_PORT),
    user: str = Form(settings.DEFAULT_USER),
    password: str = Form(settings.DEFAULT_PASSWORD)
):
    details = metadata_service.get_table_details(db_name, table_name)
    if not details:
        raise HTTPException(status_code=404, detail="Table metadata not found.")
        
    live_rows = db_service.fetch_live_table_data(host, port, user, password, db_name, table_name)
    excel_bytes = excel_service.export_table_data(table_name, details["columns"], live_rows)
    clean_filename = f"{db_name}_{table_name.replace('.', '_')}_Data_Export.xlsx"
    
    return Response(
        content=excel_bytes,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={clean_filename}"}
    )

@router.post("/excel/upload")
async def upload_excel(file: UploadFile = File(...), db_name: str = Form(...), table_name: str = Form(...)):
    contents = await file.read()
    details = metadata_service.get_table_details(db_name, table_name)
    if not details:
        raise HTTPException(status_code=404, detail="Table structure not found.")
        
    try:
        rows = excel_service.parse_excel(contents)
        if not rows:
            return {"success": False, "error": "Excel file is empty or contains no data rows."}
            
        excel_headers = list(rows[0].keys())
        mappings = validation_service.map_columns(excel_headers, details["columns"])
        val_result = validation_service.validate_rows(rows, mappings, details["columns"])
        
        return {
            "success": True,
            "filename": file.filename,
            "total_rows": len(rows),
            "excel_headers": excel_headers,
            "column_mappings": mappings,
            "validation": val_result
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

@router.post("/sql/generate")
def generate_sql(req: ValidateRequest):
    details = metadata_service.get_table_details(req.db_name, req.table_name)
    if not details:
        raise HTTPException(status_code=404, detail="Target table details not found.")
        
    val_result = validation_service.validate_rows(req.rows, req.column_mappings, details["columns"])
    sql_result = sql_generator.generate_bulk_insert(req.table_name, details["columns"], val_result["rows"])
    
    return {
        "validation": val_result,
        "sql_result": sql_result
    }

@router.post("/sql/execute")
def execute_sql(req: ExecuteRequest):
    res = db_service.execute_transaction_script(
        host=req.host,
        port=req.port,
        user=req.user,
        password=req.password,
        database=req.database,
        sql_script=req.sql_script,
        is_dry_run=req.is_dry_run
    )
    return res

@router.get("/history")
def get_import_history():
    return db_service.get_history()
