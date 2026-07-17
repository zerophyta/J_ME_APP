from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from app.database import SessionLocal
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from app.database import SessionLocal
from app.models.message import Message
from app.models.chat_member import ChatMember
from app.models.chat import Chat
from app.models.secret_chat import SecretChat
from app.models.user import User
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
    # validate chat exists
    chat = db.query(Chat).filter(Chat.id == message.chat_id).first()
    if not chat:
        raise HTTPException(status_code=400, detail="Chat does not exist")

    # validate sender exists
    sender = db.query(User).filter(User.id == message.sender_id).first()
    if not sender:
        raise HTTPException(status_code=400, detail="Sender does not exist")

    # validate sender membership
    sender_in_chat = db.query(ChatMember).filter(
        ChatMember.chat_id == message.chat_id,
        ChatMember.user_id == message.sender_id
    ).first()
    if not sender_in_chat:
        raise HTTPException(status_code=403, detail="Sender not in chat")

    # validate secret chat exists
    secret_chat = db.query(SecretChat).filter(SecretChat.id == message.chat_id).first()
    if not secret_chat:
        raise HTTPException(status_code=400, detail="Secret chat does not exist")

    # validate sender and receiver are part of secret chat
    if message.sender_id not in [secret_chat.user1_id, secret_chat.user2_id]:
        raise HTTPException(status_code=403, detail="Sender not in this secret chat")

    if message.receiver_id not in [secret_chat.user1_id, secret_chat.user2_id]:
        raise HTTPException(status_code=403, detail="Receiver not in this secret chat")

    # ensure sender and receiver are not the same
    if message.sender_id == message.receiver_id:
        raise HTTPException(status_code=400, detail="Sender and receiver cannot be the same")

    # create and save message
    new_msg = Message(
        chat_id=message.chat_id,
        sender_id=message.sender_id,
        content=message.content,
        timestamp=datetime.utcnow()
    )
    db.add(new_msg)
    db.commit()
    db.refresh(new_msg)
    return new_msg

@router.get("/{chat_id}", response_model=list[MessageResponse])
def get_messages(chat_id: int, db: Session = Depends(get_db)):
    return db.query(Message).filter(Message.chat_id == chat_id).order_by(Message.timestamp).all()

