from pydantic import BaseModel

class PrivacyBase(BaseModel):
    user_id: int
    setting: str
    value: str

class PrivacyCreate(PrivacyBase):
    pass

class PrivacyResponse(PrivacyBase):
    id: int

    class Config:
        orm_mode = True

