from typing import Optional
from pydantic import BaseModel
from datetime import datetime

class SecretChatBase(BaseModel):
    user1_id: int
    user2_id: int
    encryption_key: str
    created_at: datetime

class SecretChatCreate(SecretChatBase):
    pass

class SecretChatResponse(SecretChatBase):
    id: int

    class Config:
        orm_mode = True

