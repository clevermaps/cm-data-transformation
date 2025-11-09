from cm_data_transformation.runner import Runner
from cm_data_transformation.operations import Operations


## Call with YAML config

runner = Runner("duckdb:///data/data.duckdb")
#runner.run_yaml("./pipelines/test.yaml")

runner.run_yaml("./pipelines/location_evaluation.yaml")


## Call with python
operations = Operations("duckdb:///data/data.duckdb")

# operations.generate_buffer({
#   'from': {
#       'table': 'stg.gtfs__stops',
#       'options': {
#           'geometry': 'geom'
#       }
#   },
#   'func': {
#       'type': 'buffer',
#       'options': {
#           'size': 300,
#           'column': 'buffer_geom'
#       }
#   },
#   'to': {
#       'table': 'stg.gtfs__stops_buffer_300'
#   }  
# })


# operations.generate_grid_within_h3({
#   'from': {
#       'table': 'stg.geoboundaries__adm4',
#       'options': {
#           'geometry': 'geom',
#           'id': 'shape_id'
#       }
#   },
#   'func': {
#       'type': 'h3_polygon',
#       'options': {
#           'h3_res': 7
#       }
#   },
#   'to': {
#       'table': 'stg.adm_h3'
#   }  
# }
# )