from sqlalchemy import Column, String, Integer
from app.database import Base
from sqlalchemy.orm import relationship



class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True)
    email = Column(String, unique=True)
    phone = Column(String, unique=True, nullable=True)
    password = Column(String)
    avatar = Column(String, default="")
    role = Column(String, default="user")  # "user" or "admin"

messages = relationship("Message", back_populates="sender", cascade="all, delete-orphan")

