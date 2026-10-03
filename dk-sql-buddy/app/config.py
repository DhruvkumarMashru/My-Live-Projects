import os
import secrets

class Settings:
    APP_NAME: str = "DK's SQL Buddy"
    APP_VERSION: str = "2.0.0"
    DEFAULT_SERVER: str = "210.212.183.19"
    DEFAULT_PORT: int = 18187
    DEFAULT_USER: str = "support"
    DEFAULT_PASSWORD: str = "@Support#114477"
    METADATA_CACHE_PATH: str = os.path.join(os.path.dirname(__file__), "metadata_cache.json")
    SAVED_CONNECTIONS_PATH: str = os.path.join(os.path.dirname(__file__), "saved_connections.json")
    IMPORT_HISTORY_PATH: str = os.path.join(os.path.dirname(__file__), "import_history.json")
    SQL_LIBRARY_PATH: str = os.path.join(os.path.dirname(__file__), "sql_library.json")
    USERS_PATH: str = os.path.join(os.path.dirname(__file__), "users.json")
    AVATARS_PATH: str = os.path.join(os.path.dirname(__file__), "static", "avatars")
    # Session secret — stored in a file so it persists across restarts
    _SECRET_FILE: str = os.path.join(os.path.dirname(__file__), ".session_secret")

    @property
    def SESSION_SECRET(self) -> str:
        if not os.path.exists(self._SECRET_FILE):
            secret = secrets.token_hex(32)
            with open(self._SECRET_FILE, "w") as f:
                f.write(secret)
            return secret
        with open(self._SECRET_FILE, "r") as f:
            return f.read().strip()

settings = Settings()
