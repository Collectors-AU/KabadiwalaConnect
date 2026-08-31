from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.material import MaterialCategory
from app.schemas.material import MaterialCategoryResponse

router = APIRouter(prefix="/api/materials", tags=["materials"])


@router.get("/")
def list_materials(db: Session = Depends(get_db)):
    """List all material categories."""
    materials = db.query(MaterialCategory).all()
    return [MaterialCategoryResponse.model_validate(m) for m in materials]
