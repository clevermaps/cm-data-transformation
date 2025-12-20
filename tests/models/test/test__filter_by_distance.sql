
{{ cm_dbt_macros.filter_by_distance(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    by={
      "table": ref('stg__stops'),
      "geometry": "geom"
    },
    options={
      "distance": 500
    }
) }}