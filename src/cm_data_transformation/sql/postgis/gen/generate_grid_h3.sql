CREATE OR REPLACE TABLE {{ target.table }} AS
SELECT
    *,
    h3_geo_to_h3(ST_Y({{ source.geometry }}), ST_X({{ source.geometry }}), {{ options.h3_res }}) AS h3_r{{ options.h3_res }}_id
FROM {{ source.table }};
