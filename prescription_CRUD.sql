DELIMITER $$
CREATE PROCEDURE add_prescription(
    IN p_pid VARCHAR(12),
    IN p_did VARCHAR(12),
    IN p_pres_date DATE,
    IN p_drug_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE new_pres_id INT;
    
    -- Validate patient
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE paadharid = p_pid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient does not exist.';
    END IF;
    
    -- Validate doctor
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_did) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor does not exist.';
    END IF;
    
    -- Validate drug
    IF NOT EXISTS (SELECT 1 FROM Drug WHERE drug_id = p_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Drug does not exist.';
    END IF;
    
    -- Validate quantity
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be positive.';
    END IF;
    
    -- Validate doctor-patient relationship
    IF NOT EXISTS (SELECT 1 FROM Treats WHERE did = p_did AND pid = p_pid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This doctor does not treat this patient.';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Delete older prescriptions for this doctor-patient pair
    DELETE FROM Prescription
    WHERE pid = p_pid AND did = p_did AND pres_date < p_pres_date;
    
    -- Insert new prescription
    INSERT INTO Prescription(pid, did, pres_date)
    VALUES (p_pid, p_did, p_pres_date);
    
    -- Get the new prescription ID
    SET new_pres_id = LAST_INSERT_ID();
    
    -- Link the prescribed drug
    INSERT INTO Contains_drug(pres_id, drug_id, quantity)
    VALUES (new_pres_id, p_drug_id, p_quantity);
    
    COMMIT;
    
    SELECT CONCAT('Prescription added successfully for patient ', p_pid, ' from doctor ', p_did, ' on date ', p_pres_date) AS result;
END$$
DELIMITER ;

-- Procedure to delete a prescription
DELIMITER $$
CREATE PROCEDURE delete_prescription(
    IN p_pid VARCHAR(12),
    IN p_did VARCHAR(12),
    IN p_pres_date DATE
)
BEGIN
    DECLARE pres_id_var INT;
    
    -- Check that the prescription exists
    SELECT pres_id INTO pres_id_var
    FROM Prescription
    WHERE pid = p_pid AND did = p_did AND pres_date = p_pres_date;
    
    IF pres_id_var IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prescription not found.';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Delete the drug details from Contains_drug (will cascade)
    -- Delete the prescription itself (will cascade to Contains_drug)
    DELETE FROM Prescription
    WHERE pres_id = pres_id_var;
    
    COMMIT;
    
    SELECT CONCAT('Prescription for patient ', p_pid, ' from doctor ', p_did, ' on date ', p_pres_date, ' deleted successfully') AS result;
END$$
DELIMITER ;

-- Procedure to update a prescription
DELIMITER $$
CREATE PROCEDURE update_prescription(
    IN p_old_pid VARCHAR(12),
    IN p_old_did VARCHAR(12),
    IN p_old_pres_date DATE,
    IN p_new_pid VARCHAR(12),
    IN p_new_did VARCHAR(12),
    IN p_new_pres_date DATE,
    IN p_new_drug_id INT,
    IN p_new_quantity INT
)
BEGIN
    DECLARE pres_id_var INT;
    
    -- Check that the old prescription exists
    SELECT pres_id INTO pres_id_var
    FROM Prescription
    WHERE pid = p_old_pid AND did = p_old_did AND pres_date = p_old_pres_date;
    
    IF pres_id_var IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Original prescription not found.';
    END IF;
    
    -- Check that the new patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE paadharid = p_new_pid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New patient does not exist.';
    END IF;
    
    -- Check that the new doctor exists
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_new_did) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New doctor does not exist.';
    END IF;
    
    -- Check that the new drug exists
    IF NOT EXISTS (SELECT 1 FROM Drug WHERE drug_id = p_new_drug_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New drug does not exist.';
    END IF;
    
    -- Validate quantity
    IF p_new_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be positive.';
    END IF;
    
    -- Validate doctor-patient relationship
    IF NOT EXISTS (SELECT 1 FROM Treats WHERE did = p_new_did AND pid = p_new_pid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The new doctor does not treat the new patient.';
    END IF;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Update the prescription
    UPDATE Prescription
    SET pid = p_new_pid,
        did = p_new_did,
        pres_date = p_new_pres_date
    WHERE pres_id = pres_id_var;
    
    -- Update the drug details in Contains_drug
    -- First delete existing drug entries
    DELETE FROM Contains_drug
    WHERE pres_id = pres_id_var;
    
    -- Then add the new drug
    INSERT INTO Contains_drug(pres_id, drug_id, quantity)
    VALUES (pres_id_var, p_new_drug_id, p_new_quantity);
    
    COMMIT;
    
    SELECT CONCAT('Prescription updated successfully') AS result;
END$$
DELIMITER ;