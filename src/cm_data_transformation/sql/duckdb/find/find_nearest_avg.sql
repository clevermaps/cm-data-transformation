-- TODO optimize
CREATE OR REPLACE TABLE {{ target.table }} AS

WITH pairs AS (
    SELECT
        {{ left_source.table_alias }}.*,
        {{ right_source.table_alias }}.{{ right_source.id }} AS pair_id,
        ST_Distance(
            ST_Transform(a.{{ left_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            ST_Transform(b.{{ right_source.geometry }}, 'EPSG:4326', 'EPSG:3857')
        ) AS pair_distance
    FROM {{ left_source.table }} AS {{ left_source.table_alias }}
    LEFT JOIN {{ right_source.table }} AS {{ right_source.table_alias }}
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
    {{ left_source.table_alias }}.*,
    avg(pair_distance) as avg_distance
from {{ left_source.table }} AS {{ left_source.table_alias }}
left join (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY {{ left_source.id }}
            ORDER BY pair_distance
        ) AS rn
    FROM pairs
) ranked
on {{ left_source.table_alias }}.{{ left_source.id }} = ranked.{{ left_source.id }}
and rn <= {{ options.max_neighbours }}
GROUP BY
    {{ left_source.table_alias }}.*