"""
user_store.py — JSON-backed user database with CRUD operations.
File: app/users.json

Schema per user:
{
  "id": "uuid4",
  "username": "admin",
  "display_name": "Administrator",
  "email": "admin@dksqlbuddy.com",
  "password_hash": "<bcrypt>",
  "role": "admin",            # admin | manager | user
  "avatar": null,             # relative path like "avatars/uuid.jpg" or null
  "is_active": true,
  "must_change_password": false,
  "created_at": "ISO datetime"
}
"""
import json
import os
import uuid
from datetime import datetime
from typing import Optional, List

def _users_path() -> str:
    from app.config import settings
    return settings.USERS_PATH

def load_users() -> List[dict]:
    path = _users_path()
    if not os.path.exists(path):
        return []
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return []

def save_users(users: List[dict]) -> None:
    path = _users_path()
    with open(path, "w", encoding="utf-8") as f:
        json.dump(users, f, indent=2, ensure_ascii=False)

def seed_default_admin() -> None:
    """Create default admin on first run if no users exist."""
    users = load_users()
    if not users:
        from app.auth.auth_service import hash_password
        admin = {
            "id": str(uuid.uuid4()),
            "username": "admin",
            "display_name": "Administrator",
            "email": "admin@dksqlbuddy.com",
            "password_hash": hash_password("Admin@123"),
            "role": "admin",
            "avatar": None,
            "is_active": True,
            "must_change_password": True,
            "created_at": datetime.utcnow().isoformat()
        }
        save_users([admin])

def get_user_by_username(username: str) -> Optional[dict]:
    return next((u for u in load_users() if u["username"].lower() == username.lower()), None)

def get_user_by_id(user_id: str) -> Optional[dict]:
    return next((u for u in load_users() if u["id"] == user_id), None)

def create_user(username: str, display_name: str, email: str,
                password: str, role: str = "user") -> dict:
    from app.auth.auth_service import hash_password
    users = load_users()
    if any(u["username"].lower() == username.lower() for u in users):
        raise ValueError(f"Username '{username}' already exists")
    user = {
        "id": str(uuid.uuid4()),
        "username": username,
        "display_name": display_name,
        "email": email,
        "password_hash": hash_password(password),
        "role": role,
        "avatar": None,
        "is_active": True,
        "must_change_password": False,
        "created_at": datetime.utcnow().isoformat()
    }
    users.append(user)
    save_users(users)
    return user

def update_user(user_id: str, **kwargs) -> Optional[dict]:
    users = load_users()
    for u in users:
        if u["id"] == user_id:
            for k, v in kwargs.items():
                if k in u:
                    u[k] = v
            save_users(users)
            return u
    return None

def delete_user(user_id: str) -> bool:
    users = load_users()
    new_users = [u for u in users if u["id"] != user_id]
    if len(new_users) == len(users):
        return False
    save_users(new_users)
    return True

def safe_user(user: dict) -> dict:
    """Return user dict without password hash (safe to send to frontend)."""
    return {k: v for k, v in user.items() if k != "password_hash"}
