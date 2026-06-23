from fastapi import FastAPI
from app.database import Base, engine
from app.routers import auth, users, chats, messages, groups, media, privacy, secret_chat

# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(title="J_ME Backend", version="1.0.0")

# Register routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(chats.router)
app.include_router(messages.router)
app.include_router(groups.router)
app.include_router(media.router)
app.include_router(privacy.router)
app.include_router(secret_chat.router)
app.include_router(realtime.router)

@app.get("/")
def home():
    return {"message": "J_ME Backend Running Successfully"}
