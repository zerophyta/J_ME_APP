from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class MessageBase(BaseModel):
    chat_id: int
    sender_id: int
    content: str

class MessageCreate(MessageBase):
    chat_id: int
    sender_id: int

class MessageResponse(MessageBase):
    id: int
    chat_id: int
    sender_id: int
    timestamp: datetime

    class Config:
        orm_mode = True

