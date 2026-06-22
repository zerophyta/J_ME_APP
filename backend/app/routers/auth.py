from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.utils.password_hash import verify_password
from app.utils.jwt_handler import create_token
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Auth"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/login")
def login(email: str, password: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.password):
        return {"success": False, "message": "Invalid credentials"}

    token = create_token({"id": user.id, "email": user.email})
    return {"success": True, "token": token}

