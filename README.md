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

# Initialize the operations engine
ops = Operations("duckdb:///data/data.duckdb")

# Count of POI around stops
  ops.agg.aggregate_within_buffer(
      left_source={"table": "gtfs_stg.stops", "geometry": "geom"},
      right_source={"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"},
      target={"table": "app.gtfs__stops_agg_buffer"},
      options={"buffer_size": 300, "agg": "count(id) AS poi_count"}
  )

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
