from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.secret_chat import SecretChat
from app.models.user import User
from app.schemas.secret_chat_schema import SecretChatCreate, SecretChatResponse
from datetime import datetime

router = APIRouter(prefix="/secret_chat", tags=["SecretChat"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/start-secret", response_model=SecretChatResponse)
def start_secret_chat(identifier: str, current_user_id: int, db: Session = Depends(get_db)):
    # validate current user
    current_user = db.query(User).filter(User.id == current_user_id).first()
    if not current_user:
        raise HTTPException(status_code=404, detail="Current user not found")

    # Try phone first
    other_user = db.query(User).filter(User.phone == identifier).first()

    # Fallback to username
    if not other_user:
        other_user = db.query(User).filter(User.username == identifier).first()

    if not other_user:
        raise HTTPException(
            status_code=404,
            detail="User not found. Please provide phone number or username."
        )

    # check kama chat tayari ipo
    existing_secret = db.query(SecretChat).filter(
        ((SecretChat.user1_id == current_user_id) & (SecretChat.user2_id == other_user.id)) |
        ((SecretChat.user1_id == other_user.id) & (SecretChat.user2_id == current_user_id))
    ).first()

    if existing_secret:
        return existing_secret

    # create secret chat
    new_chat = SecretChat(
        user1_id=current_user_id,
        user2_id=other_user.id,
        encryption_key="generated_key",
        created_at=datetime.utcnow()
    )
    db.add(new_chat)
    db.commit()
    db.refresh(new_chat)
    return new_chat

# Get all secret chats
@router.get("/secret", response_model=list[SecretChatResponse])
def get_secret_chats(db: Session = Depends(get_db)):
    return db.query(SecretChat).all()

