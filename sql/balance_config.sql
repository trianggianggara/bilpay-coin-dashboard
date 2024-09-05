CREATE TABLE balance_config (
    id SMALLINT PRIMARY KEY,
    balance NUMERIC NOT NULL,
    balance_type VARCHAR NOT NULL
);

INSERT INTO balance_config (id, balance, balance_type) VALUES (1, 20, 'regis');
INSERT INTO balance_config (id, balance, balance_type) VALUES (2, 20, 'topup');
INSERT INTO balance_config (id, balance, balance_type) VALUES (3, 20, 'payment');
INSERT INTO balance_config (id, balance, balance_type) VALUES (4, 20, 'min_topup');
