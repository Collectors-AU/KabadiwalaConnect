from typing import Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, lots, materials, prices, recyclers, offers, admin, passports
from app.database import engine, Base
from app.seed.seed_data import seed_all
from app.database import SessionLocal

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Kabadiwala Connect API",
    description="API for the Kabadiwala Connect SIH 2026 MVP",
    version="1.0.0"
)

# Configure CORS for local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Seed database on startup if empty
@app.on_event("startup")
def startup_event():
    db = SessionLocal()
    try:
        seed_all(db)
    finally:
        db.close()

# Include routers
app.include_router(admin.router, prefix="/api/admin", tags=["admin"])
app.include_router(passports.router, prefix="/api/passports", tags=["passports"])
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(materials.router, prefix="/api/materials", tags=["materials"])
app.include_router(lots.router, prefix="/api/lots", tags=["lots"])
app.include_router(prices.router, prefix="/api/prices", tags=["prices"])
app.include_router(recyclers.router, prefix="/api/recyclers", tags=["recyclers"])
app.include_router(offers.router, prefix="/api/offers", tags=["offers"])

@app.get("/")
def read_root():
    return {"message": "Kabadiwala Connect API running. See /docs for Swagger UI."}
