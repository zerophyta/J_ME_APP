from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import SessionLocal
from app.models.group_call import GroupCallSession
from app.models.chat_member import ChatMember
from app.schemas.group_call_schema import GroupCallCreate, GroupCallResponse

router = APIRouter(prefix="/group_calls", tags=["group_calls"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/start", response_model=GroupCallResponse)
def start_group_call(request: GroupCallCreate, db: Session = Depends(get_db)):
    # check kama caller yupo kwenye group
    member = db.query(ChatMember).filter(
        ChatMember.chat_id == request.chat_id,
        ChatMember.user_id == request.caller_id
    ).first()
    if not member:
        raise HTTPException(status_code=400, detail="Caller not in group")

    call = GroupCallSession(
        caller_id=request.caller_id,
        chat_id=request.chat_id,
        call_type=request.call_type,
        status="initiated",
        started_at=datetime.utcnow()
    )
    db.add(call)
    db.commit()
    db.refresh(call)
    return call

@router.post("/{call_id}/join")
def join_group_call(call_id: int, user_id: int, db: Session = Depends(get_db)):
    call = db.query(GroupCallSession).filter(GroupCallSession.id == call_id).first()
    if not call:
        raise HTTPException(status_code=404, detail="Group call not found")

    member = db.query(ChatMember).filter(
        ChatMember.chat_id == call.chat_id,
        ChatMember.user_id == user_id
    ).first()
    if not member:
        raise HTTPException(status_code=400, detail="User not in group")

    return {"status": "success", "message": f"User {user_id} joined group call {call_id}"}

@router.post("/{call_id}/leave")
def leave_group_call(call_id: int, user_id: int, db: Session = Depends(get_db)):
    call = db.query(GroupCallSession).filter(GroupCallSession.id == call_id).first()
    if not call:
        raise HTTPException(status_code=404, detail="Group call not found")

    return {"status": "success", "message": f"User {user_id} left group call {call_id}"}

@router.post("/{call_id}/end", response_model=GroupCallResponse)
def end_group_call(call_id: int, user_id: int, db: Session = Depends(get_db)):
    call = db.query(GroupCallSession).filter(GroupCallSession.id == call_id).first()
    if not call:
        raise HTTPException(status_code=404, detail="Group call not found")

    if call.caller_id != user_id:
        raise HTTPException(status_code=403, detail="Only caller can end group call")

    call.status = "ended"
    call.ended_at = datetime.utcnow()
    db.commit()
    db.refresh(call)
    return call

