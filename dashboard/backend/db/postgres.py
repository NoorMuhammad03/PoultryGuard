# Database connection — async SQLAlchemy session.
# Uses DATABASE_URL from environment (.env).

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from typing import Generator
import os
from dotenv import load_dotenv

# Import the model package so all tables register on Base.metadata
# (needed by Alembic autogenerate).
from models import Base

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL not set in environment")

# For SQLite (dev) use connect_args; for PostgreSQL use standard pool.
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency yielding a database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()