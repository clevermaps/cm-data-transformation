# CleverMaps Transformations

This repository contains a library of standard dbt macros providing high-level spatial tasks built on top of atomic ST_* functions.
The goal is to simplify, speed up, and standardize the implementation of common spatial analytics across data pipelines.
Instead of repeatedly writing low-level spatial SQL, the library offers reusable task-oriented macros that can be easily integrated into existing dbt-based transformation workflows.

Key Characteristics:
- Implemented as pure dbt macros
- Built from atomic spatial (ST_*) functions
- Focused on high-level analytical tasks, not low-level geometry handling
- Designed for reuse across projects
- Easy to compose inside standard dbt models and CTEs


## Functions

    /
    ├── agg/         # Spatial data aggregations
    ├── enrich/      # Data enrichment based on spatial relationships
    ├── filter/      # Filtering data by spatial relationships
    ├── find/        # Finding neighbors and nearest features
    ├── gen/         # Generating new spatial objects
    └── cluster/     # Geometry clusterization

[Functions details](docs/dbt_macros_docs.md)

## Install

Add following to your packages.yml inside your dbt project:
```
packages:
  - git: "https://github.com/clevermaps/cm-data-transformation.git"
    subdirectory: "dbt/"
```

and run:
```
dbt deps
```

## Example

```
{{ cm_dbt_macros.aggregate_by_region(
    left_source={
      "table": ref('stg_geobnd__adm4'),
      "geometry": "geom"
    },
    right_source={
      "table": ref('stg_worldpop__pop'),
      "geometry": "geom"
    },
    options={
      "agg": "sum(pop) as pop_sum"
    }
) }}
```