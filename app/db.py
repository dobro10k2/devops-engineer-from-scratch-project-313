# app/db.py
# Database initialization for SQLModel with support for PostgreSQL and SQLite.

import os

from dotenv import load_dotenv
from sqlmodel import Session, SQLModel, create_engine

# Load environment variables
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")

# For SQLite we need check_same_thread
connect_args = {}
if DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(DATABASE_URL, connect_args=connect_args)


def init_db() -> None:
    """Create all tables on startup."""
    SQLModel.metadata.create_all(engine)


def get_session():
    """Provide a database session."""
    with Session(engine) as session:
        yield session

