from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.group import Group
from app.schemas.group_schema import GroupCreate, GroupResponse

router = APIRouter(prefix="/groups", tags=["Groups"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=GroupResponse)
def create_group(group: GroupCreate, db: Session = Depends(get_db)):
    new_group = Group(name=group.name, admin_id=group.admin_id)
    db.add(new_group)
    db.commit()
    db.refresh(new_group)
    return new_group

@router.get("/", response_model=list[GroupResponse])
def get_groups(db: Session = Depends(get_db)):
    return db.query(Group).all()

