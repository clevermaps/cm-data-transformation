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

    def __init__(self, connection_string: str):
        self.engine: Engine = create_engine(connection_string)
        self._initialize()
        self.FUNCTIONS = {
            "buffer": self.buffer,
            "filter": self.filter,
            "aggregate": self.aggregate,
            "grid": self.grid,
            "nearest": self.nearest,
            "join": self.join,
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

    # --------------------------
    # Hlavní funkce přijímají jen params_dict
    # --------------------------
    def buffer(self, **params_dict):
        self.run_template_sql("buffer.sql", params_dict)

    def filter(self, **params_dict):
        self.run_template_sql("filter.sql", params_dict)

    def aggregate(self, **params_dict):
        self.run_template_sql("aggregate.sql", params_dict)

    def grid(self, **params_dict):
        self.run_template_sql("grid.sql", params_dict)

    def nearest(self, **params_dict):
        self.run_template_sql("nearest.sql", params_dict)

    def join(self, **params_dict):
        self.run_template_sql("join.sql", params_dict)

    def custom_sql(self, sql: str):
        self.sql_execute(sql)

    def custom_sql_file(self, sql_file_path: str):
        file_path = Path(sql_file_path)
        if not file_path.is_file():
            raise FileNotFoundError(f"SQL file not found: {sql_file_path}")
        with open(file_path, "r") as f:
            sql = f.read()
        self.sql_execute(sql)
