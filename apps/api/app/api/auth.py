from typing import Optional

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.auth import DemoLoginRequest, DemoLoginResponse

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/demo-login")
def demo_login(request: DemoLoginRequest, db: Session = Depends(get_db)):
    """
    Demo login: creates or finds a user and returns a token.
    The token is simply the user_id for MVP simplicity.
    """
    # Check if user with this display_name and role exists
    existing = db.query(User).filter(
        User.display_name == request.display_name,
        User.role == request.role,
    ).first()

    if existing:
        return DemoLoginResponse(
            user_id=existing.id,
            token=existing.id,
            role=existing.role,
            display_name=existing.display_name,
            preferred_language=existing.preferred_language,
        )

    # Create new user
    user = User(
        id=str(uuid.uuid4()),
        role=request.role,
        display_name=request.display_name,
        preferred_language=request.language,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return DemoLoginResponse(
        user_id=user.id,
        token=user.id,
        role=user.role,
        display_name=user.display_name,
        preferred_language=user.preferred_language,
    )
