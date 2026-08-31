from typing import Optional

from .auth import DemoLoginRequest, DemoLoginResponse
from .material import MaterialCategoryResponse
from .collector import CollectorResponse
from .lot import (
    LotCreate,
    LotUpdate,
    LotResponse,
    PriceEstimateResponse,
    ClassificationResult,
)
from .recycler import RecyclerResponse, RecyclerMatchResponse
from .price import PriceResponse, PriceTrendPoint, PriceTrendResponse
from .offer import OfferCreate, OfferResponse
from .transaction import (
    HandoverRequest,
    HandoverConfirmRequest,
    PaymentRequest,
    TransactionResponse,
    EarningsSummary,
    PaymentResponse,
)
from .traceability import TraceabilityEventResponse, MaterialPassportResponse
from .demand import DemandCreate, DemandResponse
from .aggregation import AggregationGroupResponse, JoinGroupRequest

__all__ = [
    # Auth
    "DemoLoginRequest",
    "DemoLoginResponse",
    # Material
    "MaterialCategoryResponse",
    # Collector
    "CollectorResponse",
    # Lot
    "LotCreate",
    "LotUpdate",
    "LotResponse",
    "PriceEstimateResponse",
    "ClassificationResult",
    # Recycler
    "RecyclerResponse",
    "RecyclerMatchResponse",
    # Price
    "PriceResponse",
    "PriceTrendPoint",
    "PriceTrendResponse",
    # Offer
    "OfferCreate",
    "OfferResponse",
    # Transaction
    "HandoverRequest",
    "HandoverConfirmRequest",
    "PaymentRequest",
    "TransactionResponse",
    "EarningsSummary",
    "PaymentResponse",
    # Traceability
    "TraceabilityEventResponse",
    "MaterialPassportResponse",
    # Demand
    "DemandCreate",
    "DemandResponse",
    # Aggregation
    "AggregationGroupResponse",
    "JoinGroupRequest",
]
