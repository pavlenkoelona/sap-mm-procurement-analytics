-- Fictional data for the SAP MM-inspired procurement project.
-- All companies, identifiers and transactions are invented for learning purposes.

INSERT INTO vendors (vendor_id, vendor_name, country_code, payment_terms) VALUES
    (1001, 'NordTech Components GmbH', 'DE', 'NET30'),
    (1002, 'Rhein Industrial Supply GmbH', 'DE', 'NET14'),
    (1003, 'Iberia Office Solutions SL', 'ES', 'NET30'),
    (1004, 'Baltic Packaging Sp. z o.o.', 'PL', 'NET45'),
    (1005, 'Alpine Safety AG', 'AT', 'NET30');

INSERT INTO materials (material_id, material_name, material_group, unit_of_measure) VALUES
    (2001, 'Industrial sensor',       'ELECTRONICS', 'EA'),
    (2002, 'Control cable 10 m',      'ELECTRONICS', 'EA'),
    (2003, 'Safety gloves',           'SAFETY',      'PAIR'),
    (2004, 'Protective helmet',       'SAFETY',      'EA'),
    (2005, 'Cardboard box large',     'PACKAGING',   'EA'),
    (2006, 'Packaging tape 50 mm',    'PACKAGING',   'ROLL'),
    (2007, 'Office monitor 27 inch',  'IT',          'EA'),
    (2008, 'Wireless keyboard',       'IT',          'EA');

INSERT INTO purchase_orders
    (purchase_order_id, vendor_id, order_date, currency_code, order_status)
VALUES
    (450001, 1001, '2026-06-03', 'EUR', 'COMPLETED'),
    (450002, 1002, '2026-06-10', 'EUR', 'COMPLETED'),
    (450003, 1003, '2026-06-18', 'EUR', 'COMPLETED'),
    (450004, 1004, '2026-07-02', 'EUR', 'PARTIAL'),
    (450005, 1005, '2026-07-09', 'EUR', 'COMPLETED'),
    (450006, 1001, '2026-07-21', 'EUR', 'COMPLETED'),
    (450007, 1002, '2026-08-04', 'EUR', 'PARTIAL'),
    (450008, 1003, '2026-08-12', 'EUR', 'OPEN'),
    (450009, 1004, '2026-08-20', 'EUR', 'COMPLETED'),
    (450010, 1005, '2026-08-27', 'EUR', 'OPEN');

INSERT INTO purchase_order_items
    (purchase_order_id, item_number, material_id, ordered_quantity, net_price, delivery_date)
VALUES
    (450001, 10, 2001,  20, 145.00, '2026-06-17'),
    (450001, 20, 2002,  30,  32.50, '2026-06-17'),
    (450002, 10, 2003, 100,   6.80, '2026-06-20'),
    (450002, 20, 2004,  25,  28.00, '2026-06-20'),
    (450003, 10, 2007,  10, 245.00, '2026-07-03'),
    (450003, 20, 2008,  10,  38.00, '2026-07-03'),
    (450004, 10, 2005, 500,   1.20, '2026-07-16'),
    (450004, 20, 2006, 100,   2.90, '2026-07-16'),
    (450005, 10, 2003, 150,   6.60, '2026-07-23'),
    (450005, 20, 2004,  40,  27.50, '2026-07-23'),
    (450006, 10, 2001,  15, 142.00, '2026-08-05'),
    (450007, 10, 2002,  50,  31.50, '2026-08-18'),
    (450007, 20, 2001,  10, 140.00, '2026-08-18'),
    (450008, 10, 2007,   8, 239.00, '2026-08-28'),
    (450008, 20, 2008,   8,  36.50, '2026-08-28'),
    (450009, 10, 2005, 600,   1.15, '2026-09-01'),
    (450009, 20, 2006, 120,   2.80, '2026-09-01'),
    (450010, 10, 2003, 200,   6.40, '2026-09-10');

INSERT INTO goods_receipts
    (receipt_id, purchase_order_id, item_number, receipt_date, received_quantity)
VALUES
    (500001, 450001, 10, '2026-06-16',  20),
    (500002, 450001, 20, '2026-06-16',  30),
    (500003, 450002, 10, '2026-06-24', 100),
    (500004, 450002, 20, '2026-06-24',  25),
    (500005, 450003, 10, '2026-07-02',  10),
    (500006, 450003, 20, '2026-07-02',  10),
    (500007, 450004, 10, '2026-07-18', 300),
    (500008, 450005, 10, '2026-07-22', 150),
    (500009, 450005, 20, '2026-07-22',  40),
    (500010, 450006, 10, '2026-08-12',  15),
    (500011, 450007, 10, '2026-08-17',  30),
    (500012, 450009, 10, '2026-09-03', 600),
    (500013, 450009, 20, '2026-09-03', 120);

INSERT INTO invoices
    (invoice_id, purchase_order_id, invoice_date, invoice_amount, invoice_status)
VALUES
    (510001, 450001, '2026-06-18', 3875.00, 'PAID'),
    (510002, 450002, '2026-06-25', 1380.00, 'PAID'),
    (510003, 450003, '2026-07-04', 2830.00, 'PAID'),
    (510004, 450004, '2026-07-20',  360.00, 'OPEN'),
    (510005, 450005, '2026-07-24', 2090.00, 'PAID'),
    (510006, 450006, '2026-08-13', 2130.00, 'PAID'),
    (510007, 450007, '2026-08-19',  945.00, 'OPEN'),
    (510008, 450009, '2026-09-04', 1036.00, 'OPEN');

