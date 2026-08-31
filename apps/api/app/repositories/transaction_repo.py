from typing import Optional

from sqlalchemy.orm import Session
from app.repositories.base import BaseRepository
from app.models.transaction import Transaction


class TransactionRepository(BaseRepository[Transaction]):
    def __init__(self, db: Session):
        super().__init__(Transaction, db)

    def get_by_collector(self, collector_id: str, skip: int = 0, limit: int = 100) -> List[Transaction]:
        return self.db.query(Transaction).filter(
            Transaction.collector_id == collector_id
        ).order_by(Transaction.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_recycler(self, recycler_id: str, skip: int = 0, limit: int = 100) -> List[Transaction]:
        return self.db.query(Transaction).filter(
            Transaction.recycler_id == recycler_id
        ).order_by(Transaction.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_reference(self, reference: str) -> Optional[Transaction]:
        return self.db.query(Transaction).filter(Transaction.handover_reference == reference).first()

    def get_by_lot(self, lot_id: str) -> Optional[Transaction]:
        return self.db.query(Transaction).filter(Transaction.lot_id == lot_id).first()

    def get_completed(self, skip: int = 0, limit: int = 100) -> List[Transaction]:
        return self.db.query(Transaction).filter(
            Transaction.transaction_status == "COMPLETED"
        ).order_by(Transaction.completed_at.desc()).offset(skip).limit(limit).all()

    def get_by_status(self, status: str, skip: int = 0, limit: int = 100) -> List[Transaction]:
        return self.db.query(Transaction).filter(
            Transaction.transaction_status == status
        ).order_by(Transaction.created_at.desc()).offset(skip).limit(limit).all()
