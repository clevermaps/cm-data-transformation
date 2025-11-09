-- TODO optimize
CREATE OR REPLACE TABLE {{ to.table }} AS

WITH pairs AS (
    SELECT
        {{ from.options.table_alias }}.*,
        {{ with.options.table_alias }}.{{ with.options.id }} AS pair_id,
        ST_Distance(
            ST_Transform(a.{{ from.options.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            ST_Transform(b.{{ with.options.geometry }}, 'EPSG:4326', 'EPSG:3857')
        ) AS pair_distance
    FROM {{ from.table }} AS {{ from.options.table_alias }}
    LEFT JOIN {{ with.table }} AS {{ with.options.table_alias }}
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
    {% if func.options.where_condition is defined %}
        AND {{ func.options.where_condition }}
    {% endif %}
)
SELECT
    {{ from.options.table_alias }}.*,
    avg(pair_distance) as avg_distance
from {{ from.table }} AS {{ from.options.table_alias }}
left join (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY {{ from.options.id }}
            ORDER BY pair_distance
        ) AS rn
    FROM pairs
) ranked
on {{ from.options.table_alias }}.{{ from.options.id }} = ranked.{{ from.options.id }}
and rn <= {{ func.options.max_neighbours }}
GROUP BY
    {{ from.options.table_alias }}.*