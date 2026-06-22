from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base

class Privacy(Base):
    __tablename__ = "privacy"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    setting = Column(String, nullable=False)  # e.g. "last_seen", "profile_photo"
    value = Column(String, nullable=False)    # e.g. "everyone", "contacts", "nobody"

