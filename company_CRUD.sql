DELIMITER $$
CREATE PROCEDURE add_company(
    IN p_company_name VARCHAR(100),
    IN p_phone_number VARCHAR(15)
)
BEGIN
    -- Insert company
    INSERT INTO PharmaceuticalCompany(company_name, phone_number)
    VALUES (p_company_name, p_phone_number);
    
    SELECT CONCAT('Pharmaceutical company ', p_company_name, ' added successfully') AS result;
END$$
DELIMITER ;

-- Procedure to update a pharmaceutical company
DELIMITER $$
CREATE PROCEDURE update_company(
    IN p_old_name VARCHAR(100),
    IN p_new_name VARCHAR(100),
    IN p_new_phone VARCHAR(15)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed to update company information';
    END;
    
    -- Ensure old company exists
    IF NOT EXISTS (
        SELECT 1 FROM PharmaceuticalCompany WHERE company_name = p_old_name
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Company does not exist';
    END IF;
    
    -- If new name is different, check it doesn't already exist
    IF p_old_name != p_new_name AND EXISTS (
        SELECT 1 FROM PharmaceuticalCompany WHERE company_name = p_new_name
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A company with the new name already exists';
    END IF;
    
    START TRANSACTION;
    
    -- Update company information
    UPDATE PharmaceuticalCompany
    SET company_name = p_new_name,
        phone_number = p_new_phone
    WHERE company_name = p_old_name;
    
    -- If name changed, update related tables
    IF p_old_name != p_new_name THEN
        -- Update Drug table
        UPDATE Drug
        SET company_name = p_new_name
        WHERE company_name = p_old_name;
        
        -- Update Contract table
        UPDATE Contract
        SET company_name = p_new_name
        WHERE company_name = p_old_name;
    END IF;
    
    COMMIT;
    
    SELECT CONCAT('Company ', p_old_name, ' updated to ', p_new_name, ' successfully') AS result;
END$$
DELIMITER ;

-- Procedure to delete a pharmaceutical company
DELIMITER $$
CREATE PROCEDURE delete_company(
    IN p_company_name VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PharmaceuticalCompany WHERE company_name = p_company_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Company does not exist';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Delete from Contract
    DELETE FROM Contract
    WHERE company_name = p_company_name;
    
    -- Delete the company (will cascade to Drug and then to Contains_drug and Sells)
    DELETE FROM PharmaceuticalCompany
    WHERE company_name = p_company_name;
    
    COMMIT;
    
    SELECT CONCAT('Pharmaceutical company ', p_company_name, ' deleted successfully') AS result;
END$$
DELIMITER ;

