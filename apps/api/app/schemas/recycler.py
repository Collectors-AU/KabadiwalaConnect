from typing import Optional

from typing import List, Optional

from pydantic import BaseModel


class RecyclerResponse(BaseModel):
    id: str
    user_id: Optional[str] = None
    name: str
    facility_location: str
    latitude: float
    longitude: float
    materials_accepted: List[str] = []
    authorization_status: str
    authorization_reference: Optional[str] = None
    contact: Optional[str] = None
    offered_rates: dict = {}
    pickup_available: bool
    service_radius_km: float

    class Config:
        from_attributes = True


class RecyclerMatchResponse(BaseModel):
    recycler: RecyclerResponse
    match_score: float
    reasons: List[str] = []
