from datetime import datetime
from typing import Any, Dict, List

from fastapi import APIRouter, HTTPException

router = APIRouter(tags=["Compatibility"])

_secret_chats: Dict[int, Dict[str, Any]] = {}
_secret_messages: Dict[int, List[Dict[str, Any]]] = {}
_privacy: Dict[int, Dict[str, str]] = {}
_statuses: List[Dict[str, Any]] = [
    {"id": 1, "user": "You", "content": "Hello world", "isMine": True},
    {"id": 2, "user": "Alice", "content": "Checking in", "isMine": False},
]
_status_viewers: Dict[int, List[Dict[str, Any]]] = {
    1: [{
        "id": 1,
        "name": "Alice",
        "username": "alice",
        "avatar": "https://placehold.co/100x100/png",
        "viewedAt": "2026-08-25T12:00:00Z",
    }],
    2: [{
        "id": 2,
        "name": "Ben",
        "username": "ben",
        "avatar": "https://placehold.co/100x100/png",
        "viewedAt": "2026-08-25T12:10:00Z",
    }],
}
_storage: Dict[str, Any] = {"used_bytes": 0, "total_bytes": 1073741824, "percent_used": 0}
_settings: Dict[str, Any] = {}
_appearance: Dict[str, Any] = {}
_account_security: Dict[str, Any] = {"two_factor": False, "pin_lock": False, "fingerprint": False}
_login_history: List[Dict[str, Any]] = [{"id": 1, "device": "web", "time": "2026-08-25T12:00:00Z"}]
_devices: List[Dict[str, Any]] = [{"id": 1, "name": "Current Device", "last_seen": "2026-08-25T12:00:00Z"}]
_thread_replies: Dict[int, Dict[int, List[Dict[str, Any]]]] = {}


@router.post("/secret_chat/")
def create_secret_chat(payload: Dict[str, Any]):
    user1_id = payload.get("user1_id")
    user2_id = payload.get("user2_id")
    if user1_id is None or user2_id is None:
        raise HTTPException(status_code=400, detail="user1_id and user2_id are required")
    chat_id = max(_secret_chats.keys(), default=0) + 1
    record = {
        "id": chat_id,
        "user1_id": int(user1_id),
        "user2_id": int(user2_id),
        "encryption_key": payload.get("encryption_key", "generated_key"),
        "created_at": datetime.utcnow().isoformat(),
    }
    _secret_chats[chat_id] = record
    _secret_messages.setdefault(chat_id, [])
    return record


@router.get("/secret_chat/secret")
def get_secret_chats():
    return list(_secret_chats.values())


@router.post("/secret_chat/send")
def send_secret_message(payload: Dict[str, Any]):
    chat_id = payload.get("chat_id")
    user_id = payload.get("user_id")
    content = payload.get("content")
    if chat_id is None or user_id is None or content is None:
        raise HTTPException(status_code=400, detail="chat_id, user_id and content are required")
    chat_id = int(chat_id)
    message = {
        "id": len(_secret_messages.get(chat_id, [])) + 1,
        "chat_id": chat_id,
        "user_id": int(user_id),
        "content": str(content),
        "self_destruct": int(payload.get("self_destruct", 0)),
        "created_at": datetime.utcnow().isoformat(),
    }
    _secret_messages.setdefault(chat_id, []).append(message)
    return {"status": "success", "message": message}


@router.post("/secret_chat/timer")
def set_secret_timer(payload: Dict[str, Any]):
    chat_id = payload.get("chat_id")
    seconds = payload.get("self_destruct")
    if chat_id is None or seconds is None:
        raise HTTPException(status_code=400, detail="chat_id and self_destruct are required")
    chat_id = int(chat_id)
    if chat_id in _secret_chats:
        _secret_chats[chat_id]["self_destruct"] = int(seconds)
    return {"status": "success", "chat_id": chat_id, "self_destruct": int(seconds)}


@router.post("/privacy/")
def set_privacy(payload: Dict[str, Any]):
    user_id = payload.get("user_id")
    setting = payload.get("setting")
    value = payload.get("value")
    if user_id is None or setting is None or value is None:
        raise HTTPException(status_code=400, detail="user_id, setting and value are required")
    user_id = int(user_id)
    _privacy.setdefault(user_id, {})[str(setting)] = str(value)
    return {"id": user_id, "user_id": user_id, "setting": str(setting), "value": str(value)}


@router.post("/privacy/update")
def update_privacy(payload: Dict[str, Any]):
    return {"status": "success", **payload}


@router.get("/privacy/advanced")
def get_advanced_privacy():
    return {
        "forwarding": False,
        "screenshots": False,
        "secret_chats": False,
    }


@router.post("/privacy/advanced/update")
def set_advanced_privacy(payload: Dict[str, Any]):
    return {"status": "success", **payload}


@router.post("/privacy/unblock/{user_id}")
def unblock_user(user_id: int):
    return {"status": "success", "user_id": user_id}


@router.get("/status")
def get_statuses():
    return _statuses


@router.post("/status/upload", status_code=201)
def upload_status(payload: Dict[str, Any]):
    content = payload.get("content", "")
    status = {
        "id": max((s["id"] for s in _statuses), default=0) + 1,
        "user": "You",
        "content": str(content),
        "isMine": True,
    }
    _statuses.insert(0, status)
    _status_viewers.setdefault(status["id"], [])
    return {"status": "uploaded", **status}


@router.get("/status/{status_id}/viewers")
def get_status_viewers(status_id: int):
    viewers = _status_viewers.get(status_id, [])
    return viewers


@router.get("/status/archive")
def get_archived_statuses():
    return []


@router.get("/storage/usage")
def get_storage_usage():
    return _storage


@router.post("/storage/clear")
def clear_storage():
    _storage["used_bytes"] = 0
    _storage["percent_used"] = 0
    return {"status": "success"}


@router.post("/storage/auto_download")
def set_auto_download(payload: Dict[str, Any]):
    value = bool(payload.get("auto_download", False))
    _storage["auto_download"] = value
    return {"status": "success", "auto_download": value}


@router.post("/chat/backup")
def backup_chats():
    return {"status": "success", "message": "Chats backed up successfully"}


@router.post("/chat/restore")
def restore_chats():
    return {"status": "success", "message": "Chats restored successfully"}


@router.post("/chat/auto_backup")
def set_auto_backup(payload: Dict[str, Any]):
    value = bool(payload.get("auto_backup", False))
    _settings["auto_backup"] = value
    return {"status": "success", "auto_backup": value}


@router.post("/chat/export")
def export_chat(payload: Dict[str, Any]):
    return {"status": "success", "download_url": "/downloads/chat-export.zip", **payload}


@router.get("/chat/{chat_id}/info")
def get_chat_info(chat_id: int):
    return {"id": chat_id, "name": f"Chat {chat_id}", "participants": [], "created_at": "2026-01-01T00:00:00"}


@router.post("/chat/{chat_id}/mute")
def set_chat_mute(chat_id: int, payload: Dict[str, Any]):
    return {"status": "success", "chat_id": chat_id, "muted": bool(payload.get("muted", False))}


@router.post("/chat/{chat_id}/security")
def set_chat_security(chat_id: int, payload: Dict[str, Any]):
    return {
        "status": "success",
        "chat_id": chat_id,
        "pin_lock": bool(payload.get("pin_lock", False)),
        "fingerprint_unlock": bool(payload.get("fingerprint_unlock", False)),
        "two_factor_auth": bool(payload.get("two_factor_auth", False)),
    }


@router.get("/devices/active")
def get_active_devices():
    return _devices


@router.post("/devices/{device_id}/revoke")
def revoke_device(device_id: int):
    _devices = [d for d in _devices if d.get("id") != device_id]
    return {"status": "success", "device_id": device_id}


@router.get("/account/security")
def get_account_security():
    return _account_security


@router.post("/account/two_factor")
def set_two_factor(payload: Dict[str, Any]):
    value = bool(payload.get("two_factor", False))
    _account_security["two_factor"] = value
    return {"status": "success", "two_factor": value}


@router.post("/account/revoke_devices")
def revoke_all_devices():
    _devices.clear()
    return {"status": "success"}


@router.get("/account/login_history")
def get_login_history():
    return _login_history


@router.post("/settings/update")
def set_settings(payload: Dict[str, Any]):
    _settings.update(payload)
    return {"status": "success", **payload}


@router.post("/appearance/update")
def set_appearance(payload: Dict[str, Any]):
    _appearance.update(payload)
    return {"status": "success", **payload}


@router.post("/chat/view_once")
def send_view_once(payload: Dict[str, Any]):
    return {"status": "success", "message": "View-once media sent", **payload}


@router.post("/chat/{chat_id}/disappearing")
def set_disappearing_messages(chat_id: int, payload: Dict[str, Any]):
    return {"status": "success", "chat_id": chat_id, "duration": int(payload.get("duration", 0))}


@router.post("/chat/{chat_id}/message/{message_id}/edit")
def edit_message(chat_id: int, message_id: int, payload: Dict[str, Any]):
    return {"status": "success", "chat_id": chat_id, "message_id": message_id, "new_text": payload.get("new_text", "")}


@router.post("/chat/{chat_id}/message/{message_id}/delete_for_me")
def delete_message_for_me(chat_id: int, message_id: int):
    return {"status": "success", "chat_id": chat_id, "message_id": message_id, "for": "me"}


@router.post("/chat/{chat_id}/message/{message_id}/delete_for_everyone")
def delete_message_for_everyone(chat_id: int, message_id: int):
    return {"status": "success", "chat_id": chat_id, "message_id": message_id, "for": "everyone"}


@router.post("/chat/{chat_id}/message/{message_id}/reaction")
def add_reaction(chat_id: int, message_id: int, payload: Dict[str, Any]):
    return {"status": "success", "chat_id": chat_id, "message_id": message_id, "reaction": payload.get("reaction", "")}


@router.post("/chat/{chat_id}/message/{message_id}/reaction/remove")
def remove_reaction(chat_id: int, message_id: int, payload: Dict[str, Any]):
    return {"status": "success", "chat_id": chat_id, "message_id": message_id, "reaction": payload.get("reaction", "")}


@router.post("/chat/{chat_id}/thread/reply")
def send_thread_reply(chat_id: int, payload: Dict[str, Any]):
    parent_id = payload.get("parent_id")
    if parent_id is None:
        raise HTTPException(status_code=400, detail="parent_id is required")

    parent_id_int = int(parent_id)
    replies = _thread_replies.setdefault(chat_id, {}).setdefault(parent_id_int, [])
    message = {
        "id": len(replies) + 1,
        "chat_id": chat_id,
        "parent_id": parent_id_int,
        "text": payload.get("text", ""),
        "created_at": datetime.utcnow().isoformat(),
    }
    replies.append(message)
    return {"status": "success", "message": message}


@router.get("/chat/{chat_id}/thread/{parent_id}")
def get_thread_replies(chat_id: int, parent_id: int):
    return _thread_replies.get(chat_id, {}).get(parent_id, [])
