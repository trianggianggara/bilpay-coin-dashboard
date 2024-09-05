-- Simulasi ketika membuat user baru
CREATE OR REPLACE FUNCTION update_balance_function()
RETURNS TRIGGER AS $$
DECLARE
    config_balance NUMERIC;
BEGIN
    SELECT balance INTO config_balance  FROM balance_config WHERE balance_type = 'regis';


    IF NEW.type = 'koin' AND (NEW.category = 'available' OR NEW.category = 'ledger') THEN
        UPDATE balances
        SET balance = config_balance
        WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_balance_after_insert
AFTER INSERT ON balances
FOR EACH ROW
EXECUTE FUNCTION update_balance_function();

-- Simulasi ketika user melakukan top up sebesar 15000
CREATE OR REPLACE FUNCTION update_coin_balance_function()
RETURNS TRIGGER AS $$
DECLARE
    config_balance NUMERIC;
   	min_topup_balance numeric;
BEGIN
    SELECT balance INTO config_balance  FROM balance_config WHERE balance_type = 'topup';
    SELECT balance INTO min_topup_balance  FROM balance_config WHERE balance_type = 'min_topup';
	
    IF NEW.type = 'cash' and NEW.category = 'available' AND (NEW.balance - OLD.balance = min_topup_balance) THEN
        UPDATE balances
        SET balance = balance + config_balance
        WHERE customer_id = NEW.customer_id
          AND type = 'koin'
          AND (category = 'available' OR category = 'ledger');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_coin_balance_after_update
AFTER UPDATE ON balances
FOR EACH ROW
EXECUTE FUNCTION update_coin_balance_function();



-- Simulasi ketika user melakukan ketika saldo minus sebesar 5808, 10808, ETC
CREATE OR REPLACE FUNCTION update_coin_balance_minus_function()
RETURNS TRIGGER AS $$
DECLARE
    config_balance NUMERIC;
BEGIN
    SELECT balance INTO config_balance  FROM balance_config WHERE balance_type = 'payment';

    IF NEW.type = 'cash' AND NEW.category = 'available' AND (OLD.balance - NEW.balance) % 5000 = 808 THEN
        UPDATE balances
        SET balance = balance + config_balance
        WHERE customer_id = NEW.customer_id
          AND type = 'koin'
          AND (category = 'available' OR category = 'ledger');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_coin_balance_minus_after_update
AFTER UPDATE ON balances
FOR EACH ROW
EXECUTE FUNCTION update_coin_balance_minus_function();

