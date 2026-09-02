from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.database import engine, Base
import core.models
from api.sync import router as sync_router
from api.telephony import router as telephony_router
from api.compliance import router as compliance_router

# Automatic table creation on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(title="KabadiwalaConnect Backend API")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(sync_router)
app.include_router(telephony_router)
app.include_router(compliance_router)

@app.get("/")
def health_check():
    return {"status": "ok", "message": "API is running"}
