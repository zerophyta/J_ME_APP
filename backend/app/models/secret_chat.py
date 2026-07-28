from datetime import datetime
import secrets
from sqlalchemy import Column, Integer, String,DateTime, ForeignKey
from app.database import Base
from sqlalchemy.orm import relationship
from .message import Message


def generate_chat_key():
    return secrets.token_hex(32)  # random 64-char hex string 


class SecretChat(Base):
    __tablename__ = "secret_chats"

    id = Column(Integer, primary_key=True, index=True)
    user1_id = Column(Integer, ForeignKey("users.id"))
    user2_id = Column(Integer, ForeignKey("users.id"))
    encryption_key = Column(String(64), nullable=False, default=generate_chat_key)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    messages = relationship("Message", back_populates="secret_chat", cascade="all, delete-orphan")

