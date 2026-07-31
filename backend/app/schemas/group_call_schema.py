from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class GroupCallBase(BaseModel):
    caller_id: int
    chat_id: int
    call_type: str = "group_voice"

class GroupCallCreate(GroupCallBase):
    pass

class GroupCallResponse(GroupCallBase):
    id: int
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None

    class Config:
        orm_mode = True

