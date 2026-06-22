from pydantic import BaseModel

class GroupBase(BaseModel):
    name: str
    admin_id: int

class GroupCreate(GroupBase):
    pass

class GroupResponse(GroupBase):
    id: int

    class Config:
        orm_mode = True

