from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.media import Media
from app.schemas.media_schema import MediaCreate, MediaResponse

router = APIRouter(prefix="/media", tags=["Media"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=MediaResponse)
def upload_media(media: MediaCreate, db: Session = Depends(get_db)):
    new_media = Media(
        message_id=media.message_id,
        file_url=media.file_url,
        file_type=media.file_type
    )
    db.add(new_media)
    db.commit()
    db.refresh(new_media)
    return new_media

