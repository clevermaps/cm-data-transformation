CREATE OR REPLACE TABLE {{ target.table }} AS
WITH h3_ids AS
(
    SELECT
        {{ source.id }},
        unnest(
            h3_polygon_to_cells(
                {{ source.geometry }}, {{ options.h3_res }}
            )
        ) AS h3_id
    FROM {{ source.table }}
),
h3_ids_rank AS
(
    SELECT
        {{ source.id }},
        h3_id,
        row_number() OVER (PARTITION BY h3_id) AS h3_rank
    FROM h3_ids
)
SELECT
    {{ source.id }},
    h3_id,
    h3_cell_to_boundary(h3_id) AS h3_geom,
    ST_GeomFromText(h3_cell_to_boundary(h3_id)) AS geom
FROM h3_ids_rank
WHERE h3_rank = 1;
