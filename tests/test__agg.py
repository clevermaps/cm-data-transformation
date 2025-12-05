from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")
operations.custom_sql('create schema if not exists test;')

# Test that function finished without errors - DONE
# Test if results are not empty - TODO

def test_agg_within_buffer() -> None:
    operations.agg.aggregate_within_buffer(
        left_source={"table": "gtfs_stg.stops", "geometry": "geom"},
        right_source={"table": "ovm_stg.places_place", "geometry": "geom", "id": "id"},
        target={"table": "test.test_agg_within_buffer"},
        options={"buffer_size": 300, "agg": "count(id) AS poi_count"}
    )

def test_agg_by_region() -> None:
    operations.agg.aggregate_by_region(
        left_source={"table": "geobnd_stg.geoboundaries__adm4", "geometry": "geom"},
        right_source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "id"},
        target={"table": "test.test_agg_by_region"},
        options={"agg": "count(stop_id) AS stops_count"}
    )
