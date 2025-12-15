# DBT Macros Documentation

This document lists all DBT macros found in the `dbt/macros` directory, along with their parameters and sub-keys extracted from the SQL Jinja code.

---

## aggregate_by_buffer

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
- `right_source`
  - `table`
  - `geometry`
  - `where` (optional)
- `options`
  - `agg`
  - `buffer_size`

**Description:**
Performs a spatial aggregation by buffering geometries from the left source and joining with the right source within the buffer distance.

---

## aggregate_by_region

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
- `right_source`
  - `table`
  - `geometry`
  - `where` (optional)
- `options`
  - `agg`

**Description:**
Aggregates data by region using spatial intersection between left and right sources.

---

## find_nearest_avg

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
  - `id`
- `right_source`
  - `table`
  - `geometry`
  - `id`
  - `where` (optional)
- `options`
  - `max_distance`
  - `max_neighbours`

**Description:**
Finds the average distance to the nearest features from the right source for each feature in the left source.

---

## find_nearest_n

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
  - `id`
- `right_source`
  - `table`
  - `geometry`
  - `id`
  - `where` (optional)
- `options`
  - `max_distance`
  - `max_neighbours`

**Description:**
Finds the nearest N features from the right source for each feature in the left source.

---

## generate_buffer

**Parameters:**
- `source`
  - `table`
  - `geometry`
- `options`
  - `buffer_size`
  - `buffer_column`

**Description:**
Generates a buffer geometry around features in the source table.

---

## generate_grid_h3

**Parameters:**
- `source`
  - `table`
  - `geometry`
- `options`
  - `h3_res`

**Description:**
Generates H3 grid cell IDs for features in the source table.

---

## enrich_by_nearest

**Parameters:**
- `left_source`
  - `table`
  - `id`
- `right_source`
  - `table`
  - `id`
  - `columns` (dictionary of column mappings)
- `options`

**Description:**
Enriches the left source with attributes from the nearest feature in the right source.

---

## enrich_by_overlap

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
- `right_source`
  - `table`
  - `geometry`
  - `columns` (dictionary of column mappings)
  - `where` (optional)
- `options`

**Description:**
Enriches the left source with attributes from overlapping features in the right source.

---

## filter_by_distance

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
- `right_source`
  - `table`
  - `geometry`
  - `where` (optional)
- `options`
  - `distance`

**Description:**
Filters features in the left source that are within a specified distance of features in the right source.

---

## filter_by_overlap

**Parameters:**
- `left_source`
  - `table`
  - `geometry`
- `right_source`
  - `table`
  - `geometry`
  - `where` (optional)
- `options`

**Description:**
Filters features in the left source that spatially overlap with features in the right source.

---

## generate_grid_h3_poly

**Parameters:**
- `source`
  - `table`
  - `id`
  - `geometry`
- `options`
  - `h3_res`

**Description:**
Generates H3 grid polygons for features in the source table.

---

## cluster_by_distance

**Parameters:**
- `source`
  - `table`
  - `geometry`
- `options`

**Description:**
Clusters features based on distance criteria.

---

## generate_grid_h3_ring

**Parameters:**
- `source`
- `options`

**Description:**
Macro defined but no implementation provided.

---

## aggregate_by_grid_h3

**Parameters:**
- `source`
- `options`

**Description:**
Macro defined but no implementation provided.

---

## generate_voronoi

**Parameters:**
- `source`
- `options`

**Description:**
Macro defined but no implementation provided.

---

## aggregate_by_union

**Parameters:**
- Not available (file empty or no macro content)

**Description:**
Macro file empty or no implementation found.

---
