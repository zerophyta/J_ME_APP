from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.chat import Chat
from app.schemas.group_schema import GroupResponse

router = APIRouter(prefix="/chats", tags=["Chats"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=list[GroupResponse])
def get_chats(db: Session = Depends(get_db)):
    return db.query(Chat).all()

