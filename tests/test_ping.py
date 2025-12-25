# tests/test_ping.py
# Tests for /ping endpoint

from fastapi.testclient import TestClient

from app.main import fastapi_app  # Use original FastAPI app for testing

client = TestClient(fastapi_app)


def test_ping():
    response = client.get("/ping")
    assert response.status_code == 200
    assert response.json() == "pong"


def test_sentry_debug():
    # Ensure triggering Sentry route raises error
    import pytest
    with pytest.raises(ZeroDivisionError):
        client.get("/sentry-debug")

