
{{ cm_dbt_macros.generate_grid_h3(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "h3_res": 7
    }
) }}