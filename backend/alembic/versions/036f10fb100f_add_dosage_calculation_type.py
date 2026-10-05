"""add dosage calculation type

Revision ID: 036f10fb100f
Revises: 90ae4e296265
Create Date: 2026-09-30 10:30:15.276429
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "036f10fb100f"
down_revision: Union[str, Sequence[str], None] = "90ae4e296265"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


dosage_calculation_type_enum = sa.Enum(
    "WATER_CONCENTRATION",
    "BODY_WEIGHT",
    "FIXED",
    "NOT_APPLICABLE",
    name="dosage_calculation_type",
)


def upgrade() -> None:
    # 1. Create the PostgreSQL enum type.
    dosage_calculation_type_enum.create(
        op.get_bind(),
        checkfirst=True,
    )

    # 2. Add the new column as nullable temporarily.
    op.add_column(
        "medication_guidance",
        sa.Column(
            "dosage_calculation_type",
            dosage_calculation_type_enum,
            nullable=True,
        ),
    )

    # 3. Existing medication records are safe by default.
    op.execute(
        """
        UPDATE medication_guidance
        SET dosage_calculation_type = 'NOT_APPLICABLE'
        """
    )

    # 4. Our existing Amprolium products use drinking-water concentration.
    op.execute(
        """
        UPDATE medication_guidance
        SET dosage_calculation_type = 'WATER_CONCENTRATION'
        WHERE disease = 'COCCIDIOSIS'
          AND active_ingredient = 'Amprolium'
        """
    )

    # 5. Now every existing row has a value, make the column required.
    op.alter_column(
        "medication_guidance",
        "dosage_calculation_type",
        existing_type=dosage_calculation_type_enum,
        nullable=False,
    )


def downgrade() -> None:
    op.drop_column(
        "medication_guidance",
        "dosage_calculation_type",
    )

    dosage_calculation_type_enum.drop(
        op.get_bind(),
        checkfirst=True,
    )