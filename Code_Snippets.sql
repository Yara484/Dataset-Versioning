CREATE TABLE version_metadata ( 
version_id INT PRIMARY KEY, 
version_name VARCHAR(50), 
created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
description VARCHAR(255) 
);

CREATE TABLE customer_transactions (
    customer_id INT,
    transaction_id INT,
    transaction_date DATE,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    version_id INT,
    effective_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP DEFAULT '9999-12-31',
    PRIMARY KEY (transaction_id, version_id),
    FOREIGN KEY (version_id) REFERENCES version_metadata(version_id)
);

CREATE TABLE schema_changes (
    version_id INT,
    column_name VARCHAR(50),
    data_type VARCHAR(50),
    is_new BOOLEAN,
    change_description VARCHAR(255),
    PRIMARY KEY (version_id, column_name),
    FOREIGN KEY (version_id) REFERENCES version_metadata(version_id)
);

-- Insert New Version
INSERT INTO version_metadata (version_id, version_name, description)
VALUES (2, '2024-11 Monthly Update', 'Added region column and updated records');

-- Load Data with Version (Tracking Row-Level)
INSERT INTO customer_transactions (customer_id, transaction_id, transaction_date, product_id, quantity, price, version_id)
VALUES (101, 1001, '2024-11-01', 2001, 3, 150.00, 2);

-- Track Schema Changes
INSERT INTO schema_changes (version_id, column_name, data_type, is_new, change_description)
VALUES (2, 'region', 'VARCHAR(50)', TRUE, 'Added region column for geographic tracking');


-- STORED PROCEDURES

-- Retrieve Latest Version

CREATE VIEW current_customer_transactions AS
SELECT *
FROM customer_transactions
WHERE version_id = (SELECT MAX(version_id) FROM version_metadata)
AND end_date = '9999-12-31';

-- Retrieve Specific Historical Version

CREATE PROCEDURE GetCustomerTransactionsByVersion(IN version_input INT) BEGIN 
SELECT * 
FROM customer_transactions 
WHERE version_id = version_input 
AND end_date = '9999-12-31';
 END;

-- List All Available Versions

CREATE PROCEDURE ListAllVersions() BEGIN SELECT version_id, version_name, created_at, description FROM version_metadata; END;

