CREATE OR REPLACE TABLE {{ right_source.table }}_tmp AS
SELECT
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ right_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ options.distance }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) as buffer
from {{ right_source.table }}
{% if right_source.where is not none %}
WHERE {{ right_source.where }}
{% endif %};

CREATE INDEX tmp_left_source_idx ON {{ right_source.table }}_tmp USING GIST (buffer);

CREATE OR REPLACE TABLE {{ left_source.table }}_tmp AS
select
    *
from {{ left_source.table }};

CREATE INDEX tmp_right_source_idx ON {{ left_source.table }}_tmp USING GIST ({{ left_source.geometry }});

CREATE OR REPLACE TABLE {{ target.table }} AS
SELECT DISTINCT
    a.*
from {{ left_source.table }}_tmp AS a
JOIN {{ right_source.table }}_tmp AS b
ON ST_Intersects(
    a.{{ left_source.geometry }}, 
    b.buffer
);

drop table {{ left_source.table }}_tmp;
drop table {{ right_source.table }}_tmp;
