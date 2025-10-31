create or replace table {{ out_table }} as
select
    a.*,
    {{ agg_func }}
from {{ in_table_a }} as a
left join {{ in_table_b }} as b
on ST_Intersects( a.{{ geom_col_a }}, b.{{ geom_col_b }} )
group by
    a.*