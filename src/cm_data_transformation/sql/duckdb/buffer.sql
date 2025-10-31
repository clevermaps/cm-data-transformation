create or replace table {{ out_table }} as
select
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ geometry_col }}, 'EPSG:4326', 'EPSG:3857'), {{ buffer_m }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) as {{ out_col }}
from {{ in_table }}