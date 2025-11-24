# 🗺️ Geospatial Data Transformation Framework

This module contains a set of high-level functions for geospatial
analysis and data transformations. The goal is to make common **spatial
analytical operations** accessible in a simple, unified, and
user‑friendly form---without requiring deep GIS knowledge.

Key characteristics: 
* Computational functions are implemented using
Jinja SQL templates for various database systems. 
* Functions leverage
native capabilities of the target database systems to ensure performance
and scalability. 
* Everything is orchestrated by a Python layer
responsible for executing tasks, handling parameters, and rendering
final SQL queries. 
* The framework can be easily integrated into the
standard Python ecosystem. 
* The framework is easily extensible - both
with new functions and support for additional database systems.

------------------------------------------------------------------------

# Design Principles

1.  **Simplicity:**\
    Each function solves a clearly defined task.\
    Syntax and naming are designed to be understandable even for non‑GIS
    analysts.

2.  **Modularity:**\
    Functions are organized by operation type so they can be easily
    combined into simple data pipelines\
    (e.g., `generate_buffer` → `aggregate_within_buffer` →
    `enrich_by_overlap`).

3.  **Consistency:**\
    Function names match file names and include an action prefix
    (`generate_`, `filter_by_`, ...).\
    Arguments and column names follow consistent naming (`geom`, `id`,
    `value`, `metric_*`).

4.  **Compatibility:**\
    Functions are written using SQL compatible with major spatial
    engines (e.g., PostGIS, DuckDB, BigQuery).\
    Where possible, standard geometry operators are used
    (`ST_Intersects`, `ST_Distance`, `ST_Buffer`, etc.).

------------------------------------------------------------------------

# Quick Start

Below is a minimal set of examples showing how to run spatial operations
using this framework.\
You can choose between **imperative Python API** or **declarative YAML
pipelines**.

Both approaches rely on the same SQL + Jinja templates and produce
identical results.

------------------------------------------------------------------------

## Using Python

``` python
from cm_data_transformation.operations import Operations

# 1. Initialize the operations engine
ops = Operations("duckdb:///data/data.duckdb")

# 2. Prepare parameters for the operation
params = {
    "from": {
        "table": "gtfs_stg.stops"
    },
    "func": {
        "name": "aggregate_within_buffer",
        "options": {
            "buffer_size": 500,
            "agg": "count(id) AS poi_count"
        }
    },
    "with": {
        "table": "ovm_stg.places_place",
        "options": {
            "geometry": "geom",
            "id": "id"
        }
    },
    "to": {
        "table": "app.stops_agg_buffer_poi"
    }
}

# 3. Execute the operation
ops.agg.aggregate_within_buffer(params)
```

------------------------------------------------------------------------

## Using YAML

``` yaml
- step:
      title: "Count of POI around stops"
      from: 
        table: gtfs_stg.stops
        options:
          geometry: geom
      with:
        table: ovm_stg.places_place
        options:
          geometry: geom
          id: id
      function:
        type: aggregate_within_buffer
        options:
          buffer_size: 500
          agg: "count(id) AS poi_count"
      to:
        table: app.stops_agg_buffer_poi
```

``` python
from cm_data_transformation.runner import Runner

runner = Runner("duckdb:///data/data.duckdb")
runner.run_yaml("./pipelines/test.yaml")
```

------------------------------------------------------------------------

## What Happens Under the Hood

1.  You call a high-level operation (Python or YAML).
2.  The framework loads the corresponding Jinja SQL template.
3.  Parameters are injected to produce executable SQL.
4.  The SQL is executed in your target database.


------------------------------------------------------------------------

# Functions

    /
    ├── agg/         # Spatial data aggregations
    ├── enrich/      # Data enrichment based on spatial relationships
    ├── filter/      # Filtering data by spatial relationships
    ├── find/        # Finding neighbors and nearest features
    ├── gen/         # Generating new spatial objects
    ├── analyze/     # Advanced analyses and metrics
    └── utils/       # Helper functions

------------------------------------------------------------------------

## Naming Conventions

Each function solves one specific task in the form:

    <action>_<context>

  -----------------------------------------------------------------------
  Prefix (action)                                 Meaning
  ----------------------------------------------- -----------------------
  `generate_`                                     creates new geometry or
                                                  grid

  `filter_by_`                                    selects a subset of
                                                  data based on spatial
                                                  relationships

  `find_`                                         finds neighboring or
                                                  nearest features

  `enrich_by_`                                    adds attributes based
                                                  on spatial
                                                  relationships

  `aggregate_`                                    summarizes or groups
                                                  data by spatial units

  `compute_`                                      (in analyze/) computes
                                                  metrics or scores
                                                
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Overview of Existing Functions

### **agg/**

  ------------------------------- ----------------------------------------
  `aggregate_by_region`           Aggregates values of layer B within
                                  polygons of layer A (e.g., regions).

  `aggregate_within_buffer`       Aggregates values within a buffer around
                                  points or polygons.

  ------------------------------------------------------------------------

### **enrich/**

  ------------------------------ ----------------------------------------
  `enrich_by_overlap`            Adds attributes from layer B to layer A
                                 based on spatial overlap.

  -----------------------------------------------------------------------

### **filter/**

  ------------------------------ ----------------------------------------
  `filter_by_overlap`            Selects only elements of A that
                                 spatially overlap with layer B.

  -----------------------------------------------------------------------

### **find/**

  ---------------------------------- ----------------------------------------
  `find_nearest_neighbors`           Finds the nearest objects from layer B
                                     for each element of layer A.

  `find_nearest_neighbors_avg`       Same as above, but with averaging across
                                     multiple neighbors.
                                     
  ---------------------------------------------------------------------------

### **gen/**

  ------------------------------- ----------------------------------------
  `generate_buffer`               Creates a buffer around points or
                                  polygons.

  `generate_grid_h3`              Generates an H3 grid for a given
                                  geometry.

  `generate_grid_around_h3`       Generates H3 cells around a given H3
                                  index (k‑ring).

  `generate_grid_within_h3`       Generates H3 cells covering a given
                                  polygon.
                                  
  ------------------------------------------------------------------------

------------------------------------------------------------------------
