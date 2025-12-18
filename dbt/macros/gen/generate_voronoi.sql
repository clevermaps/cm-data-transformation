
{% macro generate_voronoi(source, options) %}

with tmp_union as
(
    SELECT
        st_union_agg({{ source.geometry }}) as geom
    from {{ source.table }}
),
tmp_voronoi as
(
    SELECT
        *,
        st_voronoidiagram(geom) AS voronoi
    FROM tmp_union
)
select 
    unnest(st_dump(voronoi), recursive := true) as geom
from tmp_voronoi

{% endmacro %}