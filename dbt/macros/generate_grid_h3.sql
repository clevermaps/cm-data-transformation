-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: ../src/cm_data_transformation/sql/duckdb/gen/generate_grid_h3.sql
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.


{% macro generate_grid_h3(source, options) %}
-- args: source, options

SELECT
    *,
    h3_latlng_to_cell_string(
        ST_Y({{ source.geometry }}),
        ST_X({{ source.geometry }}),
        {{ options.h3_res }}
    ) AS h3_r{{ options.h3_res }}_id
FROM {{ source.table }}
{% endmacro %}
