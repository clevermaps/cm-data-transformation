
{{ cm_dbt_macros.generate_voronoi(
    from={
      "table": ref('stg__stops'),
      "geometry": "geom"
    },
    options={}
) }}