CREATE OR REPLACE TABLE {{ from.table }}_tmp AS
SELECT
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ from.options.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ func.options.distance }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) as buffer
from {{ from.table }};

CREATE INDEX tmp_from_idx ON {{ from.table }}_tmp USING RTREE (buffer);

CREATE OR REPLACE TABLE {{ with.table }}_tmp AS
select
    *
from {{ with.table }}
{% if with.options.where is defined %}
WHERE {{ with.options.where }}
{% endif %};

CREATE INDEX tmp_with_idx ON {{ with.table }}_tmp USING RTREE ({{ with.options.geometry }});