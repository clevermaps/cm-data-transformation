from jinja2 import Template
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
import yaml

BASE_DIR = Path(__file__).resolve().parent
SQL_DIR = BASE_DIR / "sql"

class Operations:

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
            "custom": self.custom,
        }

    def _initialize(self):
        with self.engine.connect() as conn:
            if self.engine.name == "duckdb":
                self.sql_dir = SQL_DIR / "duckdb"
                conn.execute(text("LOAD spatial;"))
                conn.execute(text("INSTALL h3 FROM community;"))
                conn.execute(text("LOAD h3;"))

    def render_template(self, template_name: str, **params) -> str:
        template_path = self.sql_dir / template_name
        with open(template_path, "r") as f:
            template = Template(f.read())
        return template.render(**params)

    def sql_execute(self, sql: str):
        with self.engine.connect() as conn:
            conn.execute(text(sql))
            conn.commit()

    def run_template_sql(self, template_name: str, **params):
        sql = self.render_template(template_name, **params)
        print(sql)
        self.sql_execute(sql)

    def buffer(self, in_table, geom_col, buffer_m, out_col, out_table):
        self.run_template_sql(
            "buffer.sql",
            in_table=in_table,
            geometry_col=geom_col,
            buffer_m=buffer_m,
            out_col=out_col,
            out_table=out_table,
        )

    def filter(self, in_table_a, in_table_b, geom_col_a, geom_col_b, where_condition, out_table):
        self.run_template_sql(
            "filter.sql",
            in_table_a=in_table_a,
            in_table_b=in_table_b,
            geom_col_a=geom_col_a,
            geom_col_b=geom_col_b,
            where_condition=where_condition,
            out_table=out_table,
        )

    def aggregate(self, in_table_a, in_table_b, geom_col_a, geom_col_b, agg_func, out_table):
        self.run_template_sql(
            "aggregate.sql",
            in_table_a=in_table_a,
            in_table_b=in_table_b,
            geom_col_a=geom_col_a,
            geom_col_b=geom_col_b,
            agg_func=agg_func,
            out_table=out_table,
        )

    def grid(self, in_table, geom_col, h3_res, out_table):
        self.run_template_sql(
            "grid.sql",
            in_table=in_table,
            geom_col=geom_col,
            h3_res=h3_res,
            out_table=out_table,
        )

    def nearest(self, in_table_a, in_table_b, geom_col_a, geom_col_b, id_col_a, id_col_b, max_distance, out_table):
        self.run_template_sql(
            "nearest.sql",
            in_table_a=in_table_a,
            in_table_b=in_table_b,
            geom_col_a=geom_col_a,
            geom_col_b=geom_col_b,
            id_col_a=id_col_a,
            id_col_b=id_col_b,
            max_distance=max_distance,
            out_table=out_table,
        )

    def join(self, in_table_a, in_table_b, geom_col_a, geom_col_b, columns_a, columns_b, out_table):
        self.run_template_sql(
            "join.sql",
            in_table_a=in_table_a,
            in_table_b=in_table_b,
            geom_col_a=geom_col_a,
            geom_col_b=geom_col_b,
            a_columns=columns_a,
            b_columns=columns_b,
            out_table=out_table,
        )

    def custom(self, sql: str):
        self.sql_execute(sql)

    def run_yaml_scenario(self, yaml_path: Path):
        
        with open(yaml_path, "r") as f:
            scenario = yaml.safe_load(f)

        print(f"Running scenario: {scenario['scenario']}")
        for step in scenario["steps"]:
            name = step["name"]
            func_name = step["function"]
            params = step["params"]

            print(f" → Step: {name} ({func_name})")
            func = self.FUNCTIONS.get(func_name)
            if not func:
                raise ValueError(f"Unknown function: {func_name}")

            func(**params)

        print("Scenario finished.")
