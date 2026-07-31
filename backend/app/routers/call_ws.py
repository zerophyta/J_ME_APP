from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import Dict, List

router = APIRouter(prefix="/ws", tags=["signaling"])

# simple in-memory store ya active connections
active_connections: Dict[int, WebSocket] = {}

@router.websocket("/ws/call/{user_id}")
async def call_ws(websocket: WebSocket, user_id: int):
    await websocket.accept()
    active_connections[user_id] = websocket

    try:
        while True:
            data = await websocket.receive_json()

            # data format: {"type": "offer/answer/candidate", "to": <user_id>, "payload": {...}}
            msg_type = data.get("type")
            target_id = data.get("to")
            payload = data.get("payload")

            if target_id in active_connections:
                await active_connections[target_id].send_json({
                    "from": user_id,
                    "type": msg_type,
                    "payload": payload
                })
            else:
                await websocket.send_json({"error": f"User {target_id} not connected"})

    except WebSocketDisconnect:
        del active_connections[user_id]

