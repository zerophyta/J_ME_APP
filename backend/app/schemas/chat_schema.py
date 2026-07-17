from pydantic import BaseModel

class ChatResponse(BaseModel):
    chat_id: int
    with_user: str   # username ya mtu mwingine

    class Config:
        orm_mode = True

