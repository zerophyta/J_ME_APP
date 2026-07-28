from pydantic import BaseModel, model_validator
from typing import Optional
from datetime import datetime

class MessageBase(BaseModel):
    chat_id: Optional[int] = None
    secret_chat_id: Optional[int] = None
    sender_id: int
    group_id: Optional[int] = None
    receiver_id: Optional[int] = None
    content: str

class UserInfo(BaseModel):
    id: int
    username: str

    class Config:
        orm_mode = True

class MessageCreate(MessageBase):

    @model_validator(mode="after")
    def check_chat_or_secret_or_group(self):
        if not self.chat_id and not self.secret_chat_id and not self.group_id:
            raise ValueError("Either chat_id, secret_chat_id or group_id must be provided")
        return self

class MessageResponse(BaseModel):
    id: int
    chat_id: Optional[int] = None
    secret_chat_id: Optional[int] = None
    group_id: Optional[int] = None
    sender_id: int
    receiver_id: Optional[int] = None
    content: str
    timestamp: datetime

    # Optional nested info
    sender: Optional[UserInfo] = None
    receiver: Optional[UserInfo] = None

    class Config:   # <-- lazima iwe ndani ya MessageResponse
        orm_mode = True

