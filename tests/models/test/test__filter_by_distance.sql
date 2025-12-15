
{{ cm_dbt_macros.filter_by_distance(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    right_source={
      "table": ref('stg__stops'),
      "geometry": "geom"
    },
    options={
      "distance": 500
    }
) }}