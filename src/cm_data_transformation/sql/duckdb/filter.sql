create or replace table {{ out_table }} as
select
    a.*
from {{ in_table_a }} a
join {{ in_table_b }} b
on ST_Intersects(a.{{ geom_col_a }}, b.{{ geom_col_b }})
and {{ where_condition }}