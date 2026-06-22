from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.secret_chat import SecretChat
from app.schemas.secret_chat_schema import SecretChatCreate, SecretChatResponse

router = APIRouter(prefix="/secret_chat", tags=["SecretChat"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=SecretChatResponse)
def create_secret_chat(secret: SecretChatCreate, db: Session = Depends(get_db)):
    new_secret = SecretChat(
        user1_id=secret.user1_id,
        user2_id=secret.user2_id,
        encryption_key=secret.encryption_key
    )
    db.add(new_secret)
    db.commit()
    db.refresh(new_secret)
    return new_secret

