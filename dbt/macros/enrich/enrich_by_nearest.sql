{% macro enrich_by_nearest(left_source, right_source, options) %}

{% set enrich_options = options.copy() %}
{% set _ = enrich_options.update({'max_neighbours': 1}) %}

WITH nearest AS (
    {{ find_nearest_n(left_source, right_source, enrich_options) }}
)

SELECT
    a.*,
    {%- set b_cols = [] %}
    {%- for k, v in right_source.columns.items() %}
        {%- set _ = b_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
    {%- endfor %}
    {{ b_cols | join(', ') }}
FROM {{ left_source.table }} AS a
LEFT JOIN nearest AS n
    ON a.{{ left_source.id }} = n.{{ left_source.id }}
LEFT JOIN {{ right_source.table }} AS b
    ON b.{{ right_source.id }} = n.nearest_id

{% endmacro %}