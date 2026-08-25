from fastapi import FastAPI, HTTPException
from sqlalchemy.exc import SQLAlchemyError
from app.routers import broadcast
from app.database import Base, engine
from app.routers import auth, users, chats, messages, groups, media, privacy, secret_chat, realtime, admin, call_ws, broadcast, calls, group_calls, compat
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path

# Initialize FastAPI app
app = FastAPI(title="J_ME Backend", version="1.0.0")

# Serve static files (module-relative)
STATIC_DIR = Path(__file__).resolve().parent / "static"
if STATIC_DIR.exists():
    app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

# Favicon route
@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    favicon_path = STATIC_DIR / "favicon.ico"
    if favicon_path.exists():
        return FileResponse(str(favicon_path))
    raise HTTPException(status_code=404, detail="Favicon not found")

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
app.include_router(admin.router)
app.include_router(broadcast.router, prefix="/broadcasts", tags=["Broadcasts"])
app.include_router(call_ws.router)
app.include_router(calls.router)
app.include_router(group_calls.router)
app.include_router(compat.router)

@app.get("/")
def home():
    return {"message": "J_ME Backend Running Successfully"}

