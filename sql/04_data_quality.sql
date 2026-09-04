-- 1. Ordered value versus invoiced value
WITH order_values AS (
    SELECT purchase_order_id,
           SUM(ordered_quantity * net_price) AS ordered_value
    FROM purchase_order_items
    GROUP BY purchase_order_id
), invoice_values AS (
    SELECT purchase_order_id, SUM(invoice_amount) AS invoiced_value
    FROM invoices
    GROUP BY purchase_order_id
)
SELECT
    po.purchase_order_id,
    v.vendor_name,
    ROUND(ov.ordered_value, 2) AS ordered_value,
    ROUND(COALESCE(iv.invoiced_value, 0), 2) AS invoiced_value,
    ROUND(COALESCE(iv.invoiced_value, 0) - ov.ordered_value, 2) AS value_difference,
    CASE
        WHEN iv.invoiced_value IS NULL THEN 'NOT_INVOICED'
        WHEN ABS(iv.invoiced_value - ov.ordered_value) < 0.01 THEN 'MATCH'
        ELSE 'REVIEW'
    END AS control_status
FROM purchase_orders AS po
JOIN vendors AS v ON v.vendor_id = po.vendor_id
JOIN order_values AS ov ON ov.purchase_order_id = po.purchase_order_id
LEFT JOIN invoice_values AS iv ON iv.purchase_order_id = po.purchase_order_id
ORDER BY po.purchase_order_id;

-- 2. Receipt quantity must not exceed ordered quantity; clean data returns no rows
WITH received AS (
    SELECT purchase_order_id, item_number,
           SUM(received_quantity) AS received_quantity
    FROM goods_receipts
    GROUP BY purchase_order_id, item_number
)
SELECT poi.purchase_order_id, poi.item_number, poi.ordered_quantity,
       r.received_quantity,
       r.received_quantity - poi.ordered_quantity AS excess_quantity
FROM purchase_order_items AS poi
JOIN received AS r
    ON r.purchase_order_id = poi.purchase_order_id
   AND r.item_number = poi.item_number
WHERE r.received_quantity > poi.ordered_quantity;

-- 3. Recorded header status versus status derived from receipts
WITH item_balance AS (
    SELECT poi.purchase_order_id, poi.item_number, poi.ordered_quantity,
           COALESCE(SUM(gr.received_quantity), 0) AS received_quantity
    FROM purchase_order_items AS poi
    LEFT JOIN goods_receipts AS gr
        ON gr.purchase_order_id = poi.purchase_order_id
       AND gr.item_number = poi.item_number
    GROUP BY poi.purchase_order_id, poi.item_number, poi.ordered_quantity
), derived_status AS (
    SELECT purchase_order_id,
           CASE
               WHEN SUM(received_quantity) = 0 THEN 'OPEN'
               WHEN SUM(received_quantity) >= SUM(ordered_quantity) THEN 'COMPLETED'
               ELSE 'PARTIAL'
           END AS calculated_status
    FROM item_balance
    GROUP BY purchase_order_id
)
SELECT po.purchase_order_id, po.order_status AS recorded_status,
       ds.calculated_status,
       CASE WHEN po.order_status = ds.calculated_status
            THEN 'CONSISTENT' ELSE 'REVIEW' END AS quality_status
FROM purchase_orders AS po
JOIN derived_status AS ds ON ds.purchase_order_id = po.purchase_order_id
ORDER BY po.purchase_order_id;

