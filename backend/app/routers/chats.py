from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.chat import Chat
from app.models.secret_chat import SecretChat
from app.models.user import User
from app.schemas.chat_schema import ChatResponse
from app.schemas.secret_chat_schema import SecretChatResponse
from app.dependencies import USER_SCOPE

router = APIRouter(prefix="/user/{user_id}/chats", tags=["Chats"], dependencies=USER_SCOPE)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Normal chat
@router.post("/start", response_model=ChatResponse)
def start_chat(identifier: str, current_user_id: int, db: Session = Depends(get_db)):
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

    existing_chat = db.query(Chat).filter(
    ((Chat.user1_id == current_user_id) & (Chat.user2_id == other_user.id)) |
    ((Chat.user1_id == other_user.id) & (Chat.user2_id == current_user_id))
       ).first()

    if existing_chat:
        return existing_chat  # Rudisha ile iliyopo badala ya kuunda mpya
    
    
    
    # create normal chat
    new_chat = Chat(user1_id=current_user_id, user2_id=other_user.id)
    db.add(new_chat)
    db.commit()
    db.refresh(new_chat)
    return new_chat



# Get all normal chats
@router.get("/", response_model=list[ChatResponse])
def get_chats(db: Session = Depends(get_db)):
    return db.query(Chat).all()

