from sqlalchemy import Column, Integer,String, ForeignKey
from app.database import Base

class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.id",ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id",ondelete="CASCADE"), nullable=False)
    role = Column(String, default="member", nullable=False)  # "member" or "admin"
