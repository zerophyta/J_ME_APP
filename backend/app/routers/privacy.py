from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.privacy import Privacy
from app.schemas.privacy_schema import PrivacyCreate, PrivacyResponse

router = APIRouter(prefix="/privacy", tags=["Privacy"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=PrivacyResponse)
def set_privacy(privacy: PrivacyCreate, db: Session = Depends(get_db)):
    new_privacy = Privacy(
        user_id=privacy.user_id,
        setting=privacy.setting,
        value=privacy.value
    )
    db.add(new_privacy)
    db.commit()
    db.refresh(new_privacy)
    return new_privacy

