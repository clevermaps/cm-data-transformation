CREATE OR REPLACE TABLE {{ target.table }} AS
SELECT
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ options.buffer_size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) AS {{ options.buffer_column }}
FROM {{ source.table }}
