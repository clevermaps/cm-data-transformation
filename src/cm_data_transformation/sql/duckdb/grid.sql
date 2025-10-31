create or replace table {{ out_table }} as
select
    *,
    h3_latlng_to_cell_string(st_y({{ geom_col }}), st_x({{ geom_col }}), 6) as h3_r{{ h3_res }}_id
from {{ in_table }}