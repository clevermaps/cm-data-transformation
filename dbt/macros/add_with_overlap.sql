-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: ../src/cm_data_transformation/sql/duckdb/add/add_with_overlap.sql
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.


{% macro add_with_overlap(left_source, right_source, options) %}
-- args: left_source, right_source, options

SELECT
    a.*,

    {%- set b_cols = [] %}
    {%- if right_source.columns %}
        {%- for k, v in right_source.columns.items() %}
            {%- set _ = b_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
        {%- endfor %}
    {%- endif %}

    {{ b_cols | join(', ') }}

FROM {{ left_source.table }} AS a
LEFT JOIN {{ right_source.table }} AS b
ON ST_Intersects(a.{{ left_source.geometry }}, b.{{ right_source.geometry }})
{% endmacro %}
