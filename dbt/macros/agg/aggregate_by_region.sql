
{% macro aggregate_by_region(from, by, options) %}

{% set aggregations = options.aggregations %}

SELECT
    a.*
    
    {%- for agg in aggregations %}
    , {{ agg.function }}(b.{{ agg.column }}) AS {{ agg.result }}
    {%- endfor %}

FROM {{ by.table }} AS a
LEFT JOIN {{ from.table }} AS b
ON ST_Intersects(a.{{ by.geometry }}, b.{{ from.geometry }})

{% if from.where is defined %}
WHERE {{ from.where }}
{% endif %}

GROUP BY a.*
{% endmacro %}
