from cm_data_transformation.runner import Runner
from cm_data_transformation.operations import Operations


## Call with YAML config

runner = Runner("duckdb:///data/data.duckdb")

# runner.run_yaml("./pipelines/mhd_stops.yaml")

# runner.run_yaml("./pipelines/mhd_admin.yaml")

# runner.run_yaml("./pipelines/mhd_h3.yaml")

runner.run_yaml("./pipelines/mhd_poi.yaml")

# runner.run_yaml("./pipelines/mhd_cm.yaml")


## Call with python
#operations = Operations("duckdb:///data/data.duckdb")