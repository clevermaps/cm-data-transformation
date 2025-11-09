CREATE OR REPLACE TABLE {{ to.table }} AS
with h3_ids as
(
    select
        {{from.options.id}},
        unnest(
            h3_polygon_wkt_to_cells(
                {{from.options.geometry}}, {{func.options.h3_res}}
            )
        ) AS h3_id
    from {{ from.table }}
),
h3_ids_rank as
(
    select
        {{from.options.id}},
        h3_id,
        row_number() over(partition by h3_id) as h3_rank
    from h3_ids
)
select
    {{from.options.id}},
    h3_id,
    h3_cell_to_boundary_wkt(h3_id) as h3_wkt,
    st_geomfromtext(h3_cell_to_boundary_wkt(h3_id)) as geom
from h3_ids_rank
where h3_rank = 1