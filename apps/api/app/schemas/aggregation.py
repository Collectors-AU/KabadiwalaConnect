from typing import Optional


from pydantic import BaseModel


class AggregationGroupResponse(BaseModel):
    id: str
    material_category_id: str
    status: str
    total_weight: float
    individual_price_estimate: float
    group_price_estimate: float
    location_lat: float
    location_lng: float
    created_at: str
    material_name: Optional[str] = None
    member_count: int = 0
    potential_bonus_percent: float = 0.0

    class Config:
        from_attributes = True


class JoinGroupRequest(BaseModel):
    lot_id: str
    collector_id: str
