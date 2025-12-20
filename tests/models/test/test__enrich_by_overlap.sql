
{{ cm_dbt_macros.enrich_by_overlap(
    from={
      "table": ref('stg__stops'),
      "geometry": "geom"
    },
    by={
      "table": ref('stg__geoboundaries'),
      "geometry": "geom",
      "columns": {"shape_name": "adm4_name", "shape_id": "adm4_id"}
    },
    options={}
) }}