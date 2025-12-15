
{% macro generate_grid_h3(source, options) %}

SELECT
    *,
    h3_latlng_to_cell_string(
        ST_Y({{ source.geometry }}),
        ST_X({{ source.geometry }}),
        {{ options.h3_res }}
    ) AS h3_r{{ options.h3_res }}_id
FROM {{ source.table }}
{% endmacro %}
