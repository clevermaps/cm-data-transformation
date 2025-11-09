from pydantic import BaseModel, Field, ValidationError
from typing import Optional, Dict, Any
from jinja2 import Environment, meta
from difflib import get_close_matches
from pathlib import Path
import json


# TODO Fix not working properly

class FromConfig(BaseModel):
    table: str
    options: Optional[Dict[str, Any]] = None


class FuncConfig(BaseModel):
    type: str
    options: Dict[str, Any] = Field(default_factory=dict)


class StepConfig(BaseModel):
    from_: FromConfig = Field(alias="from")
    with_: Optional[FromConfig] = Field(alias="with", default=None)
    func: FuncConfig
    to: Optional[Dict[str, Any]] = None


def extract_jinja_vars(template_path: Path) -> set:
    """Vrátí množinu proměnných, které šablona očekává ({{ var }})."""
    env = Environment()
    with open(template_path, "r") as f:
        source = f.read()
    parsed = env.parse(source)
    return meta.find_undeclared_variables(parsed)


def flatten_dict(d: dict, parent_key="", sep=".") -> dict:
    """Zploští vnořený dict, např. {'a': {'b': 1}} -> {'a.b': 1}"""
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def suggest_param_name(param: str, available: set) -> str:
    suggestion = get_close_matches(param, available, n=1)
    return f"Did you mean '{suggestion[0]}'?" if suggestion else ""


class StepValidator:
    def __init__(self, sql_dir: Path, sql_mapping: Dict[str, str]):
        """
        Args:
            sql_dir: základní adresář se SQL šablonami
            sql_mapping: mapování názvu funkce → souboru (např. {"buffer": "buffer.sql"})
        """
        self.sql_dir = sql_dir
        self.sql_mapping = sql_mapping

    def validate_step(self, step_dict: dict):
        """
        Validuje:
        - strukturu YAML (pomocí Pydantic)
        - přítomnost všech proměnných v Jinja šabloně
        """
        try:
            step = StepConfig.model_validate(step_dict)
        except ValidationError as e:
            raise ValueError(f" YAML validation failed:\n{e}")

        func_type = step.func.type
        sql_file = self.sql_mapping.get(func_type)

        if not sql_file:
            print(f"No SQL template defined for function '{func_type}'. Skipping Jinja validation.")
            return

        template_path = self.sql_dir / sql_file
        if not template_path.exists():
            raise FileNotFoundError(f" SQL template not found: {template_path}")

        expected_vars = extract_jinja_vars(template_path)
        provided_vars = set(flatten_dict(step_dict).keys())

        missing = expected_vars - provided_vars
        if missing:
            print(f"\n Missing parameters for template '{sql_file}':")
            for var in missing:
                print(f"   - {var}  {suggest_param_name(var, provided_vars)}")

            print(f"\n Expected variables: {sorted(list(expected_vars))}")
            print(f"Provided keys: {sorted(list(provided_vars))}")
            raise ValueError(f"Validation failed for step '{func_type}'")

        print(f"Step '{func_type}' validated successfully ({sql_file})")
