from cm_data_transformation.runner import Runner


# Run operation using yaml config
runner = Runner("duckdb:///data/data.duckdb")
runner.run_yaml("./pipelines/pipeline.yaml")