from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.database import Base
import datetime

class CallSession(Base):
    __tablename__ = "call_sessions"

    id = Column(Integer, primary_key=True, index=True)
    caller_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    callee_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)  # null for group calls
    chat_id = Column(Integer, ForeignKey("groups.id", ondelete="CASCADE"), nullable=True)   # group call reference
    call_type = Column(String, default="voice")  # voice, video, group_voice, group_video
    status = Column(String, default="initiated")
    started_at = Column(DateTime, default=datetime.datetime.utcnow)
    ended_at = Column(DateTime, nullable=True)
     
      #relationship
    caller = relationship("User", foreign_keys=[caller_id])
    callee = relationship("User", foreign_keys=[callee_id])
    group = relationship("Group", foreign_keys=[chat_id])

