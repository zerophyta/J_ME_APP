from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.group_member import GroupMember
from app.models.group import Group
from app.models.user import User
from app.schemas.group_schema import GroupCreate, GroupResponse, DeleteGroupRequest, LeaveGroupRequest, JoinGroupRequest
from datetime import datetime

router = APIRouter(prefix="/groups", tags=["Groups"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=GroupResponse)
def create_group(group: GroupCreate, db: Session = Depends(get_db)):
    # validate admin user
    admin = db.query(User).filter(User.id == group.admin_id).first()
    if not admin:
        raise HTTPException(status_code=404, detail="Admin user not found")

    new_group = Group(
        name=group.name,
        admin_id=group.admin_id,
        created_at=datetime.utcnow()
    )
    db.add(new_group)
    db.commit()
    db.refresh(new_group)

    admin_member = GroupMember(group_id=new_group.id, user_id=group.admin_id)
    db.add(admin_member)
    db.commit()

    # return with admin_username
    return {
        "id": new_group.id,
        "name": new_group.name,
        "admin_id": new_group.admin_id,
        "admin_username": admin.username,
        "created_at": new_group.created_at
    }


@router.post("/join")
def join_group(request: JoinGroupRequest, db: Session = Depends(get_db)):
    # check kama group ipo
    group = db.query(Group).filter(Group.id == request.group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    # check kama user yupo
    user = db.query(User).filter(User.id == request.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # check kama tayari ni member
    existing = db.query(GroupMember).filter(
        GroupMember.group_id == request.group_id,
        GroupMember.user_id == request.user_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already a member")

    # add membership
    member = GroupMember(group_id=request.group_id, user_id=request.user_id)
    db.add(member)
    db.commit()
    db.refresh(member)

    return {"status": "success", "message": f"{user.username} joined {group.name}"}

@router.post("/leave")
def leave_group(request: LeaveGroupRequest, db: Session = Depends(get_db)):
    # check kama group ipo
    group = db.query(Group).filter(Group.id == request.group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    # check kama user yupo
    user = db.query(User).filter(User.id == request.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # check kama user ni member
    membership = db.query(GroupMember).filter(
        GroupMember.group_id == request.group_id,
        GroupMember.user_id == request.user_id
    ).first()
    if not membership:
        raise HTTPException(status_code=400, detail="User is not a member of this group")

    # kama ni admin
    if membership.role == "admin":
        # hesabu admins wote
        admins = db.query(GroupMember).filter(
            GroupMember.group_id == request.group_id,
            GroupMember.role == "admin"
        ).all()

        if len(admins) <= 1:
            raise HTTPException(
                status_code=400,
                detail="Group must have at least one admin. Transfer admin role before leaving."
            )

    # remove membership
    db.delete(membership)
    db.commit()

    return {"status": "success", "message": f"{user.username} left {group.name}"}


@router.post("/delete")
def delete_group(request: DeleteGroupRequest, db: Session = Depends(get_db)):
    group = db.query(Group).filter(Group.id == request.group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Group not found")

    if group.admin_id != request.admin_id:
        raise HTTPException(status_code=403, detail="Only admin can delete group")

    # count members
    members = db.query(GroupMember).filter(GroupMember.group_id == request.group_id).all()
    member_count = len(members)

    # case 1: only admin is member
    if member_count == 1:
        db.delete(group)
        db.commit()
        return {"status": "success", "message": f"Group '{group.name}' deleted by admin"}

    # case 2: admin wants to transfer ownership
    if request.transfer_to_user_id:
        new_admin = db.query(User).filter(User.id == request.transfer_to_user_id).first()
        if not new_admin:
            raise HTTPException(status_code=404, detail="New admin user not found")

        group.admin_id = new_admin.id
        db.commit()
        return {"status": "success", "message": f"Admin transferred group '{group.name}' to {new_admin.username}"}

    # case 3: admin must remove all members first
    raise HTTPException(
        status_code=400,
        detail="Group has other members. Remove them or transfer admin before deleting."
    )

@router.get("/", response_model=list[GroupResponse])
def get_groups(db: Session = Depends(get_db)):
    groups = db.query(Group).all()
    response = []
    for g in groups:
        admin = db.query(User).filter(User.id == g.admin_id).first()
        response.append({
            "id": g.id,
            "name": g.name,
            "admin_id": g.admin_id,
            "admin_username": admin.username if admin else "Unknown",
            "created_at": datetime.utcnow()
        })
    return response

