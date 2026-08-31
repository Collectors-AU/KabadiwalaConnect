from typing import Optional

from typing import List, Optional

from pydantic import BaseModel


class LotCreate(BaseModel):
    material_category_id: str
    description: Optional[str] = None
    photo_urls: List[str] = []
    approximate_weight: float
    condition: str = "GOOD"  # GOOD, FAIR, POOR, MIXED
    source_type: str = "HOUSEHOLD"  # HOUSEHOLD, COMMERCIAL, INDUSTRIAL, MIXED
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    location_name: Optional[str] = None


class LotUpdate(BaseModel):
    description: Optional[str] = None
    photo_urls: Optional[List[str]] = None
    approximate_weight: Optional[float] = None
    condition: Optional[str] = None
    source_type: Optional[str] = None
    status: Optional[str] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    location_name: Optional[str] = None


class LotResponse(BaseModel):
    id: str
    collector_id: str
    material_category_id: str
    description: Optional[str] = None
    photo_urls: List[str] = []
    approximate_weight: float
    condition: str
    source_type: str
    estimated_min_value: Optional[float] = None
    estimated_max_value: Optional[float] = None
    estimated_price_per_unit: Optional[float] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    location_name: Optional[str] = None
    status: str
    sync_status: str
    created_at: str
    updated_at: str
    material_name: Optional[str] = None
    collector_name: Optional[str] = None

    class Config:
        from_attributes = True


class PriceEstimateResponse(BaseModel):
    min_price: float
    max_price: float
    reference_price: float
    confidence: float
    data_points_used: int
    trend: str  # UP, DOWN, STABLE
    price_per_unit: float
    total_estimated_value: float


class ClassificationResult(BaseModel):
    category: str
    confidence: float
    alternatives: List[dict] = []
