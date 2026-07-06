from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from app.config import ADMIN_PASSWORD, ADMIN_USERNAME
from app.database import SessionLocal
from app.models.user import User
from app.utils.jwt_handler import create_token, decode_token
from app.utils.password_hash import verify_password

router = APIRouter(prefix="/auth", tags=["Auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class UserRegister(BaseModel):
    username: str
    email: EmailStr
    password: str


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/login")
def login(email: str, password: str, db: Session = Depends(get_db)):
    if email == ADMIN_USERNAME and password == ADMIN_PASSWORD:
        token = create_token({"role": "admin", "email": email})
        return {"success": True, "token": token, "role": "admin"}

    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.password):
        return {"success": False, "message": "Invalid credentials"}

    token = create_token({"id": user.id, "email": user.email, "role": "user"})
    return {"success": True, "token": token, "role": "user"}


@router.post("/register")
async def register(user: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already exists")

    hashed_password = pwd_context.hash(user.password)
    new_user = User(username=user.username, email=user.email, password=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "User registered successfully", "id": new_user.id}

