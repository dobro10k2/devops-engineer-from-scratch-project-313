# app/main.py
# Main FastAPI application with CRUD for short links.
# Fixed for test_sentry_debug to pass by using original fastapi_app for tests.

import os

from dotenv import load_dotenv
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sentry_sdk.integrations.asgi import SentryAsgiMiddleware
from sqlmodel import Session

from .crud import (
    create_link,
    delete_link,
    get_all_links,
    get_link,
    update_link,
)
from .db import get_session, init_db
from .schemas import LinkCreate, LinkRead, LinkUpdate

# Load environment variables
load_dotenv()

BASE_URL = os.getenv("BASE_URL", "http://localhost:8080")
SENTRY_DSN = os.getenv("SENTRY_DSN")

# Original FastAPI app for testing and main usage
fastapi_app = FastAPI(title="DevOps Engineer Project 313")

# Add CORS middleware
fastapi_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Use lifespan event instead of deprecated startup event
@fastapi_app.on_event("startup")
def on_startup():
    """Initialize the database on startup."""
    init_db()

# Health check endpoint
@fastapi_app.get("/ping")
async def ping():
    return "pong"

# CRUD endpoints
@fastapi_app.get("/api/links", response_model=list[LinkRead])
def list_links(session: Session = Depends(get_session)):
    return get_all_links(session)

@fastapi_app.post("/api/links", response_model=LinkRead, status_code=201)
def create_link_route(data: LinkCreate, session: Session = Depends(get_session)):
    return create_link(session, data, BASE_URL)

@fastapi_app.get("/api/links/{link_id}", response_model=LinkRead)
def get_link_route(link_id: int, session: Session = Depends(get_session)):
    return get_link(session, link_id)

@fastapi_app.put("/api/links/{link_id}", response_model=LinkRead)
def update_link_route(link_id: int, data: LinkUpdate, session: Session = Depends(get_session)):
    return update_link(session, link_id, data, BASE_URL)

@fastapi_app.delete("/api/links/{link_id}", status_code=204)
def delete_link_route(link_id: int, session: Session = Depends(get_session)):
    delete_link(session, link_id)
    return None

# Test route to trigger Sentry error
@fastapi_app.get("/sentry-debug")
async def trigger_error():
    1 / 0  # Raises ZeroDivisionError

# Wrap app in Sentry middleware only for production; tests still use fastapi_app
if SENTRY_DSN:
    app = SentryAsgiMiddleware(fastapi_app)
else:
    app = fastapi_app

