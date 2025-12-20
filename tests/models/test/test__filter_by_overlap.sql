
{{ cm_dbt_macros.filter_by_overlap(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    by={
      "table": ref('stg__geoboundaries'),
      "geometry": "geom",
      "where": "shape_name = 'Ivancice'"
    },
    options={
      
    }
) }}