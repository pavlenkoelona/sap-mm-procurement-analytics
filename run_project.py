"""Build the demo database and export portfolio reports as CSV files."""

from __future__ import annotations

import csv
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SQL_DIR = ROOT / "sql"
REPORT_DIR = ROOT / "reports"
DATABASE = ROOT / "procurement.db"

REPORTS = {
    "supplier_spend": """
        SELECT v.vendor_name,
               COUNT(DISTINCT po.purchase_order_id) AS order_count,
               ROUND(SUM(poi.ordered_quantity * poi.net_price), 2) AS ordered_value
        FROM vendors v
        JOIN purchase_orders po ON po.vendor_id = v.vendor_id
        JOIN purchase_order_items poi ON poi.purchase_order_id = po.purchase_order_id
        GROUP BY v.vendor_id, v.vendor_name
        ORDER BY ordered_value DESC
    """,
    "open_order_items": """
        WITH received AS (
            SELECT purchase_order_id, item_number,
                   SUM(received_quantity) AS received_quantity
            FROM goods_receipts
            GROUP BY purchase_order_id, item_number
        )
        SELECT poi.purchase_order_id, poi.item_number, m.material_name,
               poi.ordered_quantity,
               COALESCE(r.received_quantity, 0) AS received_quantity,
               poi.ordered_quantity - COALESCE(r.received_quantity, 0) AS open_quantity,
               poi.delivery_date
        FROM purchase_order_items poi
        JOIN materials m ON m.material_id = poi.material_id
        LEFT JOIN received r
          ON r.purchase_order_id = poi.purchase_order_id
         AND r.item_number = poi.item_number
        WHERE poi.ordered_quantity > COALESCE(r.received_quantity, 0)
        ORDER BY poi.delivery_date, poi.purchase_order_id, poi.item_number
    """,
    "invoice_control": """
        WITH order_values AS (
            SELECT purchase_order_id,
                   SUM(ordered_quantity * net_price) AS ordered_value
            FROM purchase_order_items GROUP BY purchase_order_id
        ), invoice_values AS (
            SELECT purchase_order_id, SUM(invoice_amount) AS invoiced_value
            FROM invoices GROUP BY purchase_order_id
        )
        SELECT po.purchase_order_id, v.vendor_name,
               ROUND(ov.ordered_value, 2) AS ordered_value,
               ROUND(COALESCE(iv.invoiced_value, 0), 2) AS invoiced_value,
               ROUND(COALESCE(iv.invoiced_value, 0) - ov.ordered_value, 2) AS difference,
               CASE
                 WHEN iv.invoiced_value IS NULL THEN 'NOT_INVOICED'
                 WHEN ABS(iv.invoiced_value - ov.ordered_value) < 0.01 THEN 'MATCH'
                 ELSE 'REVIEW'
               END AS control_status
        FROM purchase_orders po
        JOIN vendors v ON v.vendor_id = po.vendor_id
        JOIN order_values ov ON ov.purchase_order_id = po.purchase_order_id
        LEFT JOIN invoice_values iv ON iv.purchase_order_id = po.purchase_order_id
        ORDER BY po.purchase_order_id
    """,
}


def export_report(connection: sqlite3.Connection, name: str, query: str) -> int:
    cursor = connection.execute(query)
    rows = cursor.fetchall()
    destination = REPORT_DIR / f"{name}.csv"
    with destination.open("w", newline="", encoding="utf-8-sig") as output:
        writer = csv.writer(output)
        writer.writerow([column[0] for column in cursor.description])
        writer.writerows(rows)
    return len(rows)


def main() -> None:
    REPORT_DIR.mkdir(exist_ok=True)
    DATABASE.unlink(missing_ok=True)
    with sqlite3.connect(DATABASE) as connection:
        connection.execute("PRAGMA foreign_keys = ON")
        connection.executescript((SQL_DIR / "01_schema.sql").read_text(encoding="utf-8"))
        connection.executescript((SQL_DIR / "02_sample_data.sql").read_text(encoding="utf-8"))
        print("SAP MM Procurement Analytics")
        print("Database created successfully.\n")
        for report_name, query in REPORTS.items():
            row_count = export_report(connection, report_name, query)
            print(f"- {report_name}.csv: {row_count} rows")


if __name__ == "__main__":
    main()

