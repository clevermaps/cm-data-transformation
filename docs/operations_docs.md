# Documentation of Method Calls in the `Operations` Class

This documentation describes all methods of the `Operations` class and their usage with Python dictionaries, which are internally converted to Pydantic models for validation and type checking. Data from these models are then passed to Jinja2 templates for generating SQL queries.

---

## General Information

- The input parameters of the methods are Python dictionaries (`dict`) that correspond to the structure defined by Pydantic models.
- Internally, these dictionaries are converted to Pydantic models, ensuring validation and correct data formatting.
- SQL queries are generated using Jinja2 templates, which receive dictionaries with data.
- Users call the methods with Python dictionaries that must contain the required keys and values as described below.

---

## Used Pydantic Models and Their Structure

### `TableConfig`

Table configuration:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| `table`   | `str`   | Table name                 |
| `geometry`| `str`   | Name of the geometry column|
| `id`      | `str` (optional) | Record identifier   |

### `FilterByOverlapOptions`

Parameters for filtering by overlap:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

### `FilterWithinDistanceOptions`

Parameters for filtering by distance:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| `distance`| `int`   | Distance in meters         |

### `AggregateWithinBufferOptions`

Parameters for aggregation within buffer:

| Key          | Type   | Description                |
|--------------|---------|----------------------------|
| `buffer_size`| `int`   | Buffer size in meters      |
| `agg`       | `str`   | Aggregation SQL expression |

### `AggregateByRegionOptions`

Parameters for aggregation by region:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| `agg`     | `str`   | Aggregation SQL expression |

### `GenerateBufferOptions`

Parameters for buffer generation:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

### `GenerateH3Options`

Parameters for generating H3 grid:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

### `GenerateH3WithinOptions`

Parameters for generating H3 grid within area:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

### `FindNearestN`

Parameters for finding nearest N:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

### `FindNearestAvg`

Parameters for finding average nearest distance:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

### `AddWithOverlap`

Parameters for adding with overlap:

| Key       | Type   | Description                |
|-----------|---------|----------------------------|
| (as defined in model) | | |

---

## Methods of the `Operations` Class

### 1. `filter_by_overlap`

```python
def filter_by_overlap(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Filters records based on spatial overlap between `left_source` and `right_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `FilterByOverlapOptions` models.
- **Example call:**

```python
left_source = {"table": "...", "geometry": "..."}
right_source = {"table": "...", "geometry": "...", "id": "..."}
target = {"table": "..."}
options = {...}

operations.filter.filter_by_overlap(left_source, right_source, target, options)
```

---

### 2. `filter_within_distance_from`

```python
def filter_within_distance_from(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Filters records from `left_source` based on distance from records in `right_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `FilterWithinDistanceOptions` models.
- **Example call:**

```python
left_source = {"table": "worldpop_stg.population", "geometry": "geom"}
right_source = {"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"}
target = {"table": "app.pop_within_stops"}
options = {"distance": 500}

operations.filter.filter_within_distance_from(left_source, right_source, target, options)
```

---

### 3. `filter_within_distance_to`

```python
def filter_within_distance_to(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Filters records from `left_source` based on distance to records in `right_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `FilterWithinDistanceOptions` models.
- **Example call:** Similar to `filter_within_distance_from`.

---

### 4. `aggregate_within_buffer`

```python
def aggregate_within_buffer(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Aggregates data from `right_source` within a buffer around records from `left_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `AggregateWithinBufferOptions` models.
- **Example call:**

```python
left_source = {"table": "gtfs_stg.stops", "geometry": "geom"}
right_source = {"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"}
target = {"table": "app.gtfs__stops_agg_buffer"}
options = {"buffer_size": 300, "agg": "count(id) AS poi_count"}

operations.agg.aggregate_within_buffer(left_source, right_source, target, options)
```

---

### 5. `aggregate_by_region`

```python
def aggregate_by_region(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Aggregates data from `right_source` by regions defined in `left_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `AggregateByRegionOptions` models.
- **Example call:**

```python
left_source = {"table": "geobnd_stg.geoboundaries__adm4", "geometry": "geom"}
right_source = {"table": "worldpop_stg.population", "geometry": "geom", "id": "id"}
target = {"table": "app.adm_agg_pop"}
options = {"agg": "sum(pop) AS pop_sum"}

operations.agg.aggregate_by_region(left_source, right_source, target, options)
```

---

### 6. `generate_buffer`

```python
def generate_buffer(
    self,
    source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Generates a buffer around geometry in the source table.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `GenerateBufferOptions` models.
- **Example call:**

```python
source = {"table": "...", "geometry": "..."}
target = {"table": "..."}
options = {...}

operations.gen.generate_buffer(source, target, options)
```

---

### 7. `generate_grid_h3`

```python
def generate_grid_h3(
    self,
    source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Generates an H3 grid over the source geometry.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `GenerateH3Options` models.
- **Example call:** Similar to `generate_buffer`.

---

### 8. `generate_grid_within_h3`

```python
def generate_grid_within_h3(
    self,
    source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Generates an H3 grid within the area defined by the source geometry.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `GenerateH3WithinOptions` models.
- **Example call:** Similar to `generate_buffer`.

---

### 9. `find_nearest_n`

```python
def find_nearest_n(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Finds the N nearest records from `right_source` for each record in `left_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `FindNearestAvg` models.
- **Example call:**

```python
left_source = {"table": "...", "geometry": "..."}
right_source = {"table": "...", "geometry": "...", "id": "..."}
target = {"table": "..."}
options = {...}

operations.find.find_nearest_n(left_source, right_source, target, options)
```

---

### 10. `find_nearest_avg`

```python
def find_nearest_avg(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Calculates the average distance to the nearest records from `right_source` for each record in `left_source`.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `FindNearestN` models.
- **Example call:** Similar to `find_nearest_n`.

---

### 11. `add_with_overlap`

```python
def add_with_overlap(
    self,
    left_source: dict,
    right_source: dict,
    target: dict,
    options: dict
)
```

- **Description:** Adds data from `right_source` to `left_source` based on spatial overlap.
- **Parameters:** Dictionaries corresponding to `TableConfig` and `AddWithOverlap` models.
- **Example call:**

```python
left_source = {"table": "...", "geometry": "..."}
right_source = {"table": "...", "geometry": "...", "id": "..."}
target = {"table": "..."}
options = {...}

operations.add.add_with_overlap(left_source, right_source, target, options)
```

---

## Summary

- All methods accept Python dictionaries as input, corresponding to the structure of Pydantic models.
- Internal conversion to Pydantic models ensures validation and correct data formatting.
- SQL queries are generated using Jinja2 templates, which expect variables matching the keys in the dictionaries.
- Users work with simple dictionaries that must contain the required keys and values as described above.
