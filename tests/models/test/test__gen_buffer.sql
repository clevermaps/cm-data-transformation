
{{ cm_dbt_macros.generate_buffer(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "buffer_size": 500,
      "buffer_column": "buffer"
    }
) }}