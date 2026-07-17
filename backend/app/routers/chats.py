from fastapi import APIRouter, Depends,HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.chat import Chat
from app.schemas.group_schema import GroupResponse
from app.models.user import User
from app.models.secret_chat import SecretChat
from app.schemas.chat_schema import ChatResponse

router = APIRouter(prefix="/chats", tags=["Chats"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/start", response_model=ChatResponse)
def start_chat(identifier: str, current_user_id: int, db: Session = Depends(get_db)):
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



    # create secret chat
    new_chat = SecretChat(user1_id=current_user_id, user2_id=other_user.id)
    db.add(new_chat)
    db.commit()
    db.refresh(new_chat)

    return {
        "chat_id": new_chat.id,
        "with_user": other_user.username   # show username, not phone
    }

@router.get("/", response_model=list[GroupResponse])
def get_chats(db: Session = Depends(get_db)):
    return db.query(Chat).all()

