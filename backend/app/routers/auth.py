from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from pydantic import BaseModel

from app.schemas.user_schema import UserRegister   
from app.config import ADMIN_PASSWORD, ADMIN_USERNAME
from app.database import SessionLocal
from app.models.user import User
from app.utils.jwt_handler import create_token, decode_token
from app.utils.password_hash import verify_password
import re, shutil

router = APIRouter(prefix="/auth", tags=["Auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class LoginRequest(BaseModel):
    identifier: str
    password: str

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/login")
def login(credentials: LoginRequest, db: Session = Depends(get_db)):
    identifier = credentials.identifier
    password = credentials.password

    # check admin login
    if identifier == ADMIN_USERNAME and password == ADMIN_PASSWORD:
        token = create_token({"role": "admin", "email": identifier})
        return {"success": True, "token": token, "role": "admin"}

    # try email
    user = db.query(User).filter(User.email == identifier).first()

    # fallback to username
    if not user:
        user = db.query(User).filter(User.username == identifier).first()

    if not user or not verify_password(password, user.password):
        return {"success": False, "message": "Invalid credentials"}

    token = create_token({"id": user.id, "email": user.email, "role": "user"})
    return {"success": True, "token": token, "role": "user"}


@router.post("/register")
async def register(
    username: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    phone: str = Form(None),
    avatar: UploadFile = File(None),   # <-- avatar file
    db: Session = Depends(get_db)
):
    # check if email exists
    existing_user = db.query(User).filter(User.email == email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already exists")

    # check if phone exists
    if phone:
        existing_user = db.query(User).filter(User.phone == phone).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Phone number already registered")
        # validate phone format
        pattern = r"^\+255\d{9}$"
        if not re.match(pattern, phone):
            raise HTTPException(status_code=400, detail="Phone must be in format +255XXXXXXXXX")

    # hash password
    hashed_password = pwd_context.hash(password)

    # handle avatar file
    avatar_url = None
    if avatar:
        file_path = f"uploads/avatars/{avatar.filename}"
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(avatar.file, buffer)
        avatar_url = file_path  # or serve via static URL

    # create new user
    new_user = User(
        username=username,
        email=email,
        phone=phone,
        password=hashed_password,
        avatar=avatar_url   # <-- save avatar path/url in DB
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "User registered successfully",
        "id": new_user.id,
        "avatar_url": avatar_url
    }
