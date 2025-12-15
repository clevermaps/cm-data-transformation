select
    *
from {{ source('gtfs', 'stops') }}