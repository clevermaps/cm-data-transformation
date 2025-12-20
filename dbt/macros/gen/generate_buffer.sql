
{% macro generate_buffer(from, options) %}

SELECT
    *,
    ST_Transform(
        ST_Buffer(
            ST_Transform({{ from.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ options.buffer_size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ) AS {{ options.buffer_column }}
FROM {{ from.table }}
{% endmacro %}
