from typing import Dict, List
from fastapi import WebSocket

class WebSocketManager:
    def __init__(self):
        self.active_connections = {}

    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    async def disconnect(self, user_id: str):
        self.active_connections.pop(user_id, None)

    async def send_message(self, user_id: str, message: dict):
        if user_id in self.active_connections:
            await self.active_connections[user_id].send_json(message)

manager = WebSocketManager()

class ConnectionManager:
    def __init__(self):
        # key: user_id, value: list of WebSocket connections
        self.active_connections: Dict[int, List[WebSocket]] = {}

    async def connect(self, user_id: int, websocket: WebSocket):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)

    def disconnect(self, user_id: int, websocket: WebSocket):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def send_personal_message(self, user_id: int, message: dict):
        if user_id in self.active_connections:
            for ws in self.active_connections[user_id]:
                await ws.send_json(message)

    async def broadcast_to_users(self, user_ids: list[int], message: dict):
        for uid in user_ids:
            await self.send_personal_message(uid, message)

async def broadcast_typing(chat_id: int, sender_id: int):
    message = {"type": "typing", "chat_id": chat_id, "sender_id": sender_id}
    # broadcast kwa wote waliopo kwenye chat hiyo
    await manager.broadcast_to_users([sender_id], message)

manager = ConnectionManager()
