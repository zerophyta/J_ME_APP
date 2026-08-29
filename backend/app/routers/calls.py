from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import SessionLocal
from app.models.call import CallSession
from app.schemas.call_schema import CallSessionCreate, CallSessionResponse

router = APIRouter(prefix="/user/{user_id}/chats/{chat_id}/calls", tags=["calls"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Start a call
@router.post("/start", response_model=CallSessionResponse)
def start_call(request: CallSessionCreate, db: Session = Depends(get_db)):
    call = CallSession(
        caller_id=request.caller_id,
        callee_id=request.callee_id,
        call_type=request.call_type,
        status="initiated",
        started_at=datetime.timezone.utc()
    )
    db.add(call)
    db.commit()
    db.refresh(call)
    return call

# End a call
@router.post("/{call_id}/end", response_model=CallSessionResponse)
def end_call(call_id: int, db: Session = Depends(get_db)):
    call = db.query(CallSession).filter(CallSession.id == call_id).first()
    if not call:
        raise HTTPException(status_code=404, detail="Call not found")
    call.status = "ended"
    call.ended_at = datetime.utcnow()
    db.commit()
    db.refresh(call)
    return call

# Get call history for a user
@router.get("/history/{user_id}", response_model=list[CallSessionResponse])
def get_call_history(user_id: int, db: Session = Depends(get_db)):
    calls = db.query(CallSession).filter(
        (CallSession.caller_id == user_id) | (CallSession.callee_id == user_id)
    ).order_by(CallSession.started_at.desc()).all()
    return calls

