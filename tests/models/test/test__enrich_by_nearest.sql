
{{ cm_dbt_macros.enrich_by_nearest(
    left_source={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    right_source={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id",
      "columns": {"id": "poi_id", "name": "poi_name"}
    },
    options={
      "max_distance": 500
    }
) }}