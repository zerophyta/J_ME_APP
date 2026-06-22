from sqlalchemy import Column, String, Integer
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String)
    email = Column(String, unique=True)
    phone = Column(String)
    password = Column(String)
    avatar = Column(String, default="")

