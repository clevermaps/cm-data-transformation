from jinja2 import Template
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
import yaml

BASE_DIR = Path(__file__).resolve().parent
SQL_DIR = BASE_DIR / "sql"


class Operations:
    """
    Operations class používá nový parametr params_dict:
    params_dict = {
        "from": {...},
        "with": {...},  # volitelné
        "func": {...},
        "to": {...}
    }
    a předává jej přímo do Jinja template.
    """

    class Filter:
        def __init__(self, parent):
            self.parent = parent

        def filter_by_overlap(self, params_dict: dict):
            self.parent.run_template_sql("filter/filter_by_overlap.sql", params_dict)

    class Aggregate:
        def __init__(self, parent):
            self.parent = parent

        def aggregate_by_region(self, params_dict: dict):
            self.parent.run_template_sql("agg/aggregate_by_region.sql", params_dict)

        def aggregate_within_buffer(self, params_dict: dict):
            self.parent.run_template_sql("agg/aggregate_within_buffer.sql", params_dict)

    class Generate:
        def __init__(self, parent):
            self.parent = parent

        def generate_buffer(self, params_dict: dict):
            self.parent.run_template_sql("gen/generate_buffer.sql", params_dict)

        def generate_grid_h3(self, params_dict: dict):
            self.parent.run_template_sql("gen/generate_grid_h3.sql", params_dict)

        def generate_grid_within_h3(self, params_dict: dict):
            self.parent.run_template_sql("gen/generate_grid_within_h3.sql", params_dict)

        def generate_grid_around_h3(self, params_dict: dict):
            self.parent.run_template_sql("gen/generate_grid_around_h3.sql", params_dict)

    class Find:
        def __init__(self, parent):
            self.parent = parent

        def find_nearest_n(self, params_dict: dict):
            self.parent.run_template_sql("find/find_nearest_n.sql", params_dict)

        def find_nearest_avg(self, params_dict: dict):
            self.parent.run_template_sql("find/find_nearest_avg.sql", params_dict)

    class Enrich:
        def __init__(self, parent):
            self.parent = parent

        def enrich_by_overlap(self, params_dict: dict):
            self.parent.run_template_sql("enrich/enrich_by_overlap.sql", params_dict)

    def __init__(self, connection_string: str):
        self.engine: Engine = create_engine(connection_string)
        self._initialize()
        self.filter = self.Filter(self)
        self.agg = self.Aggregate(self)
        self.gen = self.Generate(self)
        self.find = self.Find(self)
        self.enrich = self.Enrich(self)
        
        self.FUNCTIONS = {
            "generate_buffer": self.gen.generate_buffer,
            "filter_by_overlap": self.filter.filter_by_overlap,
            "aggregate_by_region": self.agg.aggregate_by_region,
            "aggregate_within_buffer": self.agg.aggregate_within_buffer,
            "generate_grid_h3": self.gen.generate_grid_h3,
            "generate_grid_within_h3": self.gen.generate_grid_within_h3,
            "generate_grid_around_h3": self.gen.generate_grid_around_h3,
            "find_nearest_n": self.find.find_nearest_n,
            "find_nearest_avg": self.find.find_nearest_avg,
            "enrich_by_overlap": self.enrich.enrich_by_overlap,
            "custom_sql": self.custom_sql,
            "custom_sql_file": self.custom_sql_file,
        }

    def _initialize(self):
        with self.engine.connect() as conn:
            if self.engine.name == "duckdb":
                self.sql_dir = SQL_DIR / "duckdb"
                conn.execute(text("LOAD spatial;"))
                conn.execute(text("INSTALL h3 FROM community;"))
                conn.execute(text("LOAD h3;"))

    def render_template(self, template_name: str, params_dict: dict) -> str:
        template_path = self.sql_dir / template_name
        with open(template_path, "r") as f:
            template = Template(f.read())
        return template.render(**params_dict)

    def sql_execute(self, sql: str):
        with self.engine.connect() as conn:
            conn.execute(text(sql))
            conn.commit()

    def run_template_sql(self, template_name: str, params_dict: dict):
        sql = self.render_template(template_name, params_dict)
        print(sql)
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
