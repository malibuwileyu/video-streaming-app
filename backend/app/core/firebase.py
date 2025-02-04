"""Firebase Admin SDK initialization and utilities."""

import firebase_admin
from firebase_admin import credentials, firestore, auth, storage
from functools import lru_cache
from pathlib import Path
from typing import Optional

class FirebaseAdmin:
    """Firebase Admin SDK wrapper for ReelAI."""
    
    def __init__(self, credentials_path: Optional[str] = None):
        """Initialize Firebase Admin SDK.
        
        Args:
            credentials_path: Path to service account JSON file.
                            If None, will look for GOOGLE_APPLICATION_CREDENTIALS env var.
        """
        if credentials_path:
            cred = credentials.Certificate(credentials_path)
            self.app = firebase_admin.initialize_app(cred)
        else:
            # Uses GOOGLE_APPLICATION_CREDENTIALS environment variable
            self.app = firebase_admin.initialize_app()
            
        # Initialize services
        self.db = firestore.client()
        self.bucket = storage.bucket()
        
    def verify_id_token(self, id_token: str) -> dict:
        """Verify Firebase ID token."""
        return auth.verify_id_token(id_token)
    
    def get_user(self, uid: str) -> dict:
        """Get user by UID."""
        return auth.get_user(uid)
    
    def create_user(self, email: str, password: str, **kwargs) -> dict:
        """Create a new Firebase Auth user."""
        return auth.create_user(
            email=email,
            password=password,
            **kwargs
        )

@lru_cache()
def get_firebase_admin() -> FirebaseAdmin:
    """Get or create FirebaseAdmin instance (singleton)."""
    credentials_path = Path(__file__).parent.parent.parent / "firebase-credentials.json"
    return FirebaseAdmin(str(credentials_path) if credentials_path.exists() else None)

# Dependency for FastAPI
async def get_firebase():
    """FastAPI dependency for Firebase Admin."""
    return get_firebase_admin() 