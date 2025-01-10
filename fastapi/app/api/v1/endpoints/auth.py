from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from sqlalchemy.future import select
from app.db.dependencies import get_db
from app.db.models.admin import Admin  # Import the Admin model
from app.db.schemas.admin import AdminResponse, AdminBase, AdminCheck  # Import the schema for validation

router = APIRouter()

@router.post("/check-admin", response_model=AdminResponse)
async def check_admin(request: AdminCheck, db: Session = Depends(get_db)):
    """
    Check if the provided email exists in the admins table.
    """
    stmt = select(Admin).where(Admin.email == request.email)
    result = await db.execute(stmt)
    admin = result.scalar_one_or_none()

    if not admin:
        raise HTTPException(status_code=403, detail="Not authorized")

    return AdminResponse.from_orm(admin)
