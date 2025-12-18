
{{ cm_dbt_macros.generate_voronoi(
    source={
      "table": ref('stg__stops'),
      "geometry": "geom"
    },
    options={}
) }}