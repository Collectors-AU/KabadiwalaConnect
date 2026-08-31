from typing import Optional

from typing import List, Optional

from pydantic import BaseModel


class TraceabilityEventResponse(BaseModel):
    id: str
    lot_id: str
    event_type: str
    location: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    timestamp: str
    photo_url: Optional[str] = None
    actor_id: str
    reference_number: Optional[str] = None
    metadata: dict = {}

    class Config:
        from_attributes = True


class MaterialPassportResponse(BaseModel):
    lot_id: str
    material_category: str
    collector_name: str
    current_status: str
    weight: float
    events: List[TraceabilityEventResponse] = []
    verification_url: str
