from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")
operations.custom_sql('create schema if not exists test;')

def test_find_nearest_n() -> None:

    operations.find.find_nearest_n(
        left_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"},
        right_source={"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"},
        target={"table": "test.test_find_nearest_n"},
        options={"max_neighbours": 5, "max_distance": 500}
    )

def test_find_nearest_avg() -> None:

    operations.find.find_nearest_avg(
        left_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"},
        right_source={"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"},
        target={"table": "test.test_find_nearest_avg"},
        options={"max_neighbours": 5, "max_distance": 500}
    )