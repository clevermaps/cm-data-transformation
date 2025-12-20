
{{ cm_dbt_macros.aggregate_by_region(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    by={
      "table": ref('stg__geoboundaries'),
      "geometry": "geom"
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