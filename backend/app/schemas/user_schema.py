from pydantic import BaseModel, EmailStr
from typing import Optional

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    avatar: Optional[str] = None
    password: Optional[str] = None

class UserRegister(BaseModel):
    username: str
    email: EmailStr
    password: str
    phone: Optional[str] = None   # optional lakini ikitumwa itahifadhiwa


class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    phone: Optional[str] = None
    avatar: Optional[str] = None

    class Config:
        orm_mode = True
