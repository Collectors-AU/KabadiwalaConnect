from typing import Optional

from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.repositories.base import BaseRepository
from app.models.price import PriceObservation


class PriceRepository(BaseRepository[PriceObservation]):
    def __init__(self, db: Session):
        super().__init__(PriceObservation, db)

    def get_by_material(self, material_category_id: str, days: int = 30) -> List[PriceObservation]:
        cutoff = datetime.utcnow() - timedelta(days=days)
        return self.db.query(PriceObservation).filter(
            PriceObservation.material_category_id == material_category_id,
            PriceObservation.observed_at >= cutoff
        ).order_by(PriceObservation.observed_at.desc()).all()

    def get_latest_by_material(self, material_category_id: str) -> Optional[PriceObservation]:
        return self.db.query(PriceObservation).filter(
            PriceObservation.material_category_id == material_category_id
        ).order_by(PriceObservation.observed_at.desc()).first()

    def get_recent(self, days: int = 7) -> List[PriceObservation]:
        cutoff = datetime.utcnow() - timedelta(days=days)
        return self.db.query(PriceObservation).filter(
            PriceObservation.observed_at >= cutoff
        ).order_by(PriceObservation.observed_at.desc()).all()
