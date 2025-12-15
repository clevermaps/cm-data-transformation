select
    *
from {{ source('ovm', 'places_place') }}