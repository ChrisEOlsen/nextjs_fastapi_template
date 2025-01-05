from app.database.connections import async_session

# Dependency for DB session
async def get_db():
    async with async_session() as session:
        yield session
