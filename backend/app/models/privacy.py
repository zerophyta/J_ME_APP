from sqlalchemy import Column, Integer, String, ForeignKey
from app.database import Base
from sqlalchemy.orm import relationship

class Privacy(Base):
    __tablename__ = "privacy"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False )
    setting = Column(String, nullable=False)  # e.g. "last_seen", "profile_photo"
    value = Column(String, nullable=False)    # e.g. "everyone", "contacts", "nobody"

    user = relationship("User", back_populates="privacy_settings")
