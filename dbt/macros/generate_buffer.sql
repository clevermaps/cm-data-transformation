-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: ../src/cm_data_transformation/sql/duckdb/gen/generate_buffer.sql
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.


{% macro generate_buffer(source, options) %}
-- args: source, options

SELECT
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ source.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ options.buffer_size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) AS {{ options.buffer_column }}
FROM {{ source.table }}
{% endmacro %}
