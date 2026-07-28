from datetime import datetime
from pydantic import BaseModel

class ChatResponse(BaseModel):
    id: int
    user1_id: int
    user2_id: int
    created_at: datetime

    class Config:
        orm_mode = True

