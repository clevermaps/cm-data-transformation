CREATE OR REPLACE TABLE {{ to.table }} AS
SELECT
    {%- set all_cols = [] %}

    {#-- a_columns --#}
    {%- if func.options.a_columns %}
        {%- if func.options.a_columns[0] == '*' %}
            {%- set _ = all_cols.append('a.*') %}
        {%- else %}
            {%- for col in func.options.a_columns %}
                {%- set _ = all_cols.append('a.' ~ col) %}
            {%- endfor %}
        {%- endif %}
    {%- else %}
        {%- set _ = all_cols.append('a.*') %}
    {%- endif %}

    {#-- b_columns --#}
    {%- if func.options.b_columns %}
        {%- for col in func.options.b_columns %}
            {%- for k, v in col.items() %}
                {%- set _ = all_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
            {%- endfor %}
        {%- endfor %}
    {%- endif %}

    {{ all_cols | join(', ') }}

FROM {{ from.table }} AS a
LEFT JOIN {{ with.table }} AS b
ON ST_Intersects(a.{{ from.options.geometry }}, b.{{ with.options.geometry }})