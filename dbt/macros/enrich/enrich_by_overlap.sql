
{% macro enrich_by_overlap(from, by, options) %}

SELECT
    a.*,

    {%- set b_cols = [] %}
    {%- if by.columns %}
        {%- for k, v in by.columns.items() %}
            {%- set _ = b_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
        {%- endfor %}
    {%- endif %}

    {{ b_cols | join(', ') }}

FROM {{ from.table }} AS a
LEFT JOIN {{ by.table }} AS b
ON ST_Intersects(a.{{ from.geometry }}, b.{{ by.geometry }})
{% endmacro %}
