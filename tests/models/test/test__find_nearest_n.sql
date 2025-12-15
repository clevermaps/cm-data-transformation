
{{ cm_dbt_macros.find_nearest_n(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id"
    },
    right_source={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    options={
      "max_distance": 500,
      "max_neighbours": 20
    }
) }}