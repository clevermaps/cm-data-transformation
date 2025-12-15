
{% macro enrich_by_overlap(left_source, right_source, options) %}

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
