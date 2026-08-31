from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, ForeignKey

from app.database import Base


class PriceObservation(Base):
    __tablename__ = "price_observations"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    material_category_id = Column(String, ForeignKey("material_categories.id"), nullable=False)
    location = Column(String, nullable=True)
    observed_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    buying_price = Column(Float, nullable=False)
    selling_price = Column(Float, nullable=True)
    unit = Column(String, nullable=False, default="KG")
    recycler_id = Column(String, ForeignKey("recyclers.id"), nullable=True)
    source = Column(String, nullable=False)  # FIELD_ENTRY, RECYCLER_QUOTE, PLATFORM_TRANSACTION, SEEDED_DEMO_DATA
    quality = Column(String, nullable=False)  # GOOD, FAIR, POOR
