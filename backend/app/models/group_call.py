from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.database import Base
import datetime

class GroupCallSession(Base):
    __tablename__ = "group_call_sessions"

    id = Column(Integer, primary_key=True, index=True)
    caller_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    chat_id = Column(Integer, ForeignKey("groups.id", ondelete="CASCADE"), nullable=False)
    call_type = Column(String, default="group_voice")  # group_voice or group_video
    status = Column(String, default="initiated")       # initiated, ongoing, ended
    started_at = Column(DateTime, default=datetime.datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)

    caller = relationship("User", foreign_keys=[caller_id])
    group = relationship("Group", foreign_keys=[chat_id])

