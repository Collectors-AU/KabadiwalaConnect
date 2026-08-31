from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, Boolean, DateTime, ForeignKey, Text

from app.database import Base


class Recycler(Base):
    __tablename__ = "recyclers"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=True)
    name = Column(String, nullable=False)
    facility_location = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    materials_accepted = Column(Text, nullable=False, default="[]")  # JSON array as text
    authorization_status = Column(String, nullable=False)  # VERIFIED, PENDING_VERIFICATION, EXPIRED, UNKNOWN
    authorization_reference = Column(String, nullable=True)
    contact = Column(String, nullable=True)
    offered_rates = Column(Text, nullable=False, default="{}")  # JSON object as text {material_name: rate_per_kg}
    pickup_available = Column(Boolean, nullable=False, default=False)
    service_radius_km = Column(Float, nullable=False, default=10.0)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
