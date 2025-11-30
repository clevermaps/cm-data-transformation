create or replace table app.poi_reach_stops as
select
    a.id,
    count(distinct(b.destination_id)) as reachable_stops_count
from app.poi_nearest_stop as a
join app.reachable_final as b
on a.nearest_id = b.origin_id
group by 
    a.id;

create or replace table app.poi_reach_pop as
with tmp as
(
    select distinct
        a.id,
        c.adm_id
    from app.poi_nearest_stop as a
    join app.reachable_final as b
    on a.nearest_id = b.origin_id
    join app.stops_adm4 c
    on b.destination_id = c.stop_id
)
select
    a.id,
    b.name,
    b.category,
    b.address,
    round(sum(c.pop_sum)) as reachable_pop
from tmp a
join ovm_stg.places_place b
on a.id = b.id
join app.adm_agg_pop c
on a.adm_id = c.shape_id
group by 
    a.id,
    b.name,
    b.category,
    b.address;
    