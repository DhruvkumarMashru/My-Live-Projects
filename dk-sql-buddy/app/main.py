from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from starlette.middleware.sessions import SessionMiddleware
import os

from app.config import settings
from app.api.router import router
from app.auth.user_store import seed_default_admin

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Enterprise AI SQL Database & Excel Master Management System"
)

# Session middleware (must be before CORS)
app.add_middleware(SessionMiddleware, secret_key=settings.SESSION_SECRET, max_age=86400 * 7)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static and Template mounts
static_dir = os.path.join(os.path.dirname(__file__), "static")
templates_dir = os.path.join(os.path.dirname(__file__), "templates")
avatars_dir = os.path.join(os.path.dirname(__file__), "static", "avatars")

os.makedirs(avatars_dir, exist_ok=True)

app.mount("/static", StaticFiles(directory=static_dir), name="static")
templates = Jinja2Templates(directory=templates_dir)

# Include API routes
app.include_router(router)

# Seed default admin user on startup
@app.on_event("startup")
async def startup_event():
    seed_default_admin()

@app.get("/")
def index(request: Request):
    from app.auth.auth_service import get_current_user
    user = get_current_user(request)
    if not user:
        return RedirectResponse(url="/login", status_code=302)
    return templates.TemplateResponse("index.html", {"request": request, "app_name": settings.APP_NAME})

@app.get("/login")
def login_page(request: Request):
    from app.auth.auth_service import get_current_user
    user = get_current_user(request)
    if user:
        return RedirectResponse(url="/", status_code=302)
    return templates.TemplateResponse("login.html", {"request": request, "app_name": settings.APP_NAME})
