create or replace table {{ out_table }} as
select
    {%- set all_cols = [] %}

    {#-- a_columns --#}
    {%- if a_columns %}
        {%- if a_columns[0] == '*' %}
            {%- set _ = all_cols.append('a.*') %}
        {%- else %}
            {%- for col in a_columns %}
                {%- set _ = all_cols.append('a.' ~ col) %}
            {%- endfor %}
        {%- endif %}
    {%- else %}
        {%- set _ = all_cols.append('a.*') %}
    {%- endif %}

    {#-- b_columns --#}
    {%- if b_columns %}
        {%- for col in b_columns %}
            {%- for k, v in col.items() %}
                {%- set _ = all_cols.append('b.' ~ k ~ ' AS ' ~ v) %}
            {%- endfor %}
        {%- endfor %}
    {%- endif %}

    {{ all_cols | join(', ') }}

from {{ in_table_a }} as a
left join {{ in_table_b }} as b
on ST_Intersects(a.{{ geom_col_a }}, b.{{ geom_col_b }})