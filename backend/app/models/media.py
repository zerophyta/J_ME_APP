from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base

class Media(Base):
    __tablename__ = "media"

    id = Column(Integer, primary_key=True, index=True)
    message_id = Column(Integer, ForeignKey("messages.id"))
    file_url = Column(String, nullable=False)
    file_type = Column(String, nullable=False)  # image, video, audio

