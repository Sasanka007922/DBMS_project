DELIMITER $$
CREATE PROCEDURE add_contract(
    IN p_company_name VARCHAR(100),
    IN p_pharmacy_address VARCHAR(200),
    IN p_content TEXT,
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_supervisor VARCHAR(100)
)
BEGIN
    -- Check that company exists
    IF NOT EXISTS (SELECT 1 FROM PharmaceuticalCompany WHERE company_name = p_company_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmaceutical company does not exist.';
    END IF;
    
    -- Check that pharmacy exists
    IF NOT EXISTS (SELECT 1 FROM Pharmacy WHERE address = p_pharmacy_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy does not exist.';
    END IF;
    
    -- Check that start date is before end date
    IF p_start_date > p_end_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contract start date must be before end date.';
    END IF;
    
    -- Check if contract already exists
    IF EXISTS (SELECT 1 FROM Contract WHERE company_name = p_company_name AND ph_address = p_pharmacy_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A contract already exists between this company and pharmacy.';
    END IF;
    
    -- Insert contract
    INSERT INTO Contract(company_name, ph_address, content, start_date, end_date, supervisor)
    VALUES (p_company_name, p_pharmacy_address, p_content, p_start_date, p_end_date, p_supervisor);
    
    SELECT CONCAT('Contract between ', p_company_name, ' and pharmacy at ', p_pharmacy_address, ' added successfully') AS result;
END$$
DELIMITER ;

-- Procedure to update a contract
DELIMITER $$
CREATE PROCEDURE update_contract(
    IN p_company_name VARCHAR(100),
    IN p_pharmacy_address VARCHAR(200),
    IN p_content TEXT,
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_supervisor VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Contract
        WHERE company_name = p_company_name AND ph_address = p_pharmacy_address
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contract not found.';
    END IF;
    
    IF p_start_date > p_end_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Start date must be before end date.';
    END IF;
    
    UPDATE Contract
    SET content = p_content,
        start_date = p_start_date,
        end_date = p_end_date,
        supervisor = p_supervisor
    WHERE company_name = p_company_name AND ph_address = p_pharmacy_address;
    
    SELECT CONCAT('Contract between ', p_company_name, ' and pharmacy at ', p_pharmacy_address, ' updated successfully') AS result;
END$$
DELIMITER ;

-- Procedure to update contract supervisor
DELIMITER $$
CREATE PROCEDURE update_contract_supervisor(
    IN p_company_name VARCHAR(100),
    IN p_pharmacy_address VARCHAR(200),
    IN p_new_supervisor VARCHAR(100)
)
BEGIN
    -- Check if contract exists
    IF NOT EXISTS (SELECT 1 FROM Contract
    WHERE company_name = p_company_name AND ph_address = p_pharmacy_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contract does not exist.';
    END IF;
    
    -- Update supervisor
    UPDATE Contract
    SET supervisor = p_new_supervisor
    WHERE company_name = p_company_name AND ph_address = p_pharmacy_address;
    
    SELECT CONCAT('Supervisor for contract between ', p_company_name, ' and pharmacy at ', p_pharmacy_address, ' updated to ', p_new_supervisor) AS result;
END$$
DELIMITER ;

-- Procedure to delete a contract
DELIMITER $$
CREATE PROCEDURE delete_contract(
    IN p_company_name VARCHAR(100),
    IN p_pharmacy_address VARCHAR(200)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Contract 
    WHERE company_name = p_company_name AND ph_address = p_pharmacy_address) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contract does not exist.';
    END IF;
    
    -- Delete the contract
    DELETE FROM Contract
    WHERE company_name = p_company_name AND ph_address = p_pharmacy_address;
    
    SELECT CONCAT('Contract between ', p_company_name, ' and pharmacy at ', p_pharmacy_address, ' deleted successfully') AS result;
END$$
DELIMITER ;
