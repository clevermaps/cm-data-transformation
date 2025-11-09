CREATE OR REPLACE TABLE {{ to.table }} AS
SELECT
    a.*,
    {{ func.options.agg }}
FROM {{ from.table }} AS a
LEFT JOIN {{ with.table }} AS b
ON ST_Intersects(
    ST_Transform(
        ST_Buffer(
            ST_Transform(a.{{ from.options.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ func.options.buffer_size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ), 
    b.{{ with.options.geometry }}
)
GROUP BY a.*