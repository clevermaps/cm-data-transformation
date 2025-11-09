# 🗺️ Spatial SQL Functions Framework

Tento modul obsahuje sadu SQL funkcí pro prostorové analýzy a datové transformace.
Cílem je zpřístupnit běžné **spatial analytické operace** v jednoduché, jednotné a
uživatelsky srozumitelné formě – bez nutnosti hlubokých GIS znalostí.

Každá funkce je implementována jako samostatný `.sql` soubor a je zařazena
do tematické podsložky podle typu operace.

---

## 📁 Struktura adresářů

```
spatial/
├── agg/         # Agregace prostorových dat
├── enrich/      # Obohacování dat na základě prostorových vztahů
├── filter/      # Filtrování dat podle prostorových vztahů
├── find/        # Hledání sousedství a nejbližších objektů
├── gen/         # Generování nových prostorových objektů
├── analyze/     # (volitelné) Pokročilé analýzy a metriky
└── utils/       # (volitelné) Pomocné a H3 utility funkce
```

---

## 🔹 Naming konvence

Každý SQL soubor odpovídá jedné „funkci“ ve stylu:
```
<action>_<context>.sql
```

| Prefix (akce) | Význam |
|----------------|--------|
| `generate_` | vytváří novou geometrii nebo grid |
| `filter_by_` | vybírá subset dat podle prostorového vztahu |
| `find_` | hledá sousední nebo nejbližší prvky |
| `enrich_by_` | přidává nové atributy na základě prostorového vztahu |
| `aggregate_` | shrnuje nebo seskupuje data podle prostorových jednotek |
| `compute_` | (v analyze/) vypočítává metriky nebo skóre |
| `assign_` | (v utils/) přidává technické ID, např. H3 index |

---

## 🧩 Přehled existujících funkcí

### **agg/**
| Funkce | Popis |
|---------|--------|
| `aggregate_by_region.sql` | Agreguje hodnoty vrstvy B podle polygonů vrstvy A (např. regionů). |
| `aggregate_within_buffer.sql` | Agreguje hodnoty z okolí (bufferu) kolem bodů nebo polygonů. |

### **enrich/**
| Funkce | Popis |
|---------|--------|
| `enrich_by_overlap.sql` | Přidá do tabulky A atributy z tabulky B podle prostorového průniku. |

### **filter/**
| Funkce | Popis |
|---------|--------|
| `filter_by_overlap.sql` | Vybere jen prvky A, které se prostorově překrývají s vrstvou B. |

### **find/**
| Funkce | Popis |
|---------|--------|
| `find_nearest_neighbors.sql` | Najde nejbližší objekty z vrstvy B ke každému prvku vrstvy A. |
| `find_nearest_neighbors_avg.sql` | Stejné jako výše, ale s průměrováním metrik více sousedů. |

### **gen/**
| Funkce | Popis |
|---------|--------|
| `generate_buffer.sql` | Vytvoří buffer kolem bodů nebo polygonů. |
| `generate_grid_h3.sql` | Vygeneruje H3 grid podle zadané geometrie. |
| `generate_grid_around_h3.sql` | Vygeneruje H3 buňky v okolí daného H3 indexu (k-ring). |
| `generate_grid_within_h3.sql` | Vygeneruje H3 buňky pokrývající zadaný polygon. |

---

## ⚙️ Doporučené budoucí rozšíření

### **analyze/**
Funkce pro výpočet metrik a pokročilých prostorových analýz:
- `compute_coverage_ratio.sql` — podíl plochy pokrytí mezi vrstvami  
- `compute_density.sql` — prostorová hustota bodů nebo událostí  
- `compute_accessibility_score.sql` — skóre dostupnosti dle více faktorů  
- `compare_spatial_layers.sql` — porovnání dvou prostorových vrstev  

### **utils/**
Pomocné funkce, zejména pro práci s H3 gridem:
- `assign_h3_index.sql` — přidání H3 indexu podle geometrie  
- `h3_to_polygon.sql` — převod H3 ID na polygon  
- `h3_to_parent.sql` — převod na hrubší úroveň H3 gridu  
- `h3_to_children.sql` — rozpad na jemnější úroveň H3 gridu  

---

## 🧠 Design principy

1. **Jednoduchost:**  
   Každá funkce řeší jednoznačně definovanou úlohu.  
   Syntaxe i názvy jsou navržené tak, aby byly srozumitelné i ne-GIS analytikům.

2. **Modularita:**  
   Funkce jsou organizovány podle typu operace, aby bylo možné je snadno kombinovat
   (např. `generate_buffer` → `aggregate_within_buffer` → `enrich_by_overlap`).

3. **Konzistence:**  
   Název funkce odpovídá názvu souboru a obsahuje prefix akce (`generate_`, `filter_by_`, …).  
   Argumenty a názvy sloupců se drží jednotného pojmenování (`geom`, `id`, `value`, `metric_*`).

4. **Kompatibilita:**  
   Funkce jsou psány v SQL kompatibilním s běžnými spatial enginy (např. PostGIS, DuckDB, BigQuery GIS).  
   Tam, kde je to možné, jsou použity standardní geometrické operátory (`ST_Intersects`, `ST_Distance`, `ST_Buffer` atd.).

---

## 💡 Příklady kombinací funkcí

```sql
-- Vyber parcely, které se protínají se silnicemi
SELECT * FROM filter_by_overlap('parcely', 'silnice');

-- Agreguj počet POI v okolí zastávek MHD (100 m buffer)
SELECT * FROM aggregate_within_buffer('zastavky', 'poi', 100);

-- Obohať regiony o počet obyvatel z vrstvy gridu
SELECT * FROM enrich_by_overlap('regiony', 'population_grid');
```

---

## 📚 Další plány

- Přidat podporu pro časové a grid-based funkce (H3, S2, isochrony)
- Doplnit `analyze/` modul s metrikami dostupnosti, pokrytí a výkonu
- Přidat `utils/` modul s převody mezi geometriemi, gridy a regiony
- Vytvořit jednoduchý Python wrapper pro volání funkcí z dbt nebo SQL API

---

## ✍️ Autorství

Tento framework vzniká jako součást **Location Intelligence / Spatial Analytics** nástrojů
a je určen pro analytiky, kteří chtějí používat prostorové funkce
v běžných SQL workflowech bez složité GIS infrastruktury.

---
