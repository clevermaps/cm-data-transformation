from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")
operations.custom_sql('create schema if not exists test;')

def test_filter_within_distance_from() -> None:

    operations.filter.filter_within_distance(
        left_source={"table": "ovm_stg.places_place", "geometry": "geom"},
        right_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"},
        target={"table": "test.test_filter_within_distance_from"},
        options={"distance": 500}
    )

# def test_filter_by_overlap() -> None:

#     operations.filter.filter_by_overlap(
#         left_source={"table": "ovm_stg.places_place", "geometry": "geom"},
#         right_source={"table": "worldpop_stg.population", "geometry": "geom", "id": "id"},
#         target={"table": "test.test_filter_by_overlap"},
#     )