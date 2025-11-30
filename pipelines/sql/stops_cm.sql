create or replace table app.stops_cm as
select
    a.stop_id,
    a.stop_name,
    a.stop_lat as lat,
    a.stop_lon as lng,
    a.zone_id,
    b.poi_count,
    c.poi_count as schools_count,
    d.poi_count as hospitals_count,
    e.pop_sum
from gtfs_stg.stops a
left join app.stops_agg_buffer_poi b
on a.stop_id = b.stop_id

left join app.stops_agg_buffer_schools c
on a.stop_id = c.stop_id

left join app.stops_agg_buffer_hospitals d
on a.stop_id = d.stop_id

left join app.stops_agg_buffer_pop e
on a.stop_id = e.stop_id;

copy app.stops_cm to './data/cm/stops_dwh.csv' header;