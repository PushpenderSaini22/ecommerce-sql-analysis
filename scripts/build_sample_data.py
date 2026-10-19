"""Build a small, referentially consistent sample of the Olist dataset.

The full dataset is ~128 MB, which is far too large to commit to Git. This
script takes a random sample of orders and then pulls in only the matching
customers, order_items and payments, so that every JOIN in ../sql/ returns
correct results on the sample.

Usage:
    python scripts/build_sample_data.py "<path to the Olist CSV folder>" [--rows 500]
"""

import argparse
import csv
import random
import sys
from pathlib import Path

SAMPLE_SIZE = 500
SEED = 42


def read_csv(path: Path):
    with path.open("r", encoding="utf-8", newline="") as fh:
        return list(csv.DictReader(fh))


def write_csv(path: Path, rows, fieldnames):
    with path.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, help="folder containing the Olist CSVs")
    parser.add_argument("--rows", type=int, default=SAMPLE_SIZE)
    args = parser.parse_args()

    src: Path = args.source
    out = Path(__file__).resolve().parent.parent / "data" / "sample"
    out.mkdir(parents=True, exist_ok=True)

    print(f"Reading source CSVs from {src}")
    orders = read_csv(src / "orders.csv")
    print(f"  orders.csv      {len(orders):>8,} rows")

    random.seed(SEED)
    # Prefer delivered orders so the sample has a realistic timestamp range.
    eligible = [o for o in orders if o["order_status"] == "delivered"]
    picked = random.sample(eligible, min(args.rows, len(eligible)))
    order_ids = {o["order_id"] for o in picked}
    customer_ids = {o["customer_id"] for o in picked}
    print(f"  sampled         {len(picked):>8,} delivered orders")

    write_csv(out / "orders.csv", picked, list(picked[0].keys()))
    print(f"  wrote data/sample/orders.csv ({len(picked):,} rows)")

    for name, key, wanted in (
        ("order_items.csv", "order_id", order_ids),
        ("payments.csv", "order_id", order_ids),
    ):
        rows = [r for r in read_csv(src / name) if r[key] in wanted]
        write_csv(out / name, rows, list(rows[0].keys()))
        print(f"  wrote data/sample/{name} ({len(rows):,} rows)")

    customers = [c for c in read_csv(src / "customers.csv") if c["customer_id"] in customer_ids]
    write_csv(out / "customers.csv", customers, list(customers[0].keys()))
    print(f"  wrote data/sample/customers.csv ({len(customers):,} rows)")

    total = sum(p.stat().st_size for p in out.glob("*.csv"))
    print(f"\nSample size: {total / 1024:.0f} KB across {len(list(out.glob('*.csv')))} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
