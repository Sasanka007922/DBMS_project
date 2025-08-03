DELIMITER $$
CREATE PROCEDURE add_sells_entry(
    IN p_pharmacy_address VARCHAR(200),
    IN p_drug_id INT,
    IN p_stock INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    -- Input validation
    IF p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
    
    IF p_price <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price must be positive';
    END IF;
    
    -- Check that pharmacy exists
    IF NOT EXISTS (SELECT 1 FROM Pharmacy WHERE address = p_pharmacy_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy does not exist';
    END IF;
    
    -- Check that drug exists
    IF NOT EXISTS (SELECT 1 FROM Drug WHERE drug_id = p_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Drug does not exist';
    END IF;
    
    -- Check if entry already exists
    IF EXISTS (SELECT 1 FROM Sells WHERE ph_address = p_pharmacy_address AND drug_id = p_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This drug is already being sold at this pharmacy. Use update_sells_entry instead.';
    END IF;
    
    -- Insert the new sells relationship
    INSERT INTO Sells(ph_address, drug_id, stock, price)
    VALUES (p_pharmacy_address, p_drug_id, p_stock, p_price);
    
    SELECT CONCAT('Drug with ID ', p_drug_id, ' is now being sold at pharmacy at address ', p_pharmacy_address) AS result;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_sells_entry(
    IN p_pharmacy_address VARCHAR(200),
    IN p_drug_id INT
)
BEGIN
	DECLARE drug_count INT;
    -- Check if relationship exists
    IF NOT EXISTS (SELECT 1 FROM Sells WHERE ph_address = p_pharmacy_address AND drug_id = p_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This drug is not being sold at this pharmacy';
    END IF;
    
    -- Check if this would reduce the pharmacy's drug count below 10

    SELECT COUNT(*) INTO drug_count FROM Sells WHERE ph_address = p_pharmacy_address;
    
    IF drug_count <= 10 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot remove drug from pharmacy. Each pharmacy must sell at least 10 drugs.';
    END IF;
    
    -- Delete the sells relationship
    DELETE FROM Sells
    WHERE ph_address = p_pharmacy_address AND drug_id = p_drug_id;
    
    SELECT CONCAT('Drug with ID ', p_drug_id, ' is no longer being sold at pharmacy at address ', p_pharmacy_address) AS result;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_sells_entry(
    IN p_pharmacy_address VARCHAR(200),
    IN p_drug_id INT,
    IN p_stock INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    -- Input validation
    IF p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
    
    IF p_price <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price must be positive';
    END IF;
    
    -- Check that pharmacy exists
    IF NOT EXISTS (SELECT 1 FROM Pharmacy WHERE address = p_pharmacy_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy does not exist';
    END IF;
    
    -- Check that drug exists
    IF NOT EXISTS (SELECT 1 FROM Drug WHERE drug_id = p_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Drug does not exist';
    END IF;
    
    -- Check if entry exists
    IF NOT EXISTS (SELECT 1 FROM Sells WHERE ph_address = p_pharmacy_address AND drug_id = p_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This drug is not being sold at this pharmacy. Use add_sells_entry instead.';
    END IF;
    
    -- Update the sells relationship
    UPDATE Sells
    SET stock = p_stock,
        price = p_price
    WHERE ph_address = p_pharmacy_address 
    AND drug_id = p_drug_id;
    
    SELECT CONCAT('Updated inventory for drug ID ', p_drug_id, ' at pharmacy address ', p_pharmacy_address, 
                 '. New stock: ', p_stock, ', New price: $', p_price) AS result;
END$$
DELIMITER ;

