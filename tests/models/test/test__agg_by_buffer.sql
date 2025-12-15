
{{ cm_dbt_macros.aggregate_by_buffer(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    right_source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "buffer_size": 500,
      "agg": "count(b.id) as place_count"
    }
) }}