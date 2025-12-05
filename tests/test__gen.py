from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")
operations.custom_sql('create schema if not exists test;')

def test_generate_buffer():

    operations.gen.generate_buffer(
        source={"table": "gtfs_stg.stops", "geometry": "geom", "id": "stop_id"},
        target={"table": "test.test_generate_buffer"},
        options={"buffer_size": 300, "buffer_column": "buffer_geom"}
    )

def test_generate_grid_h3():

    operations.gen.generate_grid_h3(
        source={"table": "gtfs_stg.stops", "geometry": "geom"},
        target={"table": "test.test_generate_grid_h3"},
        options={"h3_res": 7}
    )

def test_generate_grid_within_h3():

    operations.gen.generate_grid_within_h3(
        source={"table": "geobnd_stg.geoboundaries__adm0", "geometry": "geom", "id": "shape_id"},
        target={"table": "test.test_generate_grid_within_h3"},
        options={"h3_res": 7}
    )