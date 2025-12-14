from pathlib import Path
import re
import sys

# ========= CONFIG =========

DSL_DIR = Path("duckdb/gen")
DBT_MACROS_DIR = Path("dbt_macros")

TEMPLATE_SUFFIX = ".sql"

FORBIDDEN_TOKENS = [
    "ref(",
    "this",
    "config(",
    "create table",
    "create or replace table",
    "drop table",
    "begin",
    "commit",
]

HEADER_TEMPLATE = """-- ⚠️ GENERATED FILE – DO NOT EDIT
-- Source: {source}
-- Generated from Jinja DSL templates.
-- Any manual changes will be overwritten.

"""

MACRO_TEMPLATE = """{header}
{{% macro {macro_name}({args}) %}}
{body}
{{% endmacro %}}
"""

# ========= HELPERS =========


def extract_macro_name(path: Path) -> str:
    """
    aggregate_within_buffer.sql.j2 -> aggregate_within_buffer
    """
    name = path.name
    if name.endswith(TEMPLATE_SUFFIX):
        return name[: -len(TEMPLATE_SUFFIX)]
    return path.stem


def normalize_body(body: str) -> str:
    """
    - strip leading/trailing empty lines
    - remove trailing whitespace
    """
    body = body.strip("\n")
    body = re.sub(r"[ \t]+$", "", body, flags=re.MULTILINE)
    return body


def parse_args(body: str, template_path: Path) -> str:
    """
    Reads macro args from a comment line:
    -- args: source, options
    """
    for line in body.splitlines():
        line = line.strip()
        if line.lower().startswith("-- args:"):
            args = line.split(":", 1)[1].strip()
            if not args:
                raise ValueError(f"{template_path}: '-- args:' is empty")
            return args

    raise ValueError(
        f"{template_path}: Missing required '-- args:' declaration"
    )


def validate_body(body: str, template_path: Path):
    lower = body.lower()
    for token in FORBIDDEN_TOKENS:
        if token in lower:
            raise ValueError(
                f"{template_path}: forbidden token detected: '{token}'"
            )


def generate_macro(template_path: Path, target_dir: Path):
    raw_body = template_path.read_text(encoding="utf-8")

    validate_body(raw_body, template_path)

    args = parse_args(raw_body, template_path)
    body = normalize_body(raw_body)
    macro_name = extract_macro_name(template_path)

    rendered = MACRO_TEMPLATE.format(
        header=HEADER_TEMPLATE.format(source=template_path.as_posix()),
        macro_name=macro_name,
        args=args,
        body=body,
    )

    target_path = target_dir / f"{macro_name}.sql"
    target_path.write_text(rendered, encoding="utf-8")

    print(f"✔ Generated {target_path}")


# ========= MAIN =========


def main():
    if not DSL_DIR.exists():
        print(f"❌ DSL directory not found: {DSL_DIR}", file=sys.stderr)
        sys.exit(1)

    DBT_MACROS_DIR.mkdir(parents=True, exist_ok=True)

    templates = sorted(DSL_DIR.glob(f"*{TEMPLATE_SUFFIX}"))
    if not templates:
        print("❌ No DSL templates found", file=sys.stderr)
        sys.exit(1)

    for template in templates:
        generate_macro(template, DBT_MACROS_DIR)

    print(f"\n✅ Successfully generated {len(templates)} dbt macros")


if __name__ == "__main__":
    main()
