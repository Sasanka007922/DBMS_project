DELIMITER $$
CREATE PROCEDURE add_drug(
    IN p_trade_name VARCHAR(100),
    IN p_formula VARCHAR(200),
    IN p_company_name VARCHAR(100)
)
BEGIN
    -- Check that company exists
    IF NOT EXISTS (SELECT 1 FROM PharmaceuticalCompany WHERE company_name = p_company_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmaceutical company does not exist.';
    END IF;
    
    -- Check if drug already exists for this company
    IF EXISTS (SELECT 1 FROM Drug WHERE trade_name = p_trade_name AND company_name = p_company_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This drug already exists for this company.';
    END IF;
    
    -- Insert drug
    INSERT INTO Drug(trade_name, formula, company_name)
    VALUES (p_trade_name, p_formula, p_company_name);
    
    SELECT CONCAT('Drug ', p_trade_name, ' added successfully for company ', p_company_name) AS result;
END$$
DELIMITER ;

-- Procedure to delete a drug
DELIMITER $$
CREATE PROCEDURE delete_drug(
    IN p_trade_name VARCHAR(100),
    IN p_company_name VARCHAR(100)
)
BEGIN
    DECLARE drug_id_var INT;
    
    -- Check if drug exists
    SELECT drug_id INTO drug_id_var
    FROM Drug 
    WHERE trade_name = p_trade_name AND company_name = p_company_name;
    
    IF drug_id_var IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Drug does not exist.';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Delete from Contains_drug (will cascade from Drug deletion)
    -- Delete from Sells (will cascade from Drug deletion)
    
    -- Delete the drug
    DELETE FROM Drug
    WHERE drug_id = drug_id_var;
    
    COMMIT;
    
    SELECT CONCAT('Drug ', p_trade_name, ' from company ', p_company_name, ' deleted successfully') AS result;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_drug(
    IN p_old_trade_name VARCHAR(100),
    IN p_company_name VARCHAR(100),
    IN p_new_trade_name VARCHAR(100),
    IN p_new_formula VARCHAR(200)
)
BEGIN
    DECLARE drug_id_var INT;
    
    -- Check if company exists
    IF NOT EXISTS (SELECT 1 FROM PharmaceuticalCompany WHERE company_name = p_company_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmaceutical company does not exist.';
    END IF;
    
    -- Check if original drug exists
    SELECT drug_id INTO drug_id_var
    FROM Drug 
    WHERE trade_name = p_old_trade_name AND company_name = p_company_name;
    
    IF drug_id_var IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Drug does not exist.';
    END IF;
    
    -- Check if new trade name already exists for this company (if changing the name)
    IF p_old_trade_name != p_new_trade_name AND 
       EXISTS (SELECT 1 FROM Drug WHERE trade_name = p_new_trade_name AND company_name = p_company_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A drug with the new trade name already exists for this company.';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Update the drug
    UPDATE Drug
    SET trade_name = p_new_trade_name,
        formula = CASE WHEN p_new_formula IS NULL OR p_new_formula = '' THEN formula ELSE p_new_formula END
    WHERE drug_id = drug_id_var;
    
    COMMIT;
    
    SELECT CONCAT('Drug updated from ', p_old_trade_name, ' to ', p_new_trade_name, ' for company ', p_company_name, ' successfully') AS result;
END$$
DELIMITER ;
