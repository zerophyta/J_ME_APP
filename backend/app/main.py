from fastapi import FastAPI
from app.routers import auth, users, chats, messages, groups, media, search, privacy, secret_chat
from app.database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI(title="J_ME Backend")

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(chats.router)
app.include_router(messages.router)
app.include_router(groups.router)
app.include_router(media.router)
app.include_router(search.router)
app.include_router(privacy.router)
app.include_router(secret_chat.router)

@app.get("/")
def home():
    return {"message": "J_ME Backend Running"}

