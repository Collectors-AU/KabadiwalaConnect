from typing import Optional

from pydantic import BaseModel


class DemoLoginRequest(BaseModel):
    role: str = "COLLECTOR"  # COLLECTOR, RECYCLER, ADMIN
    display_name: str = "Demo User"
    language: str = "en"


class DemoLoginResponse(BaseModel):
    user_id: str
    token: str
    role: str
    display_name: str
    preferred_language: str
