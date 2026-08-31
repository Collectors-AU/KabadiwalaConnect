from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text

from app.database import Base


class TraceabilityEvent(Base):
    __tablename__ = "traceability_events"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    lot_id = Column(String, ForeignKey("lots.id"), nullable=False)
    event_type = Column(String, nullable=False)  # COLLECTED, LISTED, OFFER_RECEIVED, OFFER_ACCEPTED, PICKUP_STARTED, HANDOVER, PAYMENT, RECEIVED_BY_RECYCLER, PROCESSING, RECYCLED
    location = Column(String, nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    timestamp = Column(DateTime, nullable=False, default=datetime.utcnow)
    photo_url = Column(String, nullable=True)
    actor_id = Column(String, ForeignKey("users.id"), nullable=False)
    reference_number = Column(String, nullable=True)
    event_metadata = Column(Text, nullable=False, default="{}")  # JSON text
