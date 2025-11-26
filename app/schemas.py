# app/schemas.py
# Pydantic schemas for request/response.

from datetime import datetime

from pydantic import BaseModel


class LinkCreate(BaseModel):
    original_url: str
    short_name: str


class LinkUpdate(BaseModel):
    original_url: str
    short_name: str


class LinkRead(BaseModel):
    id: int
    original_url: str
    short_name: str
    short_url: str
    created_at: datetime

    class Config:
        from_attributes = True

