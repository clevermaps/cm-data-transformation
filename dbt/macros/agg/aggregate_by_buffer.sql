
{% macro aggregate_by_buffer(from, by, options) %}

{% set aggregations = options.aggregations %}

SELECT
    a.*
    
    {%- for agg in aggregations %}
    , {{ agg.function }}(b.{{ agg.column }}) AS {{ agg.result }}
    {%- endfor %}

FROM {{ by.table }} AS a
LEFT JOIN {{ from.table }} AS b
ON ST_Intersects(
    ST_Transform(
        ST_Buffer(
            ST_Transform(a.{{ by.geometry }}, 'EPSG:4326', 'EPSG:3857'),
            {{ by.buffer_size }}
        ),
        'EPSG:3857', 'EPSG:4326'
    ),
    b.{{ by.geometry }}
)
{% if from.where is defined %}
WHERE {{ from.where }}
{% endif %}

GROUP BY a.*

{% endmacro %}
