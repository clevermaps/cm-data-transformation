
{% macro generate_grid_h3(from, options) %}

SELECT
    *,
    h3_latlng_to_cell_string(
        ST_Y({{ from.geometry }}),
        ST_X({{ from.geometry }}),
        {{ options.h3_res }}
    ) AS h3_r{{ options.h3_res }}_id
FROM {{ from.table }}

{% endmacro %}
