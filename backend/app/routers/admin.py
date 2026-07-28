from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime
from app.models.message import Message
from app.schemas.broadcast_schema import BroadcastMessageRequest
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.utils.jwt_handler import decode_token

router = APIRouter(prefix="/admin", tags=["Admin"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(token: str, db: Session = Depends(get_db)):
    payload = decode_token(token)
    user = db.query(User).filter(User.id == payload["id"]).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

@router.get("/users")
def list_users(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    return db.query(User).all()

@router.get("/users/{user_id}")
def get_user(user_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/broadcast")
def broadcast_message(request: BroadcastMessageRequest, current_user_id: int, db: Session = Depends(get_db)):
    # validate current user
    admin = db.query(User).filter(User.id == current_user_id).first()
    if not admin or admin.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can broadcast messages")

    # fetch all users except admin
    users = db.query(User).filter(User.id != current_user_id).all()

    # create message for each user
    for u in users:
        msg = Message(
            sender_id=current_user_id,
            receiver_id=u.id,
            content=request.content,
            created_at=datetime.utcnow()
        )
        db.add(msg)

    db.commit()
    return {"status": "success", "sent_to": len(users)}
