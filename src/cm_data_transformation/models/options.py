from pydantic import BaseModel

class AggregateWithinBufferOptions(BaseModel):
    buffer_size: int
    agg: str

class AggregateByRegionOptions(BaseModel):
    agg: str

class FilterWithinDistanceOptions(BaseModel):
    distance: int

class FilterByOverlapOptions(BaseModel):
    pass

class GenerateBufferOptions(BaseModel):
    buffer_size: int
    buffer_column: str

class GenerateH3Options(BaseModel):
    h3_res: int

class GenerateH3WithinOptions(BaseModel):
    h3_res: int

class FindNearestAvg(BaseModel):
    max_neighbours: int
    max_distance: int

class FindNearestN(BaseModel):
    max_neighbours: int
    max_distance: int

class AddWithOverlap(BaseModel):
    pass

