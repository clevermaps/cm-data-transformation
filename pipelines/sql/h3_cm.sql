create or replace table app.h3_cm as
select
    a.h3_id,
    b.stops_count,
    round(c.pop_sum) as pop_sum,
    round(d.pop_sum_stops) as pop_sum_stops,
    st_xmin(st_geomfromtext(a.h3_wkt)) as x_min,
    st_xmax(st_geomfromtext(a.h3_wkt)) as x_max,
    st_ymin(st_geomfromtext(a.h3_wkt)) as y_min,
    st_ymax(st_geomfromtext(a.h3_wkt)) as y_max,
    a.h3_wkt as wkt
from app.cze_h3_res7 a
left join app.h3_agg_stops b
on a.h3_id = b.h3_id

left join app.h3_agg_pop c
on a.h3_id = c.h3_id

left join app.h3_agg_pop_stops d
on a.h3_id = d.h3_id;

copy app.h3_cm to './data/cm/h3_grid_dwh.csv' header;