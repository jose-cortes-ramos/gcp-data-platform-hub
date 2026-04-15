from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from decimal import Decimal
from typing import Optional

class CryptoAsset(BaseModel):
    """
    Schema for validating incoming Crypto Asset data from CoinGecko.
    Follows Senior Data Engineering standards for financial precision.
    """
    id: str = Field(..., description="Unique identifier for the asset (e.g., bitcoin)")
    symbol: str = Field(..., description="Asset symbol (e.g., btc)")
    name: str = Field(..., description="Asset name")
    current_price: Decimal = Field(..., description="Current market price")
    market_cap: Optional[Decimal] = Field(None, description="Market capitalization")
    total_volume: Optional[Decimal] = Field(None, description="Total trading volume")
    extracted_at: datetime = Field(default_factory=datetime.utcnow, description="Timestamp of data extraction")

    @field_validator('current_price', 'market_cap', 'total_volume', mode='before')
    @classmethod
    def validate_decimal(cls, v):
        if v is None:
            return None
        try:
            return Decimal(str(v))
        except Exception:
            raise ValueError(f"Invalid decimal value: {v}")

    class Config:
        json_encoders = {
            Decimal: lambda v: float(v)  # For JSON compatibility if needed
        }

class CryptoHistoricalRaw(BaseModel):
    """
    Schema for validating historical time-series data from CoinGecko.
    Structure: {"prices": [[ts, val], ...], "market_caps": [...], "total_volumes": [...]}
    """
    prices: list[list[float]] = Field(..., description="Array of [timestamp, price] pairs")
    market_caps: list[list[float]] = Field(..., description="Array of [timestamp, market_cap] pairs")
    total_volumes: list[list[float]] = Field(..., description="Array of [timestamp, total_volume] pairs")
