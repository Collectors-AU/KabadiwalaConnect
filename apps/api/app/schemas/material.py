from typing import Optional

from pydantic import BaseModel


class MaterialCategoryResponse(BaseModel):
    id: str
    name: str
    display_name_en: str
    display_name_hi: str
    display_name_mr: str
    description: str
    hazard_level: str
    icon: str

    class Config:
        from_attributes = True
