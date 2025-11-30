create or replace table app.admin_cm as
select
    row_number() over() as id,
    a.shape_name as admin_name,
    a.shape_type as admin_level,
    b.stops_count,
    round(c.pop_sum) as pop_sum,
    round(d.pop_sum_stops) as pop_sum_stops,
    st_xmin(st_geomfromtext(a.geometry)) as x_min,
    st_xmax(st_geomfromtext(a.geometry)) as x_max,
    st_ymin(st_geomfromtext(a.geometry)) as y_min,
    st_ymax(st_geomfromtext(a.geometry)) as y_max,
    a.geometry as wkt
from geobnd_stg.geoboundaries__adm4 a
left join app.adm_agg_stops b
on a.shape_id = b.shape_id

left join app.adm_agg_pop c
on a.shape_id = c.shape_id

left join app.adm_agg_pop_stops d
on a.shape_id = d.shape_id;

copy app.admin_cm to './data/cm/admin_units_dwh.csv' header;