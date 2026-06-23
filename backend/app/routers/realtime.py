from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from app.websocket_manager import manager

router = APIRouter(prefix="/ws", tags=["Realtime"])

@router.websocket("/connect")
async def websocket_endpoint(websocket: WebSocket, user_id: int = Query(...)):
    await manager.connect(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            # Echo back for now
            await websocket.send_json({"type": "echo", "data": data})
    except WebSocketDisconnect:
        manager.disconnect(user_id, websocket)

@router.websocket("/connect")
async def websocket_endpoint(websocket: WebSocket, user_id: int = Query(...)):
    await manager.connect(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            if data["type"] == "typing":
                await manager.broadcast_to_users(data["group_members"], data)
            elif data["type"] == "group:new_message":
                await manager.broadcast_to_users(data["group_members"], data)
            else:
                await websocket.send_json({"type": "echo", "data": data})
    except WebSocketDisconnect:
        manager.disconnect(user_id, websocket)
