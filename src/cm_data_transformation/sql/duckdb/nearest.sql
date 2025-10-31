-- TODO optimize

create or replace table {{ out_table }} as

with pairs AS (
    SELECT
        a.*,
        b.{{ id_col_b }} AS pair_id,
        st_distance(
            st_transform(a.{{ geom_col_a }}, 'EPSG:4326', 'EPSG:3857'),
            st_transform(b.{{ geom_col_b }}, 'EPSG:4326', 'EPSG:3857')
        ) AS pair_distance
    FROM {{ in_table_a }} as a
    LEFT JOIN {{ in_table_b }} as b
    ON (
        st_intersects(
            st_transform(
                st_buffer(
                    st_transform(a.{{ geom_col_a }}, 'EPSG:4326', 'EPSG:3857'),
                    {{ max_distance }}
                ),
                'EPSG:3857',
                'EPSG:4326'
            ),
            b.{{ geom_col_b }}
        )
    )
)
SELECT
    *
FROM (
    SELECT
        *,
        row_number() OVER (
            PARTITION BY {{ id_col_a }}
            ORDER BY pair_distance
        ) AS rn
    FROM pairs
) ranked

WHERE rn = 1


