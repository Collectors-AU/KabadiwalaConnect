from typing import Optional


from pydantic import BaseModel


class CollectorResponse(BaseModel):
    id: str
    display_name: str
    preferred_language: str
    operating_area: Optional[str] = None
    role: str

    class Config:
        from_attributes = True
