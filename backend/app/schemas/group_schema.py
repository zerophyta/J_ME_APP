from datetime import datetime
from typing import Optional
from pydantic import BaseModel

class GroupBase(BaseModel):
    name: str
    admin_id: int

class GroupCreate(GroupBase):
    pass

class GroupResponse(GroupBase):
    id: int
    name: str
    admin_id: int
    admin_username: str
    created_at: Optional[datetime]

class LeaveGroupRequest(BaseModel):
    group_id: int
    user_id: int

class JoinGroupRequest(BaseModel):
    group_id: int
    user_id: int

class DeleteGroupRequest(BaseModel):
    group_id: int
    admin_id: int
    transfer_to_user_id: int | None = None  # optional kama admin anataka kumkabidhi mtu mwingine

    class Config:
        orm_mode = True

