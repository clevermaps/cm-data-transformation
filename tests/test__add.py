from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")
operations.custom_sql('create schema if not exists test;')

# Test that function finished without errors - DONE
# Test if results are not empty - TODO

# TODO
# def test_add_with_nearest() -> None:
#     operations.add.add_with_nearest(
#         left_source={"table": "gtfs_stg.stops", "geometry": "geom"},
#         right_source={"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"},
#         target={"table": "app.stops_with_nearest_poi"},
#         options={"max_distance": 500}
#     )

def test_add_with_overlap() -> None:
    
    operations.add.add_with_overlap(
        left_source={"table": "gtfs_stg.stops", "geometry": "geom"},
        right_source={"table": "geobnd_stg.geoboundaries__adm4", "geometry": "geom", "columns": {"shape_name": "adm4_name"}},
        target={"table": "test.test_add_with_overlap"},
        options={ }
    )
