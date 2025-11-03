CREATE OR REPLACE TABLE {{ to.table }} AS
SELECT
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ from.options.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ func.options.size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) AS {{ func.options.column }}
FROM {{ from.table }}
