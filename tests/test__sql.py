from cm_data_transformation.operations import Operations

operations = Operations("duckdb:///../data/data.duckdb")

def test_custom_sql_expression():

    operations.custom_sql("SELECT count(1) from gtfs_stg.stops")


def test_custom_sql_file():

    operations.custom_sql_file("./test.sql")