
{% macro generate_voronoi(from, options) %}

with tmp_union as
(
    SELECT
        st_union_agg({{ from.geometry }}) as geom
    from {{ from.table }}
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