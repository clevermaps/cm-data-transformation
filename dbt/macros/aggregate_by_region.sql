-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: duckdb/agg/aggregate_by_region.sql
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.


{% macro aggregate_by_region(left_source, right_source, options) %}
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
    {% if right_source.where is not none %}
    WHERE {{ right_source.where }}
    {% endif %}
) AS b
ON ST_Intersects(a.{{ left_source.geometry }}, b.{{ right_source.geometry }})
GROUP BY a.*
{% endmacro %}
