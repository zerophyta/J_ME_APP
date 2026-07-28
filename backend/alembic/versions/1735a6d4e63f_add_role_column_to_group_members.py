"""add role column to group_members

Revision ID: 1735a6d4e63f
Revises: 0319b75018fe
Create Date: 2026-07-28 17:55:08.758152

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '1735a6d4e63f'
down_revision: Union[str, Sequence[str], None] = '0319b75018fe'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade():
    # hapa unaongeza column mpya
    op.add_column(
        'group_members',
        sa.Column('role', sa.String(), nullable=False, default='member')
    )

def downgrade():
    # hapa unaondoa column kama ukirudisha migration nyuma
    op.drop_column('group_members', 'role')

