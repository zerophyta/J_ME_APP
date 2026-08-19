import os
from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.message import Message
from app.schemas.broadcast_schema import BroadcastMessageRequest

router = APIRouter(prefix="/admin", tags=["Admin"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# read admin id from dotenv
ADMIN_ID = int(os.getenv("ADMIN_ID", "0"))

@router.post("/broadcast")
def broadcast_message(request: BroadcastMessageRequest, db: Session = Depends(get_db)):
    # validate admin via dotenv
    if ADMIN_ID == 0:
        raise HTTPException(status_code=500, detail="Admin ID not configured in .env")

    # fetch all users except admin
    users = db.query(User).filter(User.id != ADMIN_ID).all()

    if not users:
        raise HTTPException(status_code=404, detail="No users found to broadcast")

    # create message for each user
    for u in users:
        msg = Message(
            sender_id=ADMIN_ID,
            receiver_id=u.id,
            content=request.content,
            timestamp=datetime.utcnow()
        )
        db.add(msg)

    db.commit()

    return {
        "status": "success",
        "sent_to": len(users),
        "content": request.content,
        "sender_id": ADMIN_ID
    }


# 🔹 Notify single user
@router.post("/notify/{user_id}")
def notify_user(user_id: int, request: BroadcastMessageRequest, db: Session = Depends(get_db)):
    if ADMIN_ID == 0:
        raise HTTPException(status_code=500, detail="Admin ID not configured in .env")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    msg = Message(
        sender_id=ADMIN_ID,
        receiver_id=user.id,
        content=request.content,
        timestamp=datetime.utcnow()
    )
    db.add(msg)
    db.commit()

    return {
        "status": "success",
        "message": f"Notification sent to {user.username}",
        "content": request.content
    }

# 🔹 Get all users (names + IDs)
@router.get("/users")
def list_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return [{"id": u.id, "username": u.username} for u in users]

# 🔹 Get all groups (names + IDs)
@router.get("/groups")
def list_groups(db: Session = Depends(get_db)):
    groups = db.query(Group).all()
    return [{"id": g.id, "name": g.name} for g in groups]

