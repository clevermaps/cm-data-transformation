-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: ../src/cm_data_transformation/sql/duckdb/agg/aggregate_within_buffer.sql
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.


{% macro aggregate_within_buffer(left_source, right_source, options) %}
-- args: left_source, right_source, options

SELECT
    a.*,
    {{ options.agg }}
FROM {{ left_source.table }} AS a
LEFT JOIN
(
    select
        *
    from {{ right_source.table }}
    {% if right_source.where is defined %}
    WHERE {{ right_source.where }}
    {% endif %}
) AS b
ON ST_Intersects(
    ST_Transform(
        ST_Buffer(
            ST_Transform(a.{{ left_source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ options.buffer_size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ),
    b.{{ right_source.geometry }}
)
GROUP BY a.*
{% endmacro %}
