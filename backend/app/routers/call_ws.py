from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.chat import Chat

router = APIRouter(prefix="/user/{user_id}/chats/{chat_id}/calls", tags=["Calls"])

active_connections: dict[int, WebSocket] = {}

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.websocket("/ws")
async def call_ws(websocket: WebSocket, user_id: int, chat_id: int, db: Session = Depends(get_db)):
    # validate chat exists and user is participant
    chat = db.query(Chat).filter(Chat.id == chat_id).first()
    if not chat:
        await websocket.close(code=4000)
        raise HTTPException(status_code=404, detail="Chat not found")

    await websocket.accept()
    active_connections[user_id] = websocket

    try:
        while True:
            data = await websocket.receive_json()
            msg_type = data.get("type")
            target_id = data.get("to")
            payload = data.get("payload")

            if target_id in active_connections:
                await active_connections[target_id].send_json({
                    "from": user_id,
                    "chat_id": chat_id,
                    "type": msg_type,
                    "payload": payload
                })
            else:
                await websocket.send_json({"error": f"User {target_id} not connected"})
    except WebSocketDisconnect:
        del active_connections[user_id]
