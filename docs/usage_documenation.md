# DBT Macro Usage Documentation

This document provides descriptions and usage examples for the DBT macros available in this project.

---

## Overview of Macros

- aggregate_by_buffer
- aggregate_by_region
- enrich_by_overlap
- enrich_by_nearest
- filter_by_distance
- filter_by_overlap
- find_nearest_avg
- find_nearest_n
- generate_buffer
- generate_grid_h3
- generate_grid_h3_poly
- generate_grid_h3_ring
- generate_voronoi

---

## aggregate_by_buffer

**Description:**  
Aggregates data from `from` table by the geometries from the `by` point or line table with dynamically computed buffer. The aggregation expression is specified in options.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The geometry column name.  
  - `where` (optional): Additional filter condition. 
- `by`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The geometry column name. 
  - `buffer_size`: The buffer size distance.
- `options`: Object containing:
  - `aggregations`: List of the aggregation objects.

**Example usage:**
```sql
{{ cm_dbt_macros.aggregate_by_buffer(
    from={
      "table": ref('stg__places'),
      "geometry": "geom",
      "where": "category = 'hospital'"
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
```

---

## aggregate_by_region

**Description:**  
Aggregates data from the `from` table by the geometries from the `by` polygon table where the geometries intersect. The aggregation expression is specified in options.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The geometry column name.
  - `where` (optional): Additional filter condition.    
- `by`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The geometry column name.
- `options`: Object containing:
  - `aggregations`: List of the aggregation objects.

**Example usage:**
```sql
{{ cm_dbt_macros.aggregate_by_region(
    from={
      "table": ref('stg__places'),
      "geometry": "geom",
      "where": "category = 'hospital'"
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
```

---


## enrich_by_overlap

**Description:**
Enriches the `from` table by joining columns with `by` table with those geometries that spatially intersect.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The geometry column name.
  - `id`: The ID column name.  
- `by`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `id`: The ID column name.
  - `columns`: A mapping of by table columns to output column names.  
- `options`: Object (currently unused)

**Example usage:**
```sql
{{ cm_dbt_macros.enrich_by_nearest(
    from={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    by={
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

## enrich_by_nearest

**Description:**  
Enriches the from the `from` table by joining columns with the `by` table with the nearest matching feature, within a maximum distance. Uses the `find_nearest_n` macro internally with `max_neighbours` set to 1.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `id`: The ID column name.  
- `by`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `id`: The ID column name.
  - `columns`: A mapping of by table columns to output column names.  
- `options`: Object containing:
  - `max_distance`: Maximum distance to consider for nearest neighbor.

**Example usage:**
```sql
{{ cm_dbt_macros.enrich_by_nearest(
    from={
      "table": ref('stg__stops'),
      "geometry": "geom",
      "id": "stop_id"
    },
    by={
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

## filter_by_distance

**Description:**  
Filters rows from the `from` table by the `by` table to those whose geometries intersect with a buffer around geometries. The buffer size is specified in the options.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.  
- `by`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `where` (optional): Additional filter condition.  
- `options`: Object containing:
  - `distance`: Buffer distance in meters.

**Example usage:**
```sql
{{ cm_dbt_macros.filter_by_distance(
    from={
      "table": ref('stg__places'),
      "geometry": "geom"
    },
    by={
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
Filters rows from the `from` table to those whose geometries spatially intersect with geometries of the `by` table. An optional filter can be applied to the right from table.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.  
- `by`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `where` (optional): Additional filter condition.  
- `options`: Object (currently unused).

**Example usage:**
```sql
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
```

---

## find_nearest_avg

**Description:**  
Finds the nearest N neighbors from the `to` table for each row from from the `from` table within a maximum distance and computes average distance from N neighbors.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The geometry column name.
  - `id`: The ID column name.  
- `to`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `id`: The ID column name.
  - `where` (optional): Additional filter condition.  
- `options`: Object containing:
  - `max_distance`: Maximum distance to consider.
  - `max_neighbours`: Maximum number of neighbors to consider.

**Example usage:**
```sql
{{ cm_dbt_macros.find_nearest_avg(
    from={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id"
    },
    to={
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
Finds the nearest N neighbors from the `to` table for each row from the `from` table within a maximum distance.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column .
  - `id`: The ID column name.  
- `to`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The geometry column name.
  - `id`: The ID column name.
  - `where` (optional): Additional filter condition.  
- `options`: Object containing:
  - `max_distance`: Maximum distance to consider.
  - `max_neighbours`: Maximum number of neighbors to return.

**Example usage:**
```sql
{{ cm_dbt_macros.find_nearest_n(
    from={
      "table": ref('stg__places'),
      "geometry": "geom",
      "id": "id"
    },
    to={
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

## generate_grid_h3_poly

**Description:**  
Generates H3 grid cells covering polygons of the `from` polygon table at a specified H3 resolution. Returns the H3 cell ID, its WKT boundary, and geometry.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table.
  - `id`: The ID column name in the from table.
  - `geometry`: The polygon geometry column name.  
- `options`: Object containing:
  - `h3_res`: The H3 resolution level.

**Example usage:**
```sql
{{ cm_dbt_macros.generate_grid_h3_poly(
    from={
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

## generate_grid_h3

**Description:**  
Generates H3 grid cells for points of the `from` table at a specified H3 resolution. Returns the H3 cell ID for each point.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table.
  - `geometry`: The point geometry column name.  
- `options`: Object containing:
  - `h3_res`: The H3 resolution level.

**Example usage:**
```sql
{{ cm_dbt_macros.generate_grid_h3(
    from={
      "table": "stg__stops",
      "geometry": "geom"
    },
    options={
      "h3_res": 7
    }
) }}
```

---

## generate_grid_h3_ring

**Description:**  
Generates a ring of H3 cells around each H3 cell from the `from` table at the specified H3 resolution and ring size.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The point geometry column name.
  - `id` (optional): The ID column name.  
- `options`: Object containing:
  - `h3_res`: The H3 resolution level.
  - `h3_ring_size`: The size of the ring around each H3 cell.

**Example usage:**
```sql
{{ cm_dbt_macros.generate_grid_h3_ring(
    from={
      "table": "stg__stops",
      "geometry": "geom",
      "id": "shape_id"
    },
    options={
      "h3_res": 7,
      "h3_ring_size": 2
    }
) }}
```

---

## generate_voronoi

**Description:**  
Generates a Voronoi diagram from the union of geometries in the `from` table. Returns the Voronoi polygons as individual geometries.

**Parameters:**  
- `from`: Object containing:
  - `table`: The name of the table..
  - `geometry`: The point geometry column name.  
- `options`: Object (currently unused).

**Example usage:**
```sql
{{ cm_dbt_macros.generate_voronoi(
    from={
      "table": "stg__stops",
      "geometry": "geom"
    },
    options={
      
    }
) }}
