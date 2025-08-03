DELIMITER $$
CREATE PROCEDURE add_pharmacy(
    IN p_name VARCHAR(100),
    IN p_address VARCHAR(200),
    IN p_phone VARCHAR(15)
)

BEGIN
    -- Insert pharmacy
    INSERT INTO Pharmacy(pname, address, phone)
    VALUES (p_name, p_address, p_phone);
    
    SELECT CONCAT('Pharmacy at address ', p_address, ' added successfully') AS result;
END$$
DELIMITER ;

-- Procedure to update a pharmacy
DELIMITER $$
CREATE PROCEDURE update_pharmacy(
    IN p_address VARCHAR(200),
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(15)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Pharmacy WHERE address = p_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy not found';
    END IF;
    
    UPDATE Pharmacy
    SET pname = p_name,
        phone = p_phone
    WHERE address = p_address;
    
    SELECT CONCAT('Pharmacy at address ', p_address, ' updated successfully') AS result;
END$$
DELIMITER ;

-- Procedure to delete a pharmacy
DELIMITER $$
CREATE PROCEDURE delete_pharmacy(
    IN p_address VARCHAR(200)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Pharmacy WHERE address = p_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy not found';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Delete from Sells (will cascade due to foreign key constraints)
    DELETE FROM Sells
    WHERE ph_address = p_address;
    
    -- Delete from Contract
    DELETE FROM Contract
    WHERE ph_address = p_address;
    
    -- Delete the pharmacy
    DELETE FROM Pharmacy
    WHERE address = p_address;
    
    COMMIT;
    
    SELECT CONCAT('Pharmacy at address ', p_address, ' deleted successfully') AS result;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE add_drug_to_pharmacy(
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This drug is already being sold at this pharmacy. Use update_drug_quantity instead.';
    END IF;
    
    -- Insert the new sells relationship
    INSERT INTO Sells(ph_address, drug_id, stock, price)
    VALUES (p_pharmacy_address, p_drug_id, p_stock, p_price);
    
    SELECT CONCAT('Drug with ID ', p_drug_id, ' is now being sold at pharmacy at address ', p_pharmacy_address, 
                 ' with initial stock of ', p_stock, ' units at $', p_price, ' per unit') AS result;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE delete_drug_from_pharmacy(
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
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Delete the sells relationship
    DELETE FROM Sells
    WHERE ph_address = p_pharmacy_address AND drug_id = p_drug_id;
    
    -- Commit the transaction
    COMMIT;
    
    SELECT CONCAT('Drug with ID ', p_drug_id, ' is no longer being sold at pharmacy at address ', p_pharmacy_address) AS result;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE update_drug_quantity(
    IN p_pharmacy_address VARCHAR(200),
    IN p_drug_id INT,
    IN p_new_stock INT,
    IN p_new_price DECIMAL(10,2)
)
BEGIN
    -- Input validation
    IF p_new_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
    END IF;
    
    IF p_new_price <= 0 THEN
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This drug is not being sold at this pharmacy. Use add_drug_to_pharmacy instead.';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Update the stock and price
    UPDATE Sells
    SET stock = p_new_stock,
        price = p_new_price
    WHERE ph_address = p_pharmacy_address 
    AND drug_id = p_drug_id;
    
    -- Commit the transaction
    COMMIT;
    
    SELECT CONCAT('Updated inventory for drug ID ', p_drug_id, ' at pharmacy address ', p_pharmacy_address, 
                 '. New stock: ', p_new_stock, ' units, New price: $', p_new_price, ' per unit') AS result;
END$$
DELIMITER ;
