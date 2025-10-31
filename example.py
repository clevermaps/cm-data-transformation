from cm_data_transformation.operations import Operations


# dve moznosti jak spoustet - bude python funkce nebo pres yaml

operations = Operations("duckdb:///../data.duckdb")

# buffer(
#     'stg.gtfs__stops', 
#     'geom', 
#     100, 
#     'stg.gtfs__stops_buffer_100'
# )

# filter(
#     'stg.gtfs__stops', 
#     'stg.geoboundaries__adm3', 
#     'geom', 
#     'geom', 
#     "b.shape_name = 'Ivancice'", 
#     'stg.gtfs__stops_fitered'
# )

# aggregate(
#     'stg.gtfs__stops_buffer_100', 
#     'stg.ovm__places', 
#     'buffer_100', 
#     'geom', 
#     'count(b.id) as places_count', 
#     'stg.gtfs__stops_places'
# )

# nearest(
#     'stg.gtfs__stops', 
#     'stg.ovm__places', 
#     'geom', 
#     'geom',
#     'stop_id',
#     'id',
#     5000,
#     'stg.gtfs__stops_places_nearest'
# )

# grid(
#     'stg.gtfs__stops', 
#     'geom', 
#     6, 
#     'stg.gtfs__stops_grid'
# )

# operations.join(
#     'stg.gtfs__stops', 
#     'stg.geoboundaries__adm3',
#     'geom',
#     'geom', 
#     ['stop_id'],
#     [{'shape_name': 'adm_nazev'}], 
#     'stg.gtfs__stops_adm3'
# )


# Run operation using yaml config
operations.run_yaml_scenario('./scenarios/stops_accessibility.yaml')