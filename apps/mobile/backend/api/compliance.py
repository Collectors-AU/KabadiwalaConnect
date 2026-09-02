from fastapi import APIRouter, Depends, Response
from sqlalchemy.orm import Session
import io
import csv
from datetime import datetime

from core.database import get_db
from core.models import TraceabilityDataset, TransactionDataset, RecyclerDataset

router = APIRouter(prefix="/api/v1/compliance", tags=["compliance"])

@router.get("/cpcb-export")
def export_cpcb_form2(db: Session = Depends(get_db), format: str = "json"):
    """
    Query verified traceability_dataset entries and format records according to CPCB Form-2 guidelines.
    Returns JSON by default, pass ?format=csv for a downloadable CSV file.
    """
    # Join Traceability with Transaction and Recycler datasets to construct the EPR compliance record
    records = db.query(TraceabilityDataset, TransactionDataset, RecyclerDataset)\
        .join(TransactionDataset, TraceabilityDataset.transaction_id == TransactionDataset.id)\
        .join(RecyclerDataset, TransactionDataset.recycler_id == RecyclerDataset.id)\
        .all()
        
    formatted_records = []
    for trace, txn, recycler in records:
        formatted_records.append({
            "Form2_Reference_ID": f"EPR-{txn.id}-{trace.id}",
            "Date_Of_Transaction": trace.created_at.strftime("%Y-%m-%d"),
            "Recycler_Facility_Name": recycler.facility_name,
            "CPCB_Registry_Number": recycler.registry_number,
            "Material_Category": f"CAT-{txn.material_id}",
            "Transaction_Value_INR": txn.amount,
            "Handover_GPS_Location": trace.location_data
        })
        
    if format == "csv":
        output = io.StringIO()
        if not formatted_records:
            return Response(content="No records found.", media_type="text/csv")
            
        writer = csv.DictWriter(output, fieldnames=formatted_records[0].keys())
        writer.writeheader()
        for row in formatted_records:
            writer.writerow(row)
            
        filename = f"cpcb_form2_export_{datetime.utcnow().date()}.csv"
        return Response(
            content=output.getvalue(),
            media_type="text/csv",
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
        
    return {"status": "SUCCESS", "cpcb_form2_records": formatted_records}
