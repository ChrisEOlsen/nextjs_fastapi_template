from fastapi import Request, status
from fastapi.responses import JSONResponse
import os

# All nextjs routes pointing to /admin routes need to contain:  
# "X-Shared-Secret": process.env.SHARED_SECRET

SHARED_SECRET = os.getenv("SHARED_SECRET")
if not SHARED_SECRET:
    raise RuntimeError("SHARED_SECRET must be set in the environment variables")

async def validate_shared_secret(request: Request, call_next):
    """
    Middleware to validate that the request includes the correct shared secret.
    """
    secret = request.headers.get("X-Shared-Secret")
    if secret != SHARED_SECRET:
        # Return a graceful JSON response for invalid shared secret
        return JSONResponse(
            status_code=status.HTTP_403_FORBIDDEN,
            content={"detail": "Forbidden: Invalid shared secret. Nice try diddy"},
        )
    return await call_next(request)
