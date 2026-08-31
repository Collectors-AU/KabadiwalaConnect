from typing import Optional

import os


class Settings:
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./kabadiwala.db")
    SECRET_KEY: str = os.getenv("SECRET_KEY", "kabadiwala-dev-secret-key-change-in-prod")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 1 week for demo
    CORS_ORIGINS: list = ["*"]
    APP_NAME: str = "Kabadiwala Connect API"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = os.getenv("DEBUG", "true").lower() == "true"


settings = Settings()
