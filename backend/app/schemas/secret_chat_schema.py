from pydantic import BaseModel

class SecretChatBase(BaseModel):
    user1_id: int
    user2_id: int
    encryption_key: str

class SecretChatCreate(SecretChatBase):
    pass

class SecretChatResponse(SecretChatBase):
    id: int

    class Config:
        orm_mode = True

