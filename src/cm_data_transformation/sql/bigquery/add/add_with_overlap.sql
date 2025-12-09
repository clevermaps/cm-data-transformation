CREATE OR REPLACE TABLE `{{ target.table }}` AS
SELECT
    a.*,

    {%- set b_cols = [] %}
    {%- if right_source.columns %}
        {%- for k, v in right_source.columns.items() %}
            {%- set _ = b_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
        {%- endfor %}
    {%- endif %}

    {{ b_cols | join(', ') }}

FROM `{{ left_source.table }}` AS a
LEFT JOIN `{{ right_source.table }}` AS b
ON ST_INTERSECTS(ST_GEOGFROMWKT(a.{{ left_source.geometry }}), ST_GEOGFROMWKT(b.{{ right_source.geometry }}));
