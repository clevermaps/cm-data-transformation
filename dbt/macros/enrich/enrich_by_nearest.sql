{% macro enrich_by_nearest(from, by, options) %}

{% set enrich_options = options.copy() %}
{% set _ = enrich_options.update({'max_neighbours': 1}) %}
{% set _ = enrich_options.update({'max_distance': options.max_distance}) %}

WITH nearest AS (
    {{ cm_dbt_macros.find_nearest_n(from, by, enrich_options) }}
)

SELECT
    a.*,
    {%- set b_cols = [] %}
    {%- for k, v in by.columns.items() %}
        {%- set _ = b_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
    {%- endfor %}
    {{ b_cols | join(', ') }}
FROM {{ from.table }} AS a
LEFT JOIN nearest AS n
    ON a.{{ from.id }} = n.{{ from.id }}
LEFT JOIN {{ by.table }} AS b
    ON b.{{ by.id }} = n.nearest_id

{% endmacro %}