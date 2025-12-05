from jinja2 import Template
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

import logging

from prefect import task

from .models.tables import TableConfig
from .models.options import AggregateWithinBufferOptions, AggregateByRegionOptions, \
    FilterWithinDistanceOptions, FilterByOverlapOptions, GenerateBufferOptions, \
    GenerateH3Options, GenerateH3WithinOptions, FindNearestAvg, FindNearestN, AddWithOverlap

from .db import init_duckdb

BASE_DIR = Path(__file__).resolve().parent
SQL_DIR = BASE_DIR / "sql"


logger = logging.getLogger(__name__)

class Operations:

    class Filter:
        def __init__(self, parent):
            self.parent = parent

        def filter_by_overlap(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': FilterByOverlapOptions(**options)
            }
            
            self.parent.run_template_sql("agg/filter_by_overlap.sql", config)

        @task(cache_policy=None)
        def filter_within_distance(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': FilterWithinDistanceOptions(**options)
            }
            
            self.parent.run_template_sql("filter/filter_within_distance.sql", config)

    class Aggregate:
        def __init__(self, parent):
            self.parent = parent

        @task(cache_policy=None)
        def aggregate_within_buffer(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': AggregateWithinBufferOptions(**options)
            }
            
            self.parent.run_template_sql("agg/aggregate_within_buffer.sql", config)

        @task(cache_policy=None)
        def aggregate_by_region(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': AggregateByRegionOptions(**options)
            }
            
            self.parent.run_template_sql("agg/aggregate_by_region.sql", config)


    class Generate:
        def __init__(self, parent):
            self.parent = parent

        @task(cache_policy=None)
        def generate_buffer(self, source: dict, target: dict, options: dict):

            config = {
                'source': TableConfig(**source),
                'target': TableConfig(**target),
                'options': GenerateBufferOptions(**options)
            }

            self.parent.run_template_sql("gen/generate_buffer.sql", config)

        def generate_grid_h3(self, source: dict, target: dict, options: dict):

            config = {
                'source': TableConfig(**source),
                'target': TableConfig(**target),
                'options': GenerateH3Options(**options)
            }

            self.parent.run_template_sql("gen/generate_grid_h3.sql", config)

        def generate_grid_within_h3(self, source: dict, target: dict, options: dict):

            config = {
                'source': TableConfig(**source),
                'target': TableConfig(**target),
                'options': GenerateH3WithinOptions(**options)
            }

            self.parent.run_template_sql("gen/generate_grid_within_h3.sql", config)

    class Find:
        def __init__(self, parent):
            self.parent = parent

        def find_nearest_n(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': FindNearestAvg(**options)
            }

            self.parent.run_template_sql("find/find_nearest_n.sql", config)

        def find_nearest_avg(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': FindNearestN(**options)
            }

            self.parent.run_template_sql("find/find_nearest_avg.sql", config)

    class Add:
        def __init__(self, parent):
            self.parent = parent

        def add_with_overlap(self, left_source: dict, right_source: dict, target: dict, options: dict):

            config = {
                'left_source': TableConfig(**left_source),
                'right_source': TableConfig(**right_source),
                'target': TableConfig(**target),
                'options': AddWithOverlap(**options)
            }

            self.parent.run_template_sql("add/add_with_overlap.sql", config)

        # TODO add_with_overlap

    def __init__(self, connection_string: str):
        
        self.engine: Engine = create_engine(connection_string)
        
        if self.engine.name == "duckdb":
            init_duckdb(self.engine, SQL_DIR)
            self.sql_dir = SQL_DIR / "duckdb"
        else:
            raise ValueError('Unsupported DB engine {}'.format(self.engine.name))
        
        self.filter = self.Filter(self)
        self.agg = self.Aggregate(self)
        self.gen = self.Generate(self)
        self.find = self.Find(self)
        self.add = self.Add(self)

    def render_template(self, template_name: str, params: dict) -> str:

        template_path = self.sql_dir / template_name
        with open(template_path, "r") as f:
            template = Template(f.read())

        return template.render(**params)
    
    def sql_execute(self, sql: str):
        with self.engine.connect() as conn:
            conn.execute(text(sql))
            conn.commit()

    def run_template_sql(self, template_name: str, params_dict: dict):

        logger.debug(params_dict)
        
        sql = self.render_template(template_name, params_dict)
        logger.debug(sql)
        self.sql_execute(sql)

    def custom_sql(self, sql: str):
        self.sql_execute(sql)

    def custom_sql_file(self, sql_file_path: str):
        file_path = Path(sql_file_path)
        if not file_path.is_file():
            raise FileNotFoundError(f"SQL file not found: {sql_file_path}")
        with open(file_path, "r") as f:
            sql = f.read()
        self.sql_execute(sql)
