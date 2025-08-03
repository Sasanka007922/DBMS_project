DELIMITER $$
CREATE PROCEDURE add_patient(
    IN p_id VARCHAR(12),
    IN p_name VARCHAR(100),
    IN p_age INT,
    IN p_address VARCHAR(100),
    IN p_primary_physician_id VARCHAR(12),
    IN p_additional_doctor_id VARCHAR(12)
)
BEGIN
    -- Input validation
    IF p_age < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Age cannot be negative.';
    END IF;
    
    -- Check that primary physician exists
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_primary_physician_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primary physician does not exist.';
    END IF;
    
    -- Check that additional doctor exists if provided
    IF p_additional_doctor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_additional_doctor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Additional doctor does not exist.';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Insert patient with primary physician
    INSERT INTO Patient(paadharid, p_name, age, address, p_daadharid)
    VALUES (p_id, p_name, p_age, p_address, p_primary_physician_id);
    
    -- Create treats relationship with primary physician
    -- (This is now handled by the trigger ensure_primary_physician_treats)
    
    -- If additional doctor is provided and different from primary physician,
    -- create another treats relationship
    IF p_additional_doctor_id IS NOT NULL AND p_additional_doctor_id != p_primary_physician_id THEN
        INSERT INTO Treats(pid, did)
        VALUES (p_id, p_additional_doctor_id);
    END IF;
    
    -- Commit transaction
    COMMIT;
    
    SELECT CONCAT('Patient ', p_id, ' added successfully with primary physician ', 
                 p_primary_physician_id, 
                 IF(p_additional_doctor_id IS NOT NULL AND p_additional_doctor_id != p_primary_physician_id, 
                    CONCAT(' and additional doctor ', p_additional_doctor_id), 
                    '')) AS result;
END$$
DELIMITER ;

-- Procedure to update a patient
DELIMITER $$
CREATE PROCEDURE update_patient(
    IN p_patient_id VARCHAR(12),
    IN p_patient_name VARCHAR(100),
    IN p_age INT,
    IN p_address VARCHAR(100),
    IN p_primary_physician_id VARCHAR(12),
    IN p_additional_doctor_id VARCHAR(12)
)
BEGIN
    -- Input validation
    IF p_age < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Age cannot be negative';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE paadharid = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient does not exist';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_primary_physician_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primary physician does not exist';
    END IF;
    
    IF p_additional_doctor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_additional_doctor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Additional doctor does not exist';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Update Patient details
    UPDATE Patient
    SET p_name = p_patient_name,
        age = p_age,
        address = p_address,
        p_daadharid = p_primary_physician_id
    WHERE paadharid = p_patient_id;
    
    -- If additional doctor is provided and different from primary physician,
    -- create another treats relationship
    IF p_additional_doctor_id IS NOT NULL AND p_additional_doctor_id != p_primary_physician_id THEN
        IF NOT EXISTS (
            SELECT 1 FROM Treats
            WHERE pid = p_patient_id AND did = p_additional_doctor_id
        ) THEN
            INSERT INTO Treats(pid, did)
            VALUES (p_patient_id, p_additional_doctor_id);
        END IF;
    END IF;
    
    COMMIT;
    
    SELECT CONCAT('Patient ', p_patient_id, ' updated successfully') AS result;
END$$
DELIMITER ;

-- Procedure to delete a patient
DELIMITER $$
CREATE PROCEDURE delete_patient(
    IN p_patient_id VARCHAR(12)
)
BEGIN
    -- Declare variables
    DECLARE doctor_id VARCHAR(12);
    DECLARE patient_count INT;
    
    -- Declare handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction if an error occurs
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Failed to delete patient - constraint violation';
    END;
    
    -- Check if patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE paadharid = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient does not exist';
    END IF;
    
    -- Get the primary physician ID for this patient
    SELECT p_daadharid INTO doctor_id FROM Patient WHERE paadharid = p_patient_id;
    
    -- Count how many patients this doctor has
    SELECT COUNT(*) INTO patient_count FROM Treats WHERE did = doctor_id;
    
    -- Check if this is the doctor's only patient
    IF patient_count <= 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete patient: This is the only patient for their doctor. Every doctor must have at least one patient.';
    END IF;
    
    -- Start transaction to ensure all-or-nothing operation
    START TRANSACTION;
    
    -- Delete associated Treats relationships first
    DELETE FROM Treats WHERE pid = p_patient_id;
    
    -- Delete associated Prescriptions
    -- Note: The Prescription deletion should cascade to Contains_drug due to ON DELETE CASCADE
    DELETE FROM Prescription WHERE pid = p_patient_id;
    
    -- Finally delete the patient record
    DELETE FROM Patient WHERE paadharid = p_patient_id;
    
    -- Commit the transaction if all operations succeed
    COMMIT;
    
    SELECT CONCAT('Patient ', p_patient_id, ' successfully deleted with all related records') AS result;
END$$
DELIMITER ;
