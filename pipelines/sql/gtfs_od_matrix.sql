-- ============================================
-- GTFS → Direct Link Average Travel Times
-- ============================================

create or replace table gtfs_stg.stop_times as
select
    _trip_id as trip_id,
    arrival_time,
    departure_time,
    stop_id,
    cast(stop_sequence as integer) as stop_sequence,
    --stop_headsign,
    pickup_type,
    drop_off_type
from gtfs_raw.stop_times;

-- 2) Load stop_times and convert arrival/departure times into seconds
CREATE or replace TABLE app.stop_times AS
SELECT
    trip_id,
    stop_id,
    stop_sequence,
    (
        split_part(arrival_time, ':', 1)::INT * 3600 +
        split_part(arrival_time, ':', 2)::INT * 60 +
        split_part(arrival_time, ':', 3)::INT
    ) AS arr_sec,
    (
        split_part(departure_time, ':', 1)::INT * 3600 +
        split_part(departure_time, ':', 2)::INT * 60 +
        split_part(departure_time, ':', 3)::INT
    ) AS dep_sec
FROM gtfs_stg.stop_times;

-- 3) Build direct edges between consecutive stops on the same trip
CREATE or replace TABLE app.edges AS
SELECT
    st1.stop_id AS from_stop,
    st2.stop_id AS to_stop,
    (st2.arr_sec - st1.dep_sec) AS travel_time
FROM app.stop_times st1
JOIN app.stop_times st2
  ON st1.trip_id = st2.trip_id
 AND st2.stop_sequence = st1.stop_sequence + 1
WHERE (st2.arr_sec - st1.dep_sec) > 0     -- remove bad or zero times
  AND (st2.arr_sec - st1.dep_sec) < 7200; -- sanity limit: 2h max

-- 4) Compute average travel time per direct stop pair
CREATE or replace TABLE app.edges_avg AS
SELECT
    from_stop,
    to_stop,
    AVG(travel_time) AS travel_time_sec
FROM app.edges
GROUP BY from_stop, to_stop;


-- -- 4) FULL 30-min reachability using recursive search
CREATE OR REPLACE TABLE app.reachable_final AS
WITH RECURSIVE reachable AS (

    -- seed: každá zastávka dosáhne sama sebe s 0 sec
    SELECT
        from_stop AS origin,
        from_stop AS current_stop,
        0 AS total_time
    FROM app.edges_avg
    GROUP BY from_stop

    UNION ALL

    -- rekurzivní rozšíření přes edges_avg
    SELECT
        r.origin,
        e.to_stop AS current_stop,
        r.total_time + e.travel_time_sec AS total_time
    FROM reachable r
    JOIN app.edges_avg e
      ON r.current_stop = e.from_stop
    WHERE r.total_time + e.travel_time_sec <= 1800
      AND e.to_stop != r.origin

)

SELECT DISTINCT
    r.origin as origin_id,
    s1.stop_name AS origin_name,
    s1.stop_lat as origin_lat,
    s1.stop_lon as origin_lng,
    r.current_stop AS destination_id,
    s2.stop_name AS destination_name,
    s2.stop_lat as destination_lat,
    s2.stop_lon as destination_lng,
    r.total_time
FROM reachable r
JOIN gtfs_stg.stops s1 ON r.origin = s1.stop_id
JOIN gtfs_stg.stops s2 ON r.current_stop = s2.stop_id
WHERE r.origin != r.current_stop
ORDER BY r.origin, r.total_time;
