from sqlalchemy import Column, String, Integer
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.message import Message


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True)
    email = Column(String, unique=True)
    phone = Column(String, unique=True, nullable=True)
    password = Column(String)
    avatar = Column(String, default="")
    role = Column(String, default="user")  # "user" or "admin"

    # Messages alizotuma
    sent_messages = relationship(
        "Message",
        foreign_keys=[Message.sender_id],
        back_populates="sender"
    )

    # Messages alizopokea
    received_messages = relationship(
        "Message",
        foreign_keys=[Message.receiver_id],
        back_populates="receiver"
    )

    # Privacy settings
    privacy_settings = relationship("Privacy", back_populates="user", cascade="all, delete-orphan")
    chat_memberships = relationship("ChatMember", back_populates="user", cascade="all, delete-orphan")
   
     # new relationships for broadcast system
    broadcasts = relationship("Broadcast", back_populates="sender")
    received_broadcasts = relationship("BroadcastRecipient", back_populates="recipient")
    
    # relationships
    calls_made = relationship("CallSession", foreign_keys="[CallSession.caller_id]", back_populates="caller")
    calls_received = relationship("CallSession", foreign_keys="[CallSession.callee_id]", back_populates="callee")
