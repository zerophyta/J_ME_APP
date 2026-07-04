from fastapi import FastAPI
from sqlalchemy.exc import SQLAlchemyError

from app.database import Base, engine
from app.routers import auth, users, chats, messages, groups, media, privacy, secret_chat, realtime, admin
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

# Create database tables
try:
    Base.metadata.create_all(bind=engine)
except SQLAlchemyError:
    pass

# Initialize FastAPI app
app = FastAPI(title="J_ME Backend", version="1.0.0")

# Serve static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Favicon route
@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return FileResponse("app/static/favicon.ico")

# Register routers
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(users.router)
app.include_router(chats.router)
app.include_router(messages.router)
app.include_router(groups.router)
app.include_router(media.router)
app.include_router(privacy.router)
app.include_router(secret_chat.router)
app.include_router(realtime.router)
app.include_router(admin.router)

@app.get("/")
def home():
    return {"message": "J_ME Backend Running Successfully"}

