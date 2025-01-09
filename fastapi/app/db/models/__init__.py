from sqlalchemy.ext.declarative import declarative_base

# Centralized Base for all models
Base = declarative_base()

# Import all models here so they are registered with Alembic
# For example:
#from app.models.pricing import Pricing
