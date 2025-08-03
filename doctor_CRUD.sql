DELIMITER $$
CREATE PROCEDURE add_doctor(
    IN p_id VARCHAR(12),
    IN p_name VARCHAR(100),
    IN p_speciality VARCHAR(100),
    IN p_years_exp INT
)
BEGIN
    -- Check years of experience
    IF p_years_exp < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Years of experience cannot be negative.';
    END IF;
    
    -- Insert doctor
    INSERT INTO Doctor(daadharid, d_name, speciality, years_of_experience)
    VALUES (p_id, p_name, p_speciality, p_years_exp);
    
    SELECT CONCAT('Doctor ', p_id, ' added successfully. Remember to assign at least one patient to this doctor.') AS result;
END$$
DELIMITER ;

-- Procedure to update a doctor
DELIMITER $$
CREATE PROCEDURE update_doctor(
    IN d_id VARCHAR(12),
    IN new_name VARCHAR(100),
    IN new_spec VARCHAR(100),
    IN new_exp INT,
    IN new_pid VARCHAR(12)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = d_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor not found.';
    END IF;
    
    IF new_exp < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid experience.';
    END IF;
    
    START TRANSACTION;
    
    UPDATE Doctor
    SET d_name = new_name,
        speciality = new_spec,
        years_of_experience = new_exp
    WHERE daadharid = d_id;
    
    IF new_pid IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM Patient WHERE paadharid = new_pid) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient not found.';
        END IF;
        
        INSERT INTO Treats(did, pid)
        VALUES (d_id, new_pid)
        ON DUPLICATE KEY UPDATE pid = VALUES(pid);
    END IF;
    
    COMMIT;
    
    SELECT CONCAT('Doctor ', d_id, ' updated successfully') AS result;
END$$
DELIMITER ;

-- Procedure to delete a doctor
DELIMITER $$
CREATE PROCEDURE delete_doctor(
    IN p_doctor_id VARCHAR(12)
)
BEGIN
    -- First check if the doctor exists
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_doctor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor does not exist';
    END IF;
    
    -- Check if doctor is a primary physician for any patient
    IF EXISTS (SELECT 1 FROM Patient WHERE p_daadharid = p_doctor_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete doctor: Doctor is the primary physician for one or more patients';
    END IF;
    
    -- Start transaction for consistency
    START TRANSACTION;
    
    -- Delete treats relationships
    DELETE FROM Treats WHERE did = p_doctor_id;
    
    -- Delete prescriptions (will cascade to Contains_drug)
    DELETE FROM Prescription WHERE did = p_doctor_id;
    
    -- Now it's safe to delete the doctor
    DELETE FROM Doctor WHERE daadharid = p_doctor_id;
    
    COMMIT;
    
    SELECT CONCAT('Doctor ', p_doctor_id, ' successfully deleted') AS result;
END$$
DELIMITER ;