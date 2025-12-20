
{{ cm_dbt_macros.generate_grid_h3_ring(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "h3_res": 7,
      "h3_ring_size": 1
    }
) }}