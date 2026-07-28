"""add created_at to secret_chats

Revision ID: 887b7820da54
Revises: b570e6da156d
Create Date: 2026-07-24 08:13:09.906157

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '887b7820da54'
down_revision: Union[str, Sequence[str], None] = 'b570e6da156d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
