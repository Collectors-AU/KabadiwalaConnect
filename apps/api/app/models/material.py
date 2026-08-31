from typing import Optional

import uuid
from datetime import datetime

from sqlalchemy import Column, String, DateTime

from app.database import Base


class MaterialCategory(Base):
    __tablename__ = "material_categories"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, unique=True, nullable=False)  # CRT, LCD, PCB, CABLE, BATTERY, MOTOR, MAGNET_ASSEMBLY, MIXED_PLASTIC
    display_name_en = Column(String, nullable=False)
    display_name_hi = Column(String, nullable=False)
    display_name_mr = Column(String, nullable=False)
    description = Column(String, nullable=False)
    hazard_level = Column(String, nullable=False)  # LOW, MEDIUM, HIGH
    icon = Column(String, nullable=False, default="")
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
