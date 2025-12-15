-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: ../src/cm_data_transformation/sql/duckdb/find/find_nearest_avg.sql
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.


{% macro find_nearest_avg(left_source, right_source, options) %}
-- args: left_source, right_source, options


WITH pairs AS (
    SELECT
        a.*,
        b.{{ right_source.id }} AS pair_id,
        ST_Distance(
            ST_Transform(a.{{ left_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            ST_Transform(b.{{ right_source.geometry }}, 'EPSG:4326', 'EPSG:3857')
        ) AS pair_distance
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
    a.*,
    avg(pair_distance) as avg_distance
from {{ left_source.table }} AS a
left join (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY {{ left_source.id }}
            ORDER BY pair_distance
        ) AS rn
    FROM pairs
) ranked
on a.{{ left_source.id }} = ranked.{{ left_source.id }}
and rn <= {{ options.max_neighbours }}
GROUP BY
    a.*
{% endmacro %}
