from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import Broadcast, BroadcastRecipient, User, ChatMember
from app.schemas import BroadcastRequest

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

    # check kama wote wako kwenye chat moja
    # chukua chat_ids ambazo sender yupo
    sender_chats = db.query(ChatMember.chat_id).filter(ChatMember.user_id == sender.id).all()
    sender_chat_ids = [c.chat_id for c in sender_chats]

    if not sender_chat_ids:
        raise HTTPException(status_code=400, detail="Sender is not in any chat")

    # kwa kila recipient, lazima awe kwenye moja ya chat_ids za sender
    for rid in request.recipient_ids:
        exists = db.query(ChatMember).filter(
            ChatMember.user_id == rid,
            ChatMember.chat_id.in_(sender_chat_ids)
        ).first()
        if not exists:
            raise HTTPException(status_code=400, detail=f"Recipient {rid} not in same chat with sender")

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
        "broadcast_id": broadcast.id
    }

