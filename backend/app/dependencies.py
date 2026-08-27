from fastapi import Depends


def user_scope(user_id: int) -> int:
    return user_id


USER_SCOPE = [Depends(user_scope)]
