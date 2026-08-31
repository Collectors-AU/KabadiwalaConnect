from typing import Optional

from sqlalchemy.orm import Session
from app.repositories.base import BaseRepository
from app.models.lot import Lot


class LotRepository(BaseRepository[Lot]):
    def __init__(self, db: Session):
        super().__init__(Lot, db)

    def get_by_collector(self, collector_id: str, status: Optional[str] = None, skip: int = 0, limit: int = 100) -> List[Lot]:
        query = self.db.query(Lot).filter(Lot.collector_id == collector_id)
        if status:
            query = query.filter(Lot.status == status)
        return query.order_by(Lot.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_status(self, status: str, skip: int = 0, limit: int = 100) -> List[Lot]:
        return self.db.query(Lot).filter(Lot.status == status).order_by(Lot.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_material(self, material_category_id: str, status: Optional[str] = None) -> List[Lot]:
        query = self.db.query(Lot).filter(Lot.material_category_id == material_category_id)
        if status:
            query = query.filter(Lot.status == status)
        return query.order_by(Lot.created_at.desc()).all()

    def update_status(self, lot_id: str, new_status: str) -> Optional[Lot]:
        lot = self.get_by_id(lot_id)
        if lot:
            lot.status = new_status
            self.db.commit()
            self.db.refresh(lot)
        return lot
