# app/main.py
# Main FastAPI application with CRUD for short links.

import json
import os

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Query, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from sentry_sdk.integrations.asgi import SentryAsgiMiddleware
from sqlmodel import Session

from .crud import (
    create_link,
    delete_link,
    get_link,
    get_links_paginated,
    update_link,
)
from .db import get_session, init_db
from .models import Link
from .schemas import LinkCreate, LinkRead, LinkUpdate

# Load environment variables
load_dotenv()

BASE_URL = os.getenv("BASE_URL", "http://localhost:8080")
SENTRY_DSN = os.getenv("SENTRY_DSN")

fastapi_app = FastAPI(title="DevOps Engineer Project 313")

fastapi_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@fastapi_app.on_event("startup")
def on_startup():
    """Initialize the database on startup."""
    init_db()


@fastapi_app.get("/ping")
async def ping():
    return "pong"


# CRUD endpoints with pagination
@fastapi_app.get("/api/links", response_model=list[LinkRead])
def list_links(
    response: Response,
    range: str = Query("[0,9]"),
    session: Session = Depends(get_session)
):
    """
    List links with pagination using range query parameter [start,end].
    Returns Content-Range header.
    """
    try:
        start, end = json.loads(range)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid range format")

    if start < 0 or end < start:
        raise HTTPException(status_code=400, detail="Invalid range values")

    limit = end - start + 1
    links, total = get_links_paginated(session, offset=start, limit=limit)
    response.headers["Content-Range"] = f"links {start}-{start+len(links)-1}/{total}"
    return links


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


@fastapi_app.get("/r/{short_name}")
def redirect_link(short_name: str, session: Session = Depends(get_session)):
    link = session.query(Link).filter(Link.short_name == short_name).first()
    if not link:
        raise HTTPException(status_code=404, detail="Not Found")
    return RedirectResponse(url=link.original_url)


@fastapi_app.get("/sentry-debug")
async def trigger_error():
    1 / 0


if SENTRY_DSN:
    app = SentryAsgiMiddleware(fastapi_app)
else:
    app = fastapi_app

