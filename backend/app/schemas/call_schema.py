from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CallSessionBase(BaseModel):
    caller_id: int
    callee_id: int
    call_type: str = "voice"

class CallSessionCreate(CallSessionBase):
    pass

class CallSessionResponse(CallSessionBase):
    id: int
    status: str
    started_at: datetime
    ended_at: Optional[datetime] = None

    class Config:
        orm_mode = True

