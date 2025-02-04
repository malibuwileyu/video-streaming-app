"""FastAPI dependencies."""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from .firebase import get_firebase_admin, FirebaseAdmin

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    firebase: FirebaseAdmin = Depends(get_firebase_admin)
) -> dict:
    """Verify Firebase ID token and return user info.
    
    Args:
        credentials: Bearer token from request
        firebase: Firebase Admin instance
        
    Returns:
        dict: User information from Firebase Auth
        
    Raises:
        HTTPException: If token is invalid or expired
    """
    try:
        # Verify the Firebase ID token
        token = credentials.credentials
        decoded_token = firebase.verify_id_token(token)
        
        # Get the user from Firebase Auth
        user = firebase.get_user(decoded_token['uid'])
        return user
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        ) 