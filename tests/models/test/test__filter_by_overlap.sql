
{{ cm_dbt_macros.filter_by_overlap(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    right_source={
      "table": ref('stg__geoboundaries'),
      "geometry": "geom",
      "where": "shape_name = 'Ivancice'"
    },
    options={
      
    }
) }}