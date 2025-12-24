# app/db.py
import os

from sqlmodel import Session, SQLModel, create_engine

DATABASE_URL = os.getenv("DATABASE_URL").replace("postgres:", "postgresql:")

# PostgreSQL engine using psycopg2-binary
engine = create_engine(DATABASE_URL, echo=True)

def init_db():
    """Create database tables"""
    SQLModel.metadata.create_all(engine)

def get_session():
    """Provide a session for CRUD operations"""
    with Session(engine) as session:
        yield session
