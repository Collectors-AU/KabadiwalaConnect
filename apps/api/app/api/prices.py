from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db

router = APIRouter(prefix="/api/prices", tags=["prices"])


@router.get("/")
def get_prices(
    material_category_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """Get current prices for materials."""
    from app.services.price_engine import get_current_prices

    prices = get_current_prices(db, material_category_id)
    return prices


@router.get("/trend")
def get_price_trend(
    material_category_id: str = Query(...),
    period: str = Query("30d"),  # 7d, 30d, 90d
    db: Session = Depends(get_db),
):
    """Get price trends for a material over a period."""
    from app.services.price_engine import get_price_trends

    return get_price_trends(db, material_category_id, period)
