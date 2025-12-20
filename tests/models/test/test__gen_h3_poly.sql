
{{ cm_dbt_macros.generate_grid_h3(
    from={
      "table": "stg__geoboundaries", 
      "geometry": "geom", 
      "id": "shape_id"
    },
    options={
      "h3_res": 7
    }
) }}