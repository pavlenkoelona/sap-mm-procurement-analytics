-- 1. Purchase order value by supplier
SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(DISTINCT po.purchase_order_id) AS order_count,
    ROUND(SUM(poi.ordered_quantity * poi.net_price), 2) AS ordered_value
FROM vendors AS v
JOIN purchase_orders AS po ON po.vendor_id = v.vendor_id
JOIN purchase_order_items AS poi ON poi.purchase_order_id = po.purchase_order_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY ordered_value DESC;

-- 2. Open quantity by purchase order item, including items without a receipt
WITH received AS (
    SELECT purchase_order_id, item_number,
           SUM(received_quantity) AS received_quantity
    FROM goods_receipts
    GROUP BY purchase_order_id, item_number
)
SELECT
    poi.purchase_order_id,
    poi.item_number,
    m.material_name,
    poi.ordered_quantity,
    COALESCE(r.received_quantity, 0) AS received_quantity,
    poi.ordered_quantity - COALESCE(r.received_quantity, 0) AS open_quantity,
    poi.delivery_date
FROM purchase_order_items AS poi
JOIN materials AS m ON m.material_id = poi.material_id
LEFT JOIN received AS r
    ON r.purchase_order_id = poi.purchase_order_id
   AND r.item_number = poi.item_number
WHERE poi.ordered_quantity > COALESCE(r.received_quantity, 0)
ORDER BY poi.delivery_date, poi.purchase_order_id, poi.item_number;

-- 3. Delivery performance by supplier
WITH item_receipts AS (
    SELECT purchase_order_id, item_number,
           MAX(receipt_date) AS latest_receipt_date
    FROM goods_receipts
    GROUP BY purchase_order_id, item_number
)
SELECT
    v.vendor_name,
    COUNT(ir.item_number) AS received_item_count,
    SUM(CASE WHEN ir.latest_receipt_date > poi.delivery_date THEN 1 ELSE 0 END) AS late_item_count,
    ROUND(
        100.0 * SUM(CASE WHEN ir.latest_receipt_date <= poi.delivery_date THEN 1 ELSE 0 END)
        / NULLIF(COUNT(ir.item_number), 0), 1
    ) AS on_time_percentage
FROM vendors AS v
JOIN purchase_orders AS po ON po.vendor_id = v.vendor_id
JOIN purchase_order_items AS poi ON poi.purchase_order_id = po.purchase_order_id
JOIN item_receipts AS ir
    ON ir.purchase_order_id = poi.purchase_order_id
   AND ir.item_number = poi.item_number
GROUP BY v.vendor_id, v.vendor_name
ORDER BY on_time_percentage DESC, v.vendor_name;

-- 4. Monthly ordered value (SQLite-compatible date expression)
SELECT
    substr(po.order_date, 1, 7) AS order_month,
    ROUND(SUM(poi.ordered_quantity * poi.net_price), 2) AS ordered_value
FROM purchase_orders AS po
JOIN purchase_order_items AS poi ON poi.purchase_order_id = po.purchase_order_id
GROUP BY substr(po.order_date, 1, 7)
ORDER BY order_month;

-- 5. Material groups by ordered value
SELECT
    m.material_group,
    ROUND(SUM(poi.ordered_quantity * poi.net_price), 2) AS ordered_value,
    SUM(poi.ordered_quantity) AS ordered_quantity
FROM materials AS m
JOIN purchase_order_items AS poi ON poi.material_id = m.material_id
GROUP BY m.material_group
ORDER BY ordered_value DESC;

