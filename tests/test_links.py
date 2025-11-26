# tests/test_links.py
# CRUD tests using SQLite in-memory database.

import os

import pytest
from fastapi.testclient import TestClient
from sqlmodel import SQLModel

# Override DB for tests
os.environ["DATABASE_URL"] = "sqlite:///./test.db"
os.environ["BASE_URL"] = "http://testserver"

from app.db import engine
from app.main import fastapi_app

client = TestClient(fastapi_app)


@pytest.fixture(autouse=True)
def prepare_db():
    SQLModel.metadata.drop_all(engine)
    SQLModel.metadata.create_all(engine)
    yield


def test_create_link():
    payload = {
        "original_url": "https://example.com",
        "short_name": "abc123"
    }
    r = client.post("/api/links", json=payload)
    assert r.status_code == 201
    data = r.json()
    assert data["short_url"] == "http://testserver/r/abc123"


def test_get_link():
    payload = {
        "original_url": "https://ex.com",
        "short_name": "zzz"
    }
    created = client.post("/api/links", json=payload).json()

    r = client.get(f"/api/links/{created['id']}")
    assert r.status_code == 200
    assert r.json()["short_name"] == "zzz"


def test_update_link():
    created = client.post("/api/links", json={
        "original_url": "https://orig.com",
        "short_name": "old"
    }).json()

    r = client.put(f"/api/links/{created['id']}", json={
        "original_url": "https://new.com",
        "short_name": "new"
    })
    assert r.status_code == 200
    data = r.json()
    assert data["short_name"] == "new"
    assert data["short_url"] == "http://testserver/r/new"


def test_delete_link():
    created = client.post("/api/links", json={
        "original_url": "https://site.com",
        "short_name": "del1"
    }).json()

    r = client.delete(f"/api/links/{created['id']}")
    assert r.status_code == 204

    r = client.get(f"/api/links/{created['id']}")
    assert r.status_code == 404

