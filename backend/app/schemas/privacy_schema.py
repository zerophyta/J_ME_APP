from pydantic import BaseModel

class PrivacyCreate(BaseModel):
    user_id: int
    setting: str
    value: str   

class PrivacyResponse(BaseModel):
    id: int
    user_id: int
    setting: str
    value: str

    class Config:
        orm_mode = True

