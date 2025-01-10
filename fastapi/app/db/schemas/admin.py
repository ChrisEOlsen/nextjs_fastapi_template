from pydantic import BaseModel, EmailStr


# Shared attributes for Admin
class AdminBase(BaseModel):
    name: str
    email: EmailStr


# Schema for creating an admin
class AdminCreate(AdminBase):
    pass


# Schema for removing an admin (by ID)
class AdminRemove(BaseModel):
    id: int


# Schema for returning admin data (e.g., from the database)
class AdminResponse(AdminBase):
    id: int

    class Config:
        from_attributes = True

class AdminCheck(BaseModel):
    email: str
