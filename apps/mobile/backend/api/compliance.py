from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
import csv
import io
from datetime import timezone

from core.database import get_db
from core.models import TransactionDataset, TraceabilityDataset, RecyclerDataset
from api.telephony import CATEGORY_MAP

router = APIRouter(prefix="/api/v1/compliance", tags=["compliance"])

@router.get("/cpcb-export")
def export_cpcb_form2(db: Session = Depends(get_db)):
    # Query verified transaction records
    # For Form-2, we need: TraceabilityDataset, TransactionDataset, RecyclerDataset
    records = db.query(
        TransactionDataset,
        TraceabilityDataset,
        RecyclerDataset
    ).join(
        TraceabilityDataset, TransactionDataset.id == TraceabilityDataset.transaction_id
    ).join(
        RecyclerDataset, TransactionDataset.recycler_id == RecyclerDataset.id
    ).all()

    # Generate CSV in-memory
    stream = io.StringIO()
    writer = csv.writer(stream)
    
    # Form-2 Headers
    writer.writerow(["FORM-2: FORM FOR MAINTAINING RECORDS OF E-WASTE HANDLED OR GENERATED"])
    writer.writerow(["[See rules 4(4), 5(4), 8(6), 9(4), 10(7), 11(8), 13(1)(xi) and 13(2)(v)]"])
    writer.writerow([])
    
    # Column headers
    writer.writerow([
        "Consignment Tracking ID",
        "Timestamp (UTC)",
        "Schedule I EEE Code",
        "Item Description",
        "Weight (Metric Tonnes)",
        "Aggregator ID",
        "Authorized Recycler Reg No",
        "SPCB CTO Reference",
        "SHA-256 Tamper Digest",
        "Custody Verification Mode"
    ])
    
    for txn, trace, recycler in records:
        # Resolve category from material_id
        # Material ID maps to our CATEGORY_MAP keys roughly
        category_str = str(txn.material_id)
        cat_info = CATEGORY_MAP.get(category_str, CATEGORY_MAP['1'])
        
        # Convert weight (kg) to Metric Tonnes (kg / 1000.0) formatted to 6 decimal places.
        weight_mt = txn.weight / 1000.0
        
        writer.writerow([
            f"CTN-{txn.id:06d}",
            trace.created_at.replace(tzinfo=timezone.utc).isoformat() if trace.created_at else "",
            cat_info['code_eee'],
            cat_info['name'],
            f"{weight_mt:.6f}",
            "AGG-DEMO-01",
            recycler.registry_number,
            "CTO-2026-X1", # Dummy SPCB CTO Reference
            trace.sha256_hash,
            "DTMF/IVR" if txn.status == "LOCAL_PENDING" else "CRYPTOGRAPHIC_QR"
        ])
    
    response = StreamingResponse(iter([stream.getvalue()]), media_type="text/csv")
    response.headers["Content-Disposition"] = "attachment; filename=cpcb_form2_export.csv"
    return response
