# Dokumentace volání metod ve třídě `Operations`

Tato dokumentace popisuje všechny metody třídy `Operations` a jejich volání s využitím Python slovníků, které jsou interně převedeny na Pydantic modely pro validaci a typovou kontrolu. Data z těchto modelů jsou následně předána do Jinja2 šablon pro generování SQL dotazů.

---

## Obecné informace

- Vstupní parametry metod jsou Python slovníky (`dict`), které odpovídají struktuře definované v Pydantic modelech.
- Interně jsou tyto slovníky převedeny na Pydantic modely, což zajišťuje validaci a správný formát dat.
- Pro generování SQL se používají Jinja2 šablony, do kterých jsou předávány slovníky s daty.
- Uživatelé tedy volají metody s Python slovníky, které musí obsahovat potřebné klíče a hodnoty podle popisu níže.

---

## Použité Pydantic modely a jejich struktura

### `TableConfig`

Konfigurace tabulky:

| Klíč      | Typ    | Popis                      |
|-----------|---------|----------------------------|
| `table`   | `str`   | Název tabulky              |
| `geometry`| `str`   | Název sloupce s geometrií  |
| `id`      | `str` (volitelný) | Identifikátor záznamu |

### `FilterByOverlapOptions`

Parametry pro filtraci podle překryvu:

| Klíč      | Typ    | Popis                      |
|-----------|---------|----------------------------|
| (dle definice modelu) | | |

### `FilterWithinDistanceOptions`

Parametry filtru podle vzdálenosti:

| Klíč      | Typ    | Popis                      |
|-----------|---------|----------------------------|
| `distance`| `int`   | Vzdálenost v metrech       |

### `AggregateWithinBufferOptions`

Parametry agregace v bufferu:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| `buffer_size`| `int`  | Velikost bufferu v metrech |
| `agg`       | `str`   | Agregační SQL výraz        |

### `AggregateByRegionOptions`

Parametry agregace podle regionu:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| `agg`       | `str`   | Agregační SQL výraz        |

### `GenerateBufferOptions`

Parametry generování bufferu:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| (dle definice modelu) | | |

### `GenerateH3Options`

Parametry generování H3 gridu:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| (dle definice modelu) | | |

### `GenerateH3WithinOptions`

Parametry generování H3 gridu uvnitř oblasti:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| (dle definice modelu) | | |

### `FindNearestN`

Parametry pro hledání nejbližších N:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| (dle definice modelu) | | |

### `FindNearestAvg`

Parametry pro hledání průměrné vzdálenosti:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| (dle definice modelu) | | |

### `AddWithOverlap`

Parametry pro přidání s překryvem:

| Klíč        | Typ    | Popis                      |
|-------------|---------|----------------------------|
| (dle definice modelu) | | |

---

## Metody třídy `Operations`

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

- **Popis:** Filtruje záznamy na základě prostorového překryvu mezi `left_source` a `right_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `FilterByOverlapOptions`.
- **Příklad volání:**

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

- **Popis:** Filtruje záznamy z `left_source` na základě vzdálenosti od záznamů v `right_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `FilterWithinDistanceOptions`.
- **Příklad volání:**

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

- **Popis:** Filtruje záznamy z `left_source` na základě vzdálenosti k záznamům v `right_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `FilterWithinDistanceOptions`.
- **Příklad volání:** Analogické jako u `filter_within_distance_from`.

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

- **Popis:** Agreguje data z `right_source` v bufferu kolem záznamů z `left_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `AggregateWithinBufferOptions`.
- **Příklad volání:**

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

- **Popis:** Agreguje data z `right_source` podle regionů definovaných v `left_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `AggregateByRegionOptions`.
- **Příklad volání:**

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

- **Popis:** Generuje buffer kolem geometrie ve zdrojové tabulce.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `GenerateBufferOptions`.
- **Příklad volání:**

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

- **Popis:** Generuje H3 grid nad zdrojovou geometrií.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `GenerateH3Options`.
- **Příklad volání:** Analogické jako u `generate_buffer`.

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

- **Popis:** Generuje H3 grid uvnitř oblasti definované zdrojovou geometrií.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `GenerateH3WithinOptions`.
- **Příklad volání:** Analogické jako u `generate_buffer`.

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

- **Popis:** Najde N nejbližších záznamů z `right_source` pro každý záznam v `left_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `FindNearestAvg`.
- **Příklad volání:**

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

- **Popis:** Vypočítá průměrnou vzdálenost k nejbližším záznamům z `right_source` pro každý záznam v `left_source`.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `FindNearestN`.
- **Příklad volání:** Analogické jako u `find_nearest_n`.

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

- **Popis:** Přidá data z `right_source` do `left_source` na základě prostorového překryvu.
- **Parametry:** Slovníky odpovídající modelům `TableConfig` a `AddWithOverlap`.
- **Příklad volání:**

```python
left_source = {"table": "...", "geometry": "..."}
right_source = {"table": "...", "geometry": "...", "id": "..."}
target = {"table": "..."}
options = {...}

operations.add.add_with_overlap(left_source, right_source, target, options)
```

---

## Shrnutí

- Všechny metody přijímají na vstupu Python slovníky odpovídající struktuře Pydantic modelů.
- Interní převod na Pydantic modely zajišťuje validaci a správný formát dat.
- SQL dotazy jsou generovány pomocí Jinja2 šablon, které očekávají proměnné odpovídající klíčům ve slovnících.
- Uživatelé tedy pracují s jednoduchými slovníky, které musí obsahovat potřebné klíče a hodnoty dle výše uvedených struktur.
