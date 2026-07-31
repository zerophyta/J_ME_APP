from typing import Optional
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
from app.models.group import Group

router = APIRouter(prefix="/messages", tags=["Messages"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=MessageResponse)
def send_message(message: MessageCreate, db: Session = Depends(get_db)):

    # Normal chat
    if message.chat_id:
        chat = db.query(Chat).filter(Chat.id == message.chat_id).first()
        if not chat:
            raise HTTPException(status_code=400, detail="Chat does not exist")

        # Check sender
        if message.sender_id not in [chat.user1_id, chat.user2_id]:
            raise HTTPException(status_code=403, detail="Sender not in this chat")

        # Check receiver
        if message.receiver_id not in [chat.user1_id, chat.user2_id]:
            raise HTTPException(status_code=403, detail="Receiver not in this chat")

        if message.sender_id == message.receiver_id:
            raise HTTPException(status_code=400, detail="Sender and receiver cannot be the same")

        new_msg = Message(
            chat_id=message.chat_id,
            sender_id=message.sender_id,
            receiver_id=message.receiver_id,
            content=message.content,
            timestamp=datetime.utcnow()
        )

    # Secret chat
    elif message.secret_chat_id:
        secret_chat = db.query(SecretChat).filter(SecretChat.id == message.secret_chat_id).first()
        if not secret_chat:
            raise HTTPException(status_code=400, detail="Secret chat does not exist")

        if message.sender_id not in [secret_chat.user1_id, secret_chat.user2_id]:
            raise HTTPException(status_code=403, detail="Sender not in this secret chat")

        if message.receiver_id not in [secret_chat.user1_id, secret_chat.user2_id]:
            raise HTTPException(status_code=403, detail="Receiver not in this secret chat")

       # if message.sender_id == message.receiver_id:
           # raise HTTPException(status_code=400, detail="Sender and receiver cannot be the same")

        new_msg = Message(
            secret_chat_id=message.secret_chat_id,
            sender_id=message.sender_id,
            receiver_id=message.receiver_id,
            content=message.content,
            timestamp=datetime.utcnow()
        )

       # Group chat
    elif message.group_id:
        group = db.query(Group).filter(Group.id == message.group_id).first()
        if not group:
            raise HTTPException(status_code=400, detail="Group does not exist")

        # Check sender is member of group
        sender_in_group = db.query(ChatMember).filter(
            ChatMember.group_id == message.group_id,
            ChatMember.user_id == message.sender_id
        ).first()
        
        if not sender_in_group and message.sender_id != group.admin_id:
            raise HTTPException(status_code=403, detail="Sender not in group")

        new_msg = Message(
            group_id=message.group_id,
            sender_id=message.sender_id,
            receiver_id=message.receiver_id,  # optional kwa group
            content=message.content,
            timestamp=datetime.utcnow()
        )

    else:
        raise HTTPException(status_code=400, detail="Either chat_id or secret_chat_id required")

    db.add(new_msg)
    db.commit()
    db.refresh(new_msg)
    return new_msg



@router.get("/", response_model=list[MessageResponse])
def get_messages(
    chat_id: Optional[int] = None,
    secret_chat_id: Optional[int] = None,
    group_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    if chat_id:
        chat = db.query(Chat).filter(Chat.id == chat_id).first()
        if not chat:
            raise HTTPException(status_code=400, detail="Chat does not exist")
        return db.query(Message).filter(Message.chat_id == chat_id).order_by(Message.timestamp).all()

    elif secret_chat_id:
        secret_chat = db.query(SecretChat).filter(SecretChat.id == secret_chat_id).first()
        if not secret_chat:
            raise HTTPException(status_code=400, detail="Secret chat does not exist")
        return db.query(Message).filter(Message.secret_chat_id == secret_chat_id).order_by(Message.timestamp).all()

    elif group_id:
        group = db.query(Group).filter(Group.id == group_id).first()
        if not group:
            raise HTTPException(status_code=400, detail="Group does not exist")
        return db.query(Message).filter(Message.group_id == group_id).order_by(Message.timestamp).all()

    else:
        raise HTTPException(status_code=400, detail="chat_id, secret_chat_id or group_id required")

