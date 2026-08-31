from typing import Optional

import json
from sqlalchemy.orm import Session
from app.repositories.base import BaseRepository
from app.models.recycler import Recycler


class RecyclerRepository(BaseRepository[Recycler]):
    def __init__(self, db: Session):
        super().__init__(Recycler, db)

    def get_by_material(self, material_name: str) -> List[Recycler]:
        """Get recyclers that accept a given material."""
        all_recyclers = self.get_all()
        return [
            r for r in all_recyclers
            if material_name in json.loads(r.materials_accepted or "[]")
        ]

    def get_verified(self) -> List[Recycler]:
        return self.db.query(Recycler).filter(Recycler.authorization_status == "VERIFIED").all()

    def get_by_user_id(self, user_id: str) -> Optional[Recycler]:
        return self.db.query(Recycler).filter(Recycler.user_id == user_id).first()
