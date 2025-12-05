from pydantic import BaseModel
from typing import Optional

class TableConfig(BaseModel):
    table: str
    geometry: Optional[str] = None
    id: Optional[str] = None
    columns: Optional[dict] = None
    table_alias: Optional[str] = None
    where: Optional[str] = None