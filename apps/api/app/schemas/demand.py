from typing import Optional


from pydantic import BaseModel


class DemandCreate(BaseModel):
    recycler_id: str
    material_category_id: str
    required_weight: float
    offered_price: float
    pickup_available: bool = False
    service_radius_km: float = 10.0
    valid_until: str  # ISO datetime string


class DemandResponse(BaseModel):
    id: str
    recycler_id: str
    material_category_id: str
    required_weight: float
    offered_price: float
    pickup_available: bool
    service_radius_km: float
    valid_until: str
    status: str
    created_at: str
    recycler_name: Optional[str] = None
    material_name: Optional[str] = None

    class Config:
        from_attributes = True
