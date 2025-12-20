
{{ cm_dbt_macros.aggregate_by_buffer(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    by={
      "table": ref('stg__places'),
      "geometry": "geom",
      "buffer_size": 500
    },
    options={
      "aggregations": [
        {
          "function": "count",
          "column": "id",
          "result": "place_count"
        }
      ]
    }
) }}