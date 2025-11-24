# main.py
# Entry point for FastAPI application

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

# Initialize app
app = FastAPI(title="DevOps Engineer Project 313")

# Setup logging middleware
logging.basicConfig(level=logging.INFO)

# Setup CORS middleware for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/ping")
async def ping():
    return "pong"

# Optional main function for direct run
def main():
    print("Hello from devops-engineer-from-scratch-project-313!")

if __name__ == "__main__":
    main()
