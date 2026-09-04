-- SAP MM-inspired procurement data model

CREATE TABLE vendors (
    vendor_id       INTEGER PRIMARY KEY,
    vendor_name     VARCHAR(100) NOT NULL,
    country_code    CHAR(2) NOT NULL,
    payment_terms   VARCHAR(20) NOT NULL
);

CREATE TABLE materials (
    material_id     INTEGER PRIMARY KEY,
    material_name   VARCHAR(100) NOT NULL,
    material_group  VARCHAR(50) NOT NULL,
    unit_of_measure VARCHAR(10) NOT NULL
);

CREATE TABLE purchase_orders (
    purchase_order_id INTEGER PRIMARY KEY,
    vendor_id         INTEGER NOT NULL,
    order_date        DATE NOT NULL,
    currency_code     CHAR(3) NOT NULL,
    order_status      VARCHAR(20) NOT NULL,
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id)
);

CREATE TABLE purchase_order_items (
    purchase_order_id INTEGER NOT NULL,
    item_number       INTEGER NOT NULL,
    material_id       INTEGER NOT NULL,
    ordered_quantity  DECIMAL(13, 3) NOT NULL,
    net_price         DECIMAL(13, 2) NOT NULL,
    delivery_date     DATE NOT NULL,
    PRIMARY KEY (purchase_order_id, item_number),
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(purchase_order_id),
    FOREIGN KEY (material_id) REFERENCES materials(material_id)
);

CREATE TABLE goods_receipts (
    receipt_id        INTEGER PRIMARY KEY,
    purchase_order_id INTEGER NOT NULL,
    item_number       INTEGER NOT NULL,
    receipt_date      DATE NOT NULL,
    received_quantity DECIMAL(13, 3) NOT NULL,
    FOREIGN KEY (purchase_order_id, item_number)
        REFERENCES purchase_order_items(purchase_order_id, item_number)
);

CREATE TABLE invoices (
    invoice_id        INTEGER PRIMARY KEY,
    purchase_order_id INTEGER NOT NULL,
    invoice_date      DATE NOT NULL,
    invoice_amount    DECIMAL(13, 2) NOT NULL,
    invoice_status    VARCHAR(20) NOT NULL,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(purchase_order_id)
);

