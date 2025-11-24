# app/main.py
# Entry point for FastAPI application with Sentry integration

import logging
import os

import sentry_sdk
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sentry_sdk.integrations.asgi import SentryAsgiMiddleware

# Logging setup
logging.basicConfig(level=logging.INFO)

# Initialize Sentry
SENTRY_DSN = os.getenv("SENTRY_DSN")
if SENTRY_DSN:
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        send_default_pii=True,
        traces_sample_rate=1.0,
    )

# Initialize FastAPI
app = FastAPI(title="DevOps Engineer Project 313")

# Add all middleware before Sentry
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Wrap the app in Sentry middleware AFTER adding all other middleware
if SENTRY_DSN:
    app = SentryAsgiMiddleware(app)

# Health check endpoint
@app.get("/ping")
async def ping():
    return "pong"

# Test route to trigger Sentry error
@app.get("/sentry-debug")
async def trigger_error():
    1 / 0  # This will send an error to Sentry

def main():
    print("Hello from devops-engineer-from-scratch-project-313!")

if __name__ == "__main__":
    main()

