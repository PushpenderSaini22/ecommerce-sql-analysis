# Data

The raw dataset is **not** committed to this repository — it is ~128 MB and is
freely available publicly.

## Dataset

**Olist — Brazilian E-Commerce Marketplace** (orders placed between 2016 and 2018).

## Tables used

| Table           | Description                                |
| --------------- | ------------------------------------------ |
| `orders`        | Order header — timestamps, customer, seller |
| `customers`     | Customer master with city / state          |
| `payments`      | One or more payment records per order      |
| `order_items`   | Line items — price, freight, product       |
| `products`      | Product catalogue                          |
| `sellers`       | Seller master                              |
| `geolocation`   | Zip-code prefix → lat/long                 |
| `order_reviews` | Customer reviews                           |

## How to load

1. Create a Google Cloud project and enable the BigQuery API.
2. Download the dataset and upload the CSVs into a BigQuery dataset
   (`bq load --source_format=CSV ...`), or use a BigQuery public dataset.
3. In every file under [`../sql`](../sql), replace `PROJECT.DATASET` with your
   own project and dataset name.

```sql
-- Example
FROM `PROJECT.DATASET.orders`;
-- becomes
FROM `my-project.olist.orders`;
```
