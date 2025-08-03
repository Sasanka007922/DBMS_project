DELIMITER $$
CREATE PROCEDURE prescription_report(
    IN p_patient_id VARCHAR(12),
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        pr.pres_date AS Prescription_Date,
        pt.p_name AS Patient_Name,
        d.d_name AS Doctor_Name,
        dr.trade_name AS Drug_Name,
        cd.quantity AS Quantity
    FROM Prescription pr
    JOIN Patient pt ON pr.pid = pt.paadharid
    JOIN Doctor d ON pr.did = d.daadharid
    JOIN Contains_drug cd ON pr.pres_id = cd.pres_id
    JOIN Drug dr ON cd.drug_id = dr.drug_id
    WHERE pr.pid = p_patient_id
    AND pr.pres_date BETWEEN p_start_date AND p_end_date
    ORDER BY pr.pres_date DESC;
END$$
DELIMITER ;

-- Procedure to print details of a prescription for a given patient and date
DELIMITER $$
CREATE PROCEDURE print_pres_details(
    IN p_patient_id VARCHAR(12),
    IN p_pres_date DATE
)
BEGIN
    SELECT
        p.pres_date AS Prescription_Date,
        pt.p_name AS Patient_Name,
        d.d_name AS Doctor_Name,
        dr.trade_name AS Drug_Name,
        dr.formula AS Drug_Formula,
        c.quantity AS Quantity,
        pc.company_name AS Manufacturer
    FROM Prescription p
    JOIN Patient pt ON p.pid = pt.paadharid
    JOIN Doctor d ON p.did = d.daadharid
    JOIN Contains_drug c ON p.pres_id = c.pres_id
    JOIN Drug dr ON c.drug_id = dr.drug_id
    JOIN PharmaceuticalCompany pc ON dr.company_name = pc.company_name
    WHERE p.pid = p_patient_id
    AND p.pres_date = p_pres_date;
END$$
DELIMITER ;

-- Procedure to get details of drugs produced by a pharmaceutical company
DELIMITER $$
CREATE PROCEDURE drug_details(
    IN p_company_name VARCHAR(100)
)
BEGIN
    SELECT
        d.drug_id AS Drug_ID,
        d.trade_name AS Drug_Name,
        d.formula AS Formula,
        pc.company_name AS Manufacturer,
        pc.phone_number AS Contact_Number
    FROM Drug d
    JOIN PharmaceuticalCompany pc ON d.company_name = pc.company_name
    WHERE d.company_name = p_company_name
    ORDER BY d.trade_name;
END$$
DELIMITER ;

-- Procedure to print stock position of a pharmacy
DELIMITER $$
CREATE PROCEDURE print_stock_position(
    IN p_pharmacy_address VARCHAR(200)
)
BEGIN
    SELECT
        p.pname AS Pharmacy_Name,
        p.address AS Pharmacy_Address,
        d.trade_name AS Drug_Name,
        pc.company_name AS Manufacturer,
        s.stock AS Stock_Position,
        s.price AS Price
    FROM Pharmacy p
    JOIN Sells s ON p.address = s.ph_address
    JOIN Drug d ON s.drug_id = d.drug_id
    JOIN PharmaceuticalCompany pc ON d.company_name = pc.company_name
    WHERE p.address = p_pharmacy_address
    ORDER BY d.trade_name;
END$$
DELIMITER ;

-- Procedure to print pharmacy contact details
DELIMITER $$
CREATE PROCEDURE print_pharmacy_contact(
    IN p_pharmacy_address VARCHAR(200)
)
BEGIN
    SELECT
        p.pname AS Pharmacy_Name,
        p.address AS Pharmacy_Address,
        p.phone AS Pharmacy_Contact
    FROM Pharmacy p
    WHERE p.address = p_pharmacy_address;
END$$
DELIMITER ;

-- Procedure to print pharmaceutical company contact details
DELIMITER $$
CREATE PROCEDURE print_company_contact(
    IN p_company_name VARCHAR(100)
)
BEGIN
    SELECT
        c.company_name AS Company_Name,
        c.phone_number AS Company_Contact
    FROM PharmaceuticalCompany c
    WHERE c.company_name = p_company_name;
END$$
DELIMITER ;

-- Procedure to print patients for a given doctor
DELIMITER $$
CREATE PROCEDURE print_patients_for_doctor(
    IN p_doctor_id VARCHAR(12)
)
BEGIN
    SELECT
        pt.paadharid AS Patient_ID,
        pt.p_name AS Patient_Name,
        pt.age AS Patient_Age,
        pt.address AS Patient_Address,
        CASE WHEN pt.p_daadharid = p_doctor_id THEN 'Yes' ELSE 'No' END AS Is_Primary_Physician
    FROM Patient pt
    JOIN Treats t ON pt.paadharid = t.pid
    WHERE t.did = p_doctor_id
    ORDER BY pt.p_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE display_contract(
    IN p_pharmacy_address VARCHAR(200),
    IN p_pharmacy_name VARCHAR(100),
    IN p_company_name VARCHAR(100)
)
BEGIN
    DECLARE contract_count INT;

    -- Input validation
    IF p_pharmacy_address IS NULL OR p_pharmacy_address = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy address is required';
    END IF;
    
    IF p_company_name IS NULL OR p_company_name = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmaceutical company name is required';
    END IF;
    
    -- Verify pharmacy exists with given address and name
    IF NOT EXISTS (
        SELECT 1 FROM Pharmacy 
        WHERE address = p_pharmacy_address 
        AND pname = p_pharmacy_name
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmacy not found with the given address and name';
    END IF;
    
    -- Verify company exists
    IF NOT EXISTS (
        SELECT 1 FROM PharmaceuticalCompany 
        WHERE company_name = p_company_name
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pharmaceutical company not found';
    END IF;
    
    -- Retrieve contract information
    SELECT 
        c.company_name AS 'Company Name',
        pc.phone_number AS 'Company Phone',
        p.pname AS 'Pharmacy Name',
        p.address AS 'Pharmacy Address',
        p.phone AS 'Pharmacy Phone',
        c.start_date AS 'Contract Start Date',
        c.end_date AS 'Contract End Date',
        c.supervisor AS 'Contract Supervisor',
        c.content AS 'Contract Content',
        CASE 
            WHEN c.end_date < CURDATE() THEN 'Expired'
            WHEN c.start_date > CURDATE() THEN 'Future'
            ELSE 'Active'
        END AS 'Contract Status',
        DATEDIFF(c.end_date, CURDATE()) AS 'Days Remaining'
    FROM Contract c
    JOIN Pharmacy p ON c.ph_address = p.address
    JOIN PharmaceuticalCompany pc ON c.company_name = pc.company_name
    WHERE c.ph_address = p_pharmacy_address
    AND p.pname = p_pharmacy_name
    AND c.company_name = p_company_name;
    
    -- If no contract exists, provide a clear message
    SELECT COUNT(*) INTO contract_count
FROM contract
WHERE pharmacy_id = some_pharmacy_id AND company_id = some_company_id;

IF contract_count = 0 THEN
    SELECT 'No contract exists between this pharmacy and pharmaceutical company' AS Message;
END IF;
END$$
DELIMITER ;


