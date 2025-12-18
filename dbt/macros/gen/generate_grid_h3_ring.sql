
{% macro generate_grid_h3_ring(source, options) %}

with tmp as
(
    {{ cm_dbt_macros.generate_grid_h3(source, options) }}
)
SELECT
    *,
    h3_grid_ring(h3_r{{ options.h3_res }}_id, {{ options.h3_ring_size }}) AS h3_r{{ options.h3_res }}_ring_{{ options.h3_ring_size }}
FROM tmp

{% endmacro %}