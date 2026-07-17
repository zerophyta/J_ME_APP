from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import SessionLocal
from app.models.message import Message

router = APIRouter(prefix="/ws", tags=["Realtime"])

# ---------------------------
# Connection Manager
# ---------------------------
class ConnectionManager:
    def __init__(self):
        self.chat_connections: dict[int, list[WebSocket]] = {}
        self.user_connections: dict[int, WebSocket] = {}

    async def connect_chat(self, chat_id: int, websocket: WebSocket):
        await websocket.accept()
        if chat_id not in self.chat_connections:
            self.chat_connections[chat_id] = []
        self.chat_connections[chat_id].append(websocket)

    async def connect_user(self, user_id: int, websocket: WebSocket):
        await websocket.accept()
        self.user_connections[user_id] = websocket

    def disconnect_chat(self, chat_id: int, websocket: WebSocket):
        self.chat_connections[chat_id].remove(websocket)
        if not self.chat_connections[chat_id]:
            del self.chat_connections[chat_id]

    def disconnect_user(self, user_id: int):
        if user_id in self.user_connections:
            del self.user_connections[user_id]

    async def broadcast_chat(self, chat_id: int, message: dict):
        if chat_id in self.chat_connections:
            for connection in self.chat_connections[chat_id]:
                await connection.send_json(message)

    async def send_to_user(self, user_id: int, message: dict):
        if user_id in self.user_connections:
            await self.user_connections[user_id].send_json(message)

manager = ConnectionManager()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ---------------------------
# Group Chat WebSocket
# ---------------------------
@router.websocket("/chat/{chat_id}")
async def chat_ws(websocket: WebSocket, chat_id: int, db: Session = Depends(get_db)):
    await manager.connect_chat(chat_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            new_msg = Message(
                chat_id=chat_id,
                sender_id=data["sender_id"],
                content=data["content"],
                timestamp=datetime.utcnow()
            )
            db.add(new_msg)
            db.commit()
            db.refresh(new_msg)

            await manager.broadcast_chat(chat_id, {
                "id": new_msg.id,
                "chat_id": chat_id,
                "sender_id": new_msg.sender_id,
                "content": new_msg.content,
                "timestamp": str(new_msg.timestamp)
            })
    except WebSocketDisconnect:
        manager.disconnect_chat(chat_id, websocket)

# ---------------------------
# Individual Chat WebSocket
# ---------------------------
@router.websocket("/user/{user_id}")
async def user_ws(websocket: WebSocket, user_id: int):
    await manager.connect_user(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            # data expected: {"receiver_id": 2, "content": "Hello"}
            await manager.send_to_user(data["receiver_id"], {
                "type": "direct_message",
                "sender_id": user_id,
                "content": data["content"],
                "timestamp": str(datetime.utcnow())
            })
    except WebSocketDisconnect:
        manager.disconnect_user(user_id)

