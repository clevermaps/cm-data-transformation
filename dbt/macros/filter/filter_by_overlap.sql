{% macro filter_by_overlap(from, by, options) %}

SELECT
    a.*
FROM {{ from.table }} AS a
JOIN {{ by.table }} AS b
ON ST_Intersects(a.{{ from.geometry }}, b.{{ by.geometry }})
{% if by.where is defined %}
AND {{ by.where }}
{% endif %}

{% endmacro %}
