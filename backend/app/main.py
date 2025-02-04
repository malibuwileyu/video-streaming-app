"""ReelAI FastAPI Backend."""

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from .core.firebase import get_firebase_admin, FirebaseAdmin
from .core.dependencies import get_current_user

app = FastAPI(
    title="ReelAI API",
    description="Backend API for ReelAI video platform",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    """Initialize Firebase Admin SDK on startup."""
    get_firebase_admin()

@app.get("/api/v1/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}

@app.get("/api/v1/me")
async def get_me(user: dict = Depends(get_current_user)):
    """Get current user information."""
    return user
