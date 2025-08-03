DELIMITER $$
CREATE PROCEDURE add_treats_entry(
    IN p_doctor_id VARCHAR(12),
    IN p_patient_id VARCHAR(12)
)
BEGIN
    -- Check that doctor exists
    IF NOT EXISTS (SELECT 1 FROM Doctor WHERE daadharid = p_doctor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor does not exist.';
    END IF;
    
    -- Check that patient exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE paadharid = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patient does not exist.';
    END IF;
    
    -- Check if relationship already exists
    IF EXISTS (SELECT 1 FROM Treats WHERE did = p_doctor_id AND pid = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This doctor-patient relationship already exists.';
    END IF;
    
    -- Insert treats relationship
    INSERT INTO Treats(did, pid)
    VALUES (p_doctor_id, p_patient_id);
    
    SELECT CONCAT('Doctor ', p_doctor_id, ' now treats patient ', p_patient_id) AS result;
END$$
DELIMITER ;

-- Procedure to delete a treats relationship
DELIMITER $$
CREATE PROCEDURE delete_treats_entry(
    IN p_doctor_id VARCHAR(12),
    IN p_patient_id VARCHAR(12)
)
BEGIN
    -- Check if relationship exists
    IF NOT EXISTS (SELECT 1 FROM Treats WHERE did = p_doctor_id AND pid = p_patient_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This doctor-patient relationship does not exist.';
    END IF;
    
    -- Check if this is the doctor's only patient
    IF (SELECT COUNT(*) FROM Treats WHERE did = p_doctor_id) <= 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot remove the only patient from a doctor. Every doctor must have at least one patient.';
    END IF;
    
    -- Check if this patient has the doctor as primary physician
    IF EXISTS (SELECT 1 FROM Patient WHERE paadharid = p_patient_id AND p_daadharid = p_doctor_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot remove relationship with primary physician. Update patient''s primary physician first.';
    END IF;
    
    -- Delete treats relationship
    DELETE FROM Treats
    WHERE did = p_doctor_id AND pid = p_patient_id;
    
    SELECT CONCAT('Relationship between doctor ', p_doctor_id, ' and patient ', p_patient_id, ' removed successfully') AS result;
END$$
DELIMITER ;
