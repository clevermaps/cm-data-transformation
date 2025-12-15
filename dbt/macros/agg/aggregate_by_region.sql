
{% macro aggregate_by_region(left_source, right_source, options) %}

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
ON ST_Intersects(a.{{ left_source.geometry }}, b.{{ right_source.geometry }})
GROUP BY a.*
{% endmacro %}
