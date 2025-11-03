from pathlib import Path
import yaml
from cm_data_transformation.operations import Operations
from cm_data_transformation.validator import StepValidator

class Runner:
    """
    Runner, který sestaví jediný dict:
    params_dict = { from: {...}, with: {...}, func: {...}, to: {...} }
    a předá ho do Jinja template.
    """

    def __init__(self, connection_string: str, validate: bool = False):
        
        if connection_string.startswith("duckdb:///"):
            path_str = connection_string.replace("duckdb:///", "")
            abs_path = Path(path_str).resolve()
            #print(abs_path)
            connection_string = f"duckdb:///{abs_path}"
        
        self.operations = Operations(connection_string)
        self.FUNCTIONS = self.operations.FUNCTIONS

        self.validate = validate

        self.validator = StepValidator(
            sql_dir=Path(__file__).parent / "sql" / "duckdb",
            sql_mapping={
                "buffer": "buffer.sql",
                "filter": "filter.sql",
                "aggregate": "aggregate.sql",
                "grid": "grid.sql",
                "nearest": "nearest.sql",
                "join": "join.sql"
            }
        )


    def run_yaml(self, yaml_path: Path):
        with open(yaml_path, "r") as f:
            config = yaml.safe_load(f)
        self._run_pipeline(config.get("pipeline", []))

    def run_steps(self, steps: list):
        """Spustí pipeline přímo ze slovníku (už načteného YAML)."""
        
        self._run_pipeline(steps)

    def _run_pipeline(self, steps: list):
        for idx, step_dict in enumerate(steps):
            step = step_dict["step"]

            if self.validate:
                self.validator.validate_step(step)

            func_cfg = step["function"]
            func_type = func_cfg["type"]

            func = self.FUNCTIONS.get(func_type)
            if not func:
                raise ValueError(f"Unknown function: {func_type}")
            
            if func_type == 'custom_sql':
                func(func_cfg['options']['sql'])
            elif func_type == 'custom_sql_file':
                func(Path(func_cfg['options']['sql_file_path']).resolve())
            else:
                # vstupní tabulka
                from_cfg = step.get("from", {})
                from_options = from_cfg.get("options", {})

                # volitelná druhá tabulka
                with_cfg = step.get("with", {})
                with_options = with_cfg.get("options", {})

                # výstupní tabulka
                to_cfg = step.get("to", {})
                out_table = to_cfg.get("table") or func_cfg.get("options", {}).get("out")

                # složení jediného dictu pro Jinja
                params_dict = {
                    "from": {**from_cfg, "options": from_options},
                    "with": {**with_cfg, "options": with_options} if with_cfg else None,
                    "func": {**func_cfg, "options": {**func_cfg.get("options", {}), "out": out_table}},
                    "to": {"table": out_table}
                }

                # odstranění None
                params_dict = {k: v for k, v in params_dict.items() if v is not None}

                print(f"Step {idx+1}: Running {func_type} → {out_table}")
                
                # předáme celý dict do Jinja template
                func(**params_dict)
