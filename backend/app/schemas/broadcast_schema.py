from pydantic import BaseModel
from typing import List

class BroadcastRequest(BaseModel):
    sender_id: int
    content: str
    recipient_ids: List[int]

class BroadcastMessageRequest(BaseModel):
    sender_id: int
    content: str
    recipient_ids: List[int]
