"""add created_at and not null to secret_chats

Revision ID: 3761b27de411
Revises: 887b7820da54
Create Date: 2026-07-24 16:09:43.728853

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '3761b27de411'
down_revision: Union[str, Sequence[str], None] = '887b7820da54'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ongeza column created_at na default NOW()
    op.add_column(
        "secret_chats",
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now())
    )

    # hakikisha user1_id na user2_id haziruhusu NULL
    op.alter_column("secret_chats", "user1_id", nullable=False)
    op.alter_column("secret_chats", "user2_id", nullable=False)

def downgrade() -> None:
    # rudisha hali ya awali
    op.drop_column("secret_chats", "created_at")
    op.alter_column("secret_chats", "user1_id", nullable=True)
    op.alter_column("secret_chats", "user2_id", nullable=True)

