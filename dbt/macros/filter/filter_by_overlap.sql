{% macro filter_by_overlap(left_source, right_source, options) %}

SELECT
    a.*
FROM {{ left_source.table }} AS a
JOIN {{ right_source.table }} AS b
ON ST_Intersects(a.{{ left_source.geometry }}, b.{{ right_source.geometry }})
{% if right_source.where is defined %}
AND {{ right_source.where }}
{% endif %}

{% endmacro %}
