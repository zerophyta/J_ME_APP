from pydantic import BaseModel

class MediaBase(BaseModel):
    message_id: int
    file_url: str
    file_type: str

class MediaCreate(MediaBase):
    pass

class MediaResponse(MediaBase):
    id: int

    class Config:
        orm_mode = True

