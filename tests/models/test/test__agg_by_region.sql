
{{ cm_dbt_macros.aggregate_by_region(
    left_source={
      "table": ref('stg__geoboundaries'),
      "geometry": "geom"
    },
    right_source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "agg": "count(b.id) as place_count"
    }
) }}