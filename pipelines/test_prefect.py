from prefect import flow
from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")

@flow(name='Stops flow')
def stops_flow():

    # Count of POI around stops
    operations.agg.aggregate_within_buffer(
        left_source={"table": "gtfs_stg.stops", "geometry": "geom"},
        right_source={"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"},
        target={"table": "app.gtfs__stops_agg_buffer"},
        options={"buffer_size": 300, "agg": "count(id) AS poi_count"}
    )

    # Sum of population around stops
    operations.agg.aggregate_within_buffer(
        left_source={"table": "gtfs_stg.stops", "geometry": "geom"},
        right_source={"table": "worldpop_stg.population", "geometry": "geom", "id": "id"},
        target={"table": "app.stops_agg_buffer_pop"},
        options={"buffer_size": 300, "agg": "sum(pop) AS pop_sum"}
    )

    # Count of stops in admin units
    operations.agg.aggregate_by_region(
        left_source={"table": "geobnd_stg.geoboundaries__adm4", "geometry": "geom"},
        right_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "id"},
        target={"table": "app.adm_agg_stops"},
        options={"agg": "count(stop_id) AS stops_count"}
    )


@flow(name='Admin flow')
def admin_flow():

    #Sum of population in admin units
    operations.agg.aggregate_by_region(
        left_source={"table": "geobnd_stg.geoboundaries__adm4", "geometry": "geom"},
        right_source={"table": "worldpop_stg.population", "geometry": "geom", "id": "id"},
        target={"table": "app.adm_agg_pop"},
        options={"agg": "sum(pop) AS pop_sum"}
    )

    #Population within stops
    operations.filter.filter_within_distance(
        left_source={"table": "worldpop_stg.population", "geometry": "geom"},
        right_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"},
        target={"table": "app.pop_within_stops"},
        options={"distance": 500}
    )

    # Sum of population within stops in admin units
    operations.agg.aggregate_by_region(
        left_source={"table": "geobnd_stg.geoboundaries__adm4", "geometry": "geom"},
        right_source={"table": "worldpop_stg.population", "geometry": "geom", "id": "id"},
        target={"table": "app.adm_agg_pop_stops"},
        options={"agg": "sum(pop) AS pop_sum_stops"}
    )

@flow(name='H3 flow')
def h3_flow():

    # 1) Generate hexagons
    operations.gen.generate_grid_within_h3(
        source={"table": "geobnd_stg.geoboundaries__adm0", "geometry": "geom", "id": "shape_id"},
        target={"table": "app.cze_h3_res7"},
        options={"h3_res": 7}
    )

    # 2) Count of stops in admin units
    operations.agg.aggregate_by_region(
        left_source={"table": "app.cze_h3_res7", "geometry": "geom"},
        right_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "id"},
        target={"table": "app.h3_agg_stops"},
        options={"agg": "count(stop_id) AS stops_count"}
    )

    # 3) Sum of population in admin units
    operations.agg.aggregate_by_region(
        left_source={"table": "app.cze_h3_res7", "geometry": "geom"},
        right_source={"table": "worldpop_stg.population", "geometry": "geom", "id": "id"},
        target={"table": "app.h3_agg_pop"},
        options={"agg": "sum(pop) AS pop_sum"}
    )

    # 4) Population within stops
    operations.filter.filter_within_distance(
        left_source={"table": "worldpop_stg.population", "geometry": "geom", "id": "id"},
        right_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"},
        target={"table": "app.pop_within_stops"},
        options={"distance": 500, "reverse": True}
    )

    # 5) Sum of population around stops in admin units
    operations.agg.aggregate_by_region(
        left_source={"table": "app.cze_h3_res7", "geometry": "geom", "id": "shape_id"},
        right_source={"table": "app.pop_within_stops", "geometry": "geom"},
        target={"table": "app.h3_agg_pop_stops"},
        options={"agg": "sum(pop) AS pop_sum_stops"}
    )

@flow(name='Final CleverMaps dwh tables')
def cm_dwh_flow():

    operations.custom_sql_file('./sql/stops_cm.sql')
    operations.custom_sql_file('./sql/admin_cm.sql')
    operations.custom_sql_file('./sql/h3_cm.sql')

if __name__ == "__main__":
    
    # stops_flow()
    # admin_flow()
    # h3_flow()

    cm_dwh_flow()