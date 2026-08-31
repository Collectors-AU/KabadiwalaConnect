from typing import Optional

from typing import List, Optional

from pydantic import BaseModel


class PriceResponse(BaseModel):
    material_category_id: str
    material_name: str
    current_price: float
    min_price: float
    max_price: float
    unit: str = "KG"
    trend: str  # UP, DOWN, STABLE
    last_updated: Optional[str] = None


class PriceTrendPoint(BaseModel):
    date: str
    price: float


class PriceTrendResponse(BaseModel):
    material_category_id: str
    material_name: str
    period: str
    data_points: List[PriceTrendPoint] = []
    trend_direction: str
    change_percent: float
