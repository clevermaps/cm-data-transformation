# DBT Macro Usage Documentation

This document provides descriptions and usage examples for the DBT macros available in this project.

---

## filter_by_distance

**Description:**  
Filters rows from the left source table to those whose geometries intersect with a buffer around geometries from the right source table. The buffer size is specified in the options.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `where` (optional): Additional filter condition for the right source table.  
- `options`: Object containing:
  - `distance`: Buffer distance in the units of the coordinate system.

**Example usage:**
```sql
{{ cm_dbt_macros.filter_by_distance(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    right_source={
      "table": ref('stg__stops'),
      "geometry": "geom"
    },
    options={
      "distance": 500
    }
) }}
```

---

## filter_by_overlap

**Description:**  
Filters rows from the left source table to those whose geometries spatially intersect with geometries from the right source table. An optional filter can be applied to the right source table.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `where` (optional): Additional filter condition for the right source table.  
- `options`: Object (currently unused).

**Example usage:**
```sql
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
```

---

## enrich_by_nearest

**Description:**  
Enriches the left source table by joining columns from the nearest matching row in the right source table, within a maximum distance. Uses the `find_nearest_n` macro internally with `max_neighbours` set to 1.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.
  - `id`: The ID column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `id`: The ID column name in the right source table.
  - `columns`: A mapping of right source columns to output column names.  
- `options`: Object containing:
  - `max_distance`: Maximum distance to consider for nearest neighbor.

**Example usage:**
```sql
{{ cm_dbt_macros.enrich_by_nearest(
    left_source={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    right_source={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id",
      "columns": {"id": "poi_id", "name": "poi_name"}
    },
    options={
      "max_distance": 500
    }
) }}
```

---

## generate_buffer

**Description:**  
Generates a buffer geometry column around the geometries in the source table, with a specified buffer size and output column name.

**Parameters:**  
- `source`: Object containing:
  - `table`: The source table reference.
  - `geometry`: The geometry column name in the source table.  
- `options`: Object containing:
  - `buffer_size`: The buffer size distance.
  - `buffer_column`: The name of the output buffer column.

**Example usage:**
```sql
{{ cm_dbt_macros.generate_buffer(
    source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "buffer_size": 500,
      "buffer_column": "buffer"
    }
) }}
```

---

## generate_grid_h3

**Description:**  
Generates an H3 grid cell ID column for each geometry in the source table at a specified H3 resolution.

**Parameters:**  
- `source`: Object containing:
  - `table`: The source table reference.
  - `geometry`: The geometry column name in the source table.  
- `options`: Object containing:
  - `h3_res`: The H3 resolution level.

**Example usage:**
```sql
{{ cm_dbt_macros.generate_grid_h3(
    source={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    options={
      "h3_res": 7
    }
) }}
```

---

## generate_grid_h3_poly

**Description:**  
Generates H3 grid cells covering polygons from the source table at a specified H3 resolution. Returns the H3 cell ID, its WKT boundary, and geometry.

**Parameters:**  
- `source`: Object containing:
  - `id`: The ID column name in the source table.
  - `geometry`: The geometry column name in the source table.  
- `options`: Object containing:
  - `h3_res`: The H3 resolution level.

**Example usage:**
```sql
{{ cm_dbt_macros.generate_grid_h3(
    source={
      "table": "stg__geoboundaries", 
      "geometry": "geom", 
      "id": "shape_id"
    },
    options={
      "h3_res": 7
    }
) }}
```

---

## aggregate_by_buffer

**Description:**  
Aggregates data from the right source table joined to the left source table where the left geometries intersect with a buffer around the left geometries. The aggregation expression is specified in options.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `where` (optional): Additional filter condition for the right source table.  
- `options`: Object containing:
  - `buffer_size`: The buffer size distance.
  - `agg`: The aggregation SQL expression.

**Example usage:**
```sql
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
```

---

## aggregate_by_region

**Description:**  
Aggregates data from the right source table joined to the left source table where the geometries intersect. The aggregation expression is specified in options.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `where` (optional): Additional filter condition for the right source table.  
- `options`: Object containing:
  - `agg`: The aggregation SQL expression.

**Example usage:**
```sql
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
```

---

## find_nearest_avg

**Description:**  
Finds the average distance to the nearest neighbors from the right source table for each row in the left source table within a maximum distance and number of neighbors.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.
  - `id`: The ID column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `id`: The ID column name in the right source table.
  - `where` (optional): Additional filter condition for the right source table.  
- `options`: Object containing:
  - `max_distance`: Maximum distance to consider.
  - `max_neighbours`: Maximum number of neighbors to consider.

**Example usage:**
```sql
{{ cm_dbt_macros.find_nearest_avg(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id"
    },
    right_source={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    options={
      "max_distance": 500,
      "max_neighbours": 20
    }
) }}
```

---

## find_nearest_n

**Description:**  
Finds the nearest N neighbors from the right source table for each row in the left source table within a maximum distance.

**Parameters:**  
- `left_source`: Object containing:
  - `table`: The left source table reference.
  - `geometry`: The geometry column name in the left source table.
  - `id`: The ID column name in the left source table.  
- `right_source`: Object containing:
  - `table`: The right source table reference.
  - `geometry`: The geometry column name in the right source table.
  - `id`: The ID column name in the right source table.
  - `where` (optional): Additional filter condition for the right source table.  
- `options`: Object containing:
  - `max_distance`: Maximum distance to consider.
  - `max_neighbours`: Maximum number of neighbors to return.

**Example usage:**
```sql
{{ cm_dbt_macros.find_nearest_n(
    left_source={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id"
    },
    right_source={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    options={
      "max_distance": 500,
      "max_neighbours": 20
    }
) }}
```

---

## aggregate_by_union

**Description:**  
*No implementation available.*

**Parameters:**  
- `source`: Object (not specified).  
- `options`: Object (not specified).

**Example usage:**  
*No example available.*

---

## generate_grid_h3_ring

**Description:**  
*No implementation available.*

**Parameters:**  
- `source`: Object (not specified).  
- `options`: Object (not specified).

**Example usage:**  
*No example available.*
