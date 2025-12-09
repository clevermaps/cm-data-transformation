-- TODO optimize
CREATE OR REPLACE TABLE {{ target.table }} AS

WITH pairs AS (
    SELECT
        a.*,
        b.{{ right_source.id }} AS nearest_id,
        ST_Distance(
            ST_Transform(a.{{ left_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            ST_Transform(b.{{ right_source.geometry }}, 'EPSG:4326', 'EPSG:3857')
        ) AS nearest_distance
    FROM {{ left_source.table }} AS a
    LEFT JOIN {{ right_source.table }} AS b
    ON (
        ST_Intersects(
            ST_Transform(
                ST_Buffer(
                    ST_Transform(a.{{ left_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
                    {{ options.max_distance }}
                ),
                'EPSG:3857',
                'EPSG:4326'
            ),
            b.{{ right_source.geometry }}
        )
    )
    {% if right_source.where is not none %}
        AND {{ right_source.where }}
    {% endif %}
)
SELECT
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY {{ left_source.id }}
            ORDER BY nearest_distance
        ) AS rn
    FROM pairs
) ranked
WHERE rn <= {{ options.max_neighbours }};
