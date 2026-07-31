from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import Broadcast, BroadcastRecipient, User, ChatMember
from app.schemas import BroadcastRequest
from app.models.chat import Chat
from app.models.secret_chat import SecretChat

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/broadcast")
def send_broadcast(request: BroadcastRequest, db: Session = Depends(get_db)):
    # check kama sender yupo
    sender = db.query(User).filter(User.id == request.sender_id).first()
    if not sender:
        raise HTTPException(status_code=404, detail="Sender not found")

    # check kama recipients wote wapo
    recipients = db.query(User).filter(User.id.in_(request.recipient_ids)).all()
    if len(recipients) != len(request.recipient_ids):
        raise HTTPException(status_code=400, detail="One or more recipients not found")

    # check kama recipients wako kwenye chat moja na sender (group OR normal OR secret)
    for rid in request.recipient_ids:
        in_group = db.query(ChatMember).filter(
            ChatMember.user_id == sender.id,
            ChatMember.chat_id == ChatMember.chat_id,
            ChatMember.user_id == rid
        ).first()

        in_normal = db.query(Chat).filter(
            ((Chat.user1_id == sender.id) & (Chat.user2_id == rid)) |
            ((Chat.user2_id == sender.id) & (Chat.user1_id == rid))
        ).first()

        in_secret = db.query(SecretChat).filter(
            ((SecretChat.user1_id == sender.id) & (SecretChat.user2_id == rid)) |
            ((SecretChat.user2_id == sender.id) & (SecretChat.user1_id == rid))
        ).first()

        if not (in_group or in_normal or in_secret):
            raise HTTPException(status_code=400, detail=f"Recipient {rid} not in same chat/secret_chat with sender")

    # create broadcast
    broadcast = Broadcast(sender_id=request.sender_id, content=request.content)
    db.add(broadcast)
    db.commit()
    db.refresh(broadcast)

    # add recipients
    for rid in request.recipient_ids:
        br = BroadcastRecipient(broadcast_id=broadcast.id, recipient_id=rid)
        db.add(br)

    db.commit()

    return {
        "status": "success",
        "message": f"Broadcast sent to {len(request.recipient_ids)} users",
        "broadcast_id": broadcast.id,
        "content": broadcast.content,
        "sender": {
            "id": sender.id,
            "username": sender.username
        },
        "recipients": [{"id": r.id, "username": r.username} for r in recipients]
    }
