from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base

class SecretChat(Base):
    __tablename__ = "secret_chats"

    id = Column(Integer, primary_key=True, index=True)
    user1_id = Column(Integer, ForeignKey("users.id"))
    user2_id = Column(Integer, ForeignKey("users.id"))
    encryption_key = Column(String, nullable=False)

