"""Execute every query in ../sql against the bundled sample data.

    pip install duckdb
    python scripts/run_all.py

Expects to be run from the repository root. Results are printed as markdown
tables so they can be piped straight into a README or a terminal.
"""

import sys
from pathlib import Path

try:
    import duckdb
except ImportError:
    sys.exit("duckdb is not installed. Run: pip install duckdb")

ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = ROOT / "sql"
SAMPLE = ROOT / "data" / "sample"

TABLES = ["orders", "customers", "payments", "order_items"]


def main() -> int:
    missing = [t for t in TABLES if not (SAMPLE / f"{t}.csv").exists()]
    if missing:
        sys.exit(f"Missing sample files: {', '.join(missing)}")

    con = duckdb.connect()
    for table in TABLES:
        con.execute(
            f"CREATE OR REPLACE TABLE {table} AS "
            f"SELECT * FROM read_csv_auto('{(SAMPLE / f'{table}.csv').as_posix()}', header = true)"
        )
        count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"loaded {table:<12} {count:>6,} rows")

    print()
    files = sorted(p for p in SQL_DIR.glob("[0-9][0-9]_*.sql"))
    failures = 0

    for path in files:
        title = path.stem
        sql = path.read_text(encoding="utf-8")
        try:
            result = con.execute(sql)
            rows = result.fetchall()
            cols = [d[0] for d in result.description]
        except Exception as exc:  # noqa: BLE001
            failures += 1
            print(f"FAILED  {title}: {exc}\n")
            continue

        print(f"=== {title} ===")
        if not rows:
            print("(no rows)\n")
            continue

        print("| " + " | ".join(cols) + " |")
        print("|" + "|".join("---" for _ in cols) + "|")
        for row in rows:
            print("| " + " | ".join("" if v is None else str(v) for v in row) + " |")
        print()

    con.close()
    print(f"{len(files) - failures}/{len(files)} queries succeeded.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
