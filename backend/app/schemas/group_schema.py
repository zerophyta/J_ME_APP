from datetime import datetime
from typing import Optional
from pydantic import BaseModel

class GroupBase(BaseModel):
    name: str
    admin_id: int

class MemberResponse(BaseModel):
    id: int
    username: str

class GroupCreate(GroupBase):
    pass

class GroupResponse(GroupBase):
    id: int
    name: str
    admin_id: int
    admin_username: str
    members: list[MemberResponse]
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

class RemoveMemberRequest(BaseModel):
    group_id: int
    admin_id: int
    member_id: int   # member anayefutwa

class AssignAdminRequest(BaseModel):
    group_id: int
    admin_id: int        # current admin
    new_admin_id: int    # member anayechaguliwa kuwa admin mpya

    class Config:
        orm_mode = True

