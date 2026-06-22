from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.message import Message
from app.schemas.message_schema import MessageCreate, MessageResponse

router = APIRouter(prefix="/messages", tags=["Messages"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=MessageResponse)
def send_message(message: MessageCreate, db: Session = Depends(get_db)):
    new_msg = Message(
        chat_id=message.chat_id,
        sender_id=message.sender_id,
        content=message.content
    )
    db.add(new_msg)
    db.commit()
    db.refresh(new_msg)
    return new_msg

@router.get("/{chat_id}", response_model=list[MessageResponse])
def get_messages(chat_id: int, db: Session = Depends(get_db)):
    return db.query(Message).filter(Message.chat_id == chat_id).all()

