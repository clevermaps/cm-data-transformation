CREATE OR REPLACE TABLE {{ to.table }} AS
SELECT
    *,
    h3_latlng_to_cell_string(
        ST_Y({{ from.options.geometry }}),
        ST_X({{ from.options.geometry }}),
        {{ func.options.h3_res }}
    ) AS h3_r{{ func.options.h3_res }}_id
FROM {{ from.table }}
