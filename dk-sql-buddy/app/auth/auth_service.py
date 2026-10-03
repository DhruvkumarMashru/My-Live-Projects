"""
auth_service.py — Password hashing, session management, request user extraction
"""
import bcrypt
from itsdangerous import URLSafeTimedSerializer, BadSignature, SignatureExpired
from fastapi import Request
from typing import Optional

# Import settings lazily to avoid circular imports
def _get_secret():
    from app.config import settings
    return settings.SESSION_SECRET

def hash_password(plain: str) -> str:
    """Return bcrypt hash of a plain-text password."""
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

def verify_password(plain: str, hashed: str) -> bool:
    """Verify plain password against bcrypt hash."""
    try:
        return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
    except Exception:
        return False

def create_session_token(user_id: str) -> str:
    """Create a signed, timed session token for a user ID."""
    s = URLSafeTimedSerializer(_get_secret())
    return s.dumps(user_id, salt="session")

def decode_session_token(token: str, max_age: int = 86400 * 7) -> Optional[str]:
    """Decode session token; returns user_id or None if invalid/expired."""
    s = URLSafeTimedSerializer(_get_secret())
    try:
        return s.loads(token, salt="session", max_age=max_age)
    except (BadSignature, SignatureExpired):
        return None

def get_current_user(request: Request) -> Optional[dict]:
    """Extract and return the logged-in user dict from the session cookie."""
    from app.auth.user_store import get_user_by_id
    token = request.cookies.get("dksb_session")
    if not token:
        return None
    user_id = decode_session_token(token)
    if not user_id:
        return None
    return get_user_by_id(user_id)

def require_auth(request: Request) -> dict:
    """FastAPI dependency — raises 401 if not logged in."""
    from fastapi import HTTPException
    user = get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return user

def require_admin(request: Request) -> dict:
    """FastAPI dependency — raises 403 if not admin."""
    from fastapi import HTTPException
    user = require_auth(request)
    if user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return user
