from pathlib import Path
import yaml
from cm_data_transformation.operations import Operations

class Runner:
    """
    Runner, který sestaví jediný dict:
    params_dict = { from: {...}, with: {...}, func: {...}, to: {...} }
    a předá ho do Jinja template.
    """

    def __init__(self, connection_string: str):
        if connection_string.startswith("duckdb:///"):
            path_str = connection_string.replace("duckdb:///", "")
            abs_path = Path(path_str).resolve()
            print(abs_path)
            connection_string = f"duckdb:///{abs_path}"
        self.operations = Operations(connection_string)
        self.FUNCTIONS = self.operations.FUNCTIONS

    def run_yaml(self, yaml_path: Path):
        with open(yaml_path, "r") as f:
            scenario = yaml.safe_load(f)
        self._run_pipeline(scenario.get("pipeline", []))

    def _run_pipeline(self, pipeline: list):
        for idx, step_dict in enumerate(pipeline):
            step = step_dict["step"]
            func_cfg = step["function"]
            func_type = func_cfg["type"]

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
            func = self.FUNCTIONS.get(func_type)
            if not func:
                raise ValueError(f"Unknown function: {func_type}")

            # předáme celý dict do Jinja template
            func(**params_dict)
