-- TODO optimize
CREATE OR REPLACE TABLE {{ to.table }} AS

WITH pairs AS (
    SELECT
        a.*,
        b.{{ with.options.id }} AS pair_id,
        ST_Distance(
            ST_Transform(a.{{ from.options.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            ST_Transform(b.{{ with.options.geometry }}, 'EPSG:4326', 'EPSG:3857')
        ) AS pair_distance
    FROM {{ from.table }} AS a
    LEFT JOIN {{ with.table }} AS b
    ON (
        ST_Intersects(
            ST_Transform(
                ST_Buffer(
                    ST_Transform(a.{{ from.options.geometry }}, 'EPSG:4326', 'EPSG:3857'),
                    {{ func.options.max_distance }}
                ),
                'EPSG:3857',
                'EPSG:4326'
            ),
            b.{{ with.options.geometry }}
        )
    )
)
SELECT
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY {{ from.options.id }}
            ORDER BY pair_distance
        ) AS rn
    FROM pairs
) ranked
WHERE rn = 1