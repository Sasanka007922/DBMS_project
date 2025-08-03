/*
Nova Medical Database Comprehensive Test Suite
This script tests all CRUD operations and business rules
*/

USE nova;

-- Test Group 1: Pharmaceutical Company Tests
SELECT '========== PHARMACEUTICAL COMPANY TESTS ==========' AS '';

-- Test 1.1: Create company
SELECT 'Test 1.1: Create new company' AS '';
CALL add_company('AstraZeneca', '1122334455');

-- Test 1.2: Try to create duplicate company (should fail)
SELECT 'Test 1.2: Try to create duplicate company (should fail)' AS '';
-- This should fail
CALL add_company('AstraZeneca', '5566778899');

-- Test 1.3: Update company
SELECT 'Test 1.3: Update company' AS '';
CALL update_company('AstraZeneca', 'AstraZeneca UK', '9988776655');

-- Test 1.4: Update company with existing name (should fail)
SELECT 'Test 1.4: Update company with existing name (should fail)' AS '';
-- This should fail
CALL update_company('AstraZeneca UK', 'Pfizer', '9988776655');

-- Test 1.5: Delete company
SELECT 'Test 1.5: Delete company' AS '';
CALL delete_company('AstraZeneca UK');

-- Test Group 2: Pharmacy Tests
SELECT '========== PHARMACY TESTS ==========' AS '';

-- Test 2.1: Create pharmacy
SELECT 'Test 2.1: Create new pharmacy' AS '';
CALL add_pharmacy('NewMed Pharmacy', '111 New St, City', '1112223333');

-- Test 2.2: Update pharmacy
SELECT 'Test 2.2: Update pharmacy' AS '';
CALL update_pharmacy('111 New St, City', 'NewMed Plus', '3332221111');

-- Test 2.3: Add drugs to pharmacy
SELECT 'Test 2.3: Add drugs to pharmacy' AS '';
-- We need at least 10 drugs for our test pharmacy
SET @drug_counter = 1;
WHILE @drug_counter <= 10 DO
    CALL add_drug_to_pharmacy('111 New St, City', @drug_counter, 100, 9.99);
    SET @drug_counter = @drug_counter + 1;
END WHILE;

-- Test 2.4: Update drug quantity
SELECT 'Test 2.4: Update drug quantity' AS '';
CALL update_drug_quantity('111 New St, City', 1, 150, 10.99);

-- Test 2.5: Try to delete drug when pharmacy has exactly 10 drugs (should fail)
SELECT 'Test 2.5: Try to delete drug when pharmacy has exactly 10 drugs (should fail)' AS '';
-- This should fail
CALL delete_drug_from_pharmacy('111 New St, City', 1);

-- Test 2.6: Add another drug
SELECT 'Test 2.6: Add another drug' AS '';
CALL add_drug_to_pharmacy('111 New St, City', 11, 100, 9.99);

-- Test 2.7: Now try to delete a drug (should succeed)
SELECT 'Test 2.7: Now try to delete a drug (should succeed)' AS '';
CALL delete_drug_from_pharmacy('111 New St, City', 11);

-- Test 2.8: Delete pharmacy
SELECT 'Test 2.8: Delete pharmacy' AS '';
CALL delete_pharmacy('111 New St, City');

-- Test Group 3: Doctor Tests
SELECT '========== DOCTOR TESTS ==========' AS '';

-- Test 3.1: Create doctor
SELECT 'Test 3.1: Create new doctor' AS '';
CALL add_doctor('DOC101', 'Dr. Test Doctor', 'General Medicine', 5);

-- Test 3.2: Create doctor with negative experience (should fail)
SELECT 'Test 3.2: Create doctor with negative experience (should fail)' AS '';
-- This should fail
CALL add_doctor('DOC102', 'Dr. Negative Exp', 'Surgery', -2);

-- Test 3.3: Update doctor
SELECT 'Test 3.3: Update doctor' AS '';
CALL update_doctor('DOC101', 'Dr. Test Updated', 'Internal Medicine', 6, NULL);

-- Test 3.4: Try to delete doctor without patients (should fail indirectly)
SELECT 'Test 3.4: Try to delete doctor without patients (should fail indirectly)' AS '';
-- This should fail because a doctor needs at least one patient
CALL delete_doctor('DOC101');

-- Test 3.5: Add patient to doctor
SELECT 'Test 3.5: Add patient to doctor' AS '';
CALL add_patient('PAT101', 'Test Patient', 40, '101 Test St', 'DOC101', NULL);

-- Test 3.6: Now try to delete doctor with patient (should succeed)
SELECT 'Test 3.6: Now try to delete doctor with patient (should fail with primary physician constraint)' AS '';
-- This should fail because doctor is a primary physician
CALL delete_doctor('DOC101');

-- Test 3.7: Create another doctor and update patient's primary physician
SELECT 'Test 3.7: Create another doctor and update patient primary physician' AS '';
CALL add_doctor('DOC102', 'Dr. Another Test', 'Family Medicine', 8);
CALL add_treats_entry('DOC102', 'PAT101');
CALL update_patient('PAT101', 'Test Patient', 40, '101 Test St', 'DOC102', 'DOC101');

-- Test 3.8: Now try to delete the first doctor (should succeed)
SELECT 'Test 3.8: Now try to delete the first doctor (should succeed)' AS '';
CALL delete_doctor('DOC101');

-- Test Group 4: Patient Tests
SELECT '========== PATIENT TESTS ==========' AS '';

-- Test 4.1: Create another patient
SELECT 'Test 4.1: Create another patient' AS '';
CALL add_patient('PAT102', 'Another Test Patient', 50, '102 Test Ave', 'DOC102', NULL);

-- Test 4.2: Create patient with negative age (should fail)
SELECT 'Test 4.2: Create patient with negative age (should fail)' AS '';
-- This should fail
CALL add_patient('PAT103', 'Negative Age Patient', -5, '103 Test Blvd', 'DOC102', NULL);

-- Test 4.3: Update patient
SELECT 'Test 4.3: Update patient' AS '';
CALL update_patient('PAT102', 'Updated Test Patient', 51, '102 Updated Ave', 'DOC102', NULL);

-- Test 4.4: Delete patient
SELECT 'Test 4.4: Delete patient' AS '';
CALL delete_patient('PAT102');

-- Test 4.5: Try to delete last patient of doctor (should fail)
SELECT 'Test 4.5: Try to delete last patient of doctor (should fail)' AS '';
-- This should fail because every doctor must have at least one patient
CALL delete_patient('PAT101');

-- Test Group 5: Drug Tests
SELECT '========== DRUG TESTS ==========' AS '';

-- Test 5.1: Create new drug
SELECT 'Test 5.1: Create new drug' AS '';
CALL add_drug('TestDrug', 'C10H15O10', 'Merck');

-- Test 5.2: Try to create duplicate drug for same company (should fail)
SELECT 'Test 5.2: Try to create duplicate drug for same company (should fail)' AS '';
-- This should fail
CALL add_drug('TestDrug', 'C10H15O10', 'Merck');

-- Test 5.3: Create same drug name but for different company (should succeed)
SELECT 'Test 5.3: Create same drug name but for different company (should succeed)' AS '';
CALL add_drug('TestDrug', 'C10H15O10', 'Pfizer');

-- Test 5.4: Update drug
SELECT 'Test 5.4: Update drug' AS '';
CALL update_drug('TestDrug', 'Merck', 'TestDrug Plus', 'C10H15O10N');

-- Test 5.5: Delete drug
SELECT 'Test 5.5: Delete drug' AS '';
CALL delete_drug('TestDrug Plus', 'Merck');
CALL delete_drug('TestDrug', 'Pfizer');

-- Test Group 6: Prescription Tests
SELECT '========== PRESCRIPTION TESTS ==========' AS '';

-- Test 6.1: Create prescription
SELECT 'Test 6.1: Create prescription' AS '';
CALL add_prescription('PAT101', 'DOC102', CURDATE(), 1, 30);

-- Test 6.2: Try to create prescription with invalid quantity (should fail)
SELECT 'Test 6.2: Try to create prescription with invalid quantity (should fail)' AS '';
-- This should fail
CALL add_prescription('PAT101', 'DOC102', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 0);

-- Test 6.3: Update prescription
SELECT 'Test 6.3: Update prescription' AS '';
CALL update_prescription('PAT101', 'DOC102', CURDATE(), 'PAT101', 'DOC102', CURDATE(), 3, 60);

-- Test 6.4: Delete prescription
SELECT 'Test 6.4: Delete prescription' AS '';
CALL delete_prescription('PAT101', 'DOC102', CURDATE());

-- Test Group 7: Contract Tests
SELECT '========== CONTRACT TESTS ==========' AS '';

-- Test 7.1: Create contract
SELECT 'Test 7.1: Create contract' AS '';
CALL add_contract('Merck', '321 Elm Blvd, County', 'Test contract content', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 'Test Supervisor');

-- Test 7.2: Try to create contract with end date before start date (should fail)
SELECT 'Test 7.2: Try to create contract with end date before start date (should fail)' AS '';
-- This should fail
CALL add_contract('Pfizer', '123 Main St, City', 'Invalid date contract', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), CURDATE(), 'Test Supervisor');

-- Test 7.3: Update contract
SELECT 'Test 7.3: Update contract' AS '';
CALL update_contract('Merck', '321 Elm Blvd, County', 'Updated test contract', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 YEAR), 'Updated Supervisor');

-- Test 7.4: Update contract supervisor only
SELECT 'Test 7.4: Update contract supervisor only' AS '';
CALL update_contract_supervisor('Merck', '321 Elm Blvd, County', 'New Supervisor');

-- Test 7.5: Delete contract
SELECT 'Test 7.5: Delete contract' AS '';
CALL delete_contract('Merck', '321 Elm Blvd, County');

-- Test Group 8: Treats Relationship Tests
SELECT '========== TREATS RELATIONSHIP TESTS ==========' AS '';

-- Test 8.1: Create another doctor and patient for relationship tests
SELECT 'Test 8.1: Create another doctor and patient for relationship tests' AS '';
CALL add_doctor('DOC201', 'Dr. Relationship Test', 'Psychiatry', 10);
CALL add_patient('PAT201', 'Relationship Test Patient', 45, '201 Test Dr', 'DOC201', NULL);
CALL add_patient('PAT202', 'Second Relationship Patient', 35, '202 Test Cir', 'DOC201', NULL);

-- Test 8.2: Add treats relationship
SELECT 'Test 8.2: Add treats relationship' AS '';
CALL add_treats_entry('DOC102', 'PAT201');

-- Test 8.3: Try to add duplicate relationship (should fail)
SELECT 'Test 8.3: Try to add duplicate relationship (should fail)' AS '';
-- This should fail
CALL add_treats_entry('DOC102', 'PAT201');

-- Test 8.4: Delete treats relationship
SELECT 'Test 8.4: Delete treats relationship' AS '';
CALL delete_treats_entry('DOC102', 'PAT201');

-- Test 8.5: Try to delete primary physician relationship (should fail)
SELECT 'Test 8.5: Try to delete primary physician relationship (should fail)' AS '';
-- This should fail
CALL delete_treats_entry('DOC201', 'PAT201');

-- Test 8.6: Try to delete last patient relationship from doctor (should fail)
SELECT 'Test 8.6: Try to delete last patient relationship from doctor (should fail)' AS '';
-- Set up to have only one relationship
CALL delete_patient('PAT202');
-- This should fail because every doctor must have at least one patient
CALL delete_treats_entry('DOC201', 'PAT201');

-- Test Group 9: Report/Query Tests
SELECT '========== REPORT/QUERY TESTS ==========' AS '';

-- Test 9.1: Drug details report
SELECT 'Test 9.1: Drug details report' AS '';
CALL drug_details('Johnson & Johnson Inc.');

-- Test 9.2: Pharmacy stock position
SELECT 'Test 9.2: Pharmacy stock position' AS '';
CALL print_stock_position('123 Main St, City');

-- Test 9.3: Pharmacy contact details
SELECT 'Test 9.3: Pharmacy contact details' AS '';
CALL print_pharmacy_contact('456 Oak Ave, Town');

-- Test 9.4: Company contact details
SELECT 'Test 9.4: Company contact details' AS '';
CALL print_company_contact('Pfizer');

-- Test 9.5: Doctor's patients report
SELECT 'Test 9.5: Doctor\'s patients report' AS '';
CALL print_patients_for_doctor('DOC001');

-- Test 9.6: Patient prescription report
SELECT 'Test 9.6: Patient prescription report' AS '';
-- Using date range that includes our test data
CALL prescription_report('PAT007', DATE_SUB(CURDATE(), INTERVAL 30 DAY), CURDATE());

-- Clean up final test data
DROP PROCEDURE IF EXISTS cleanup_test_data;
DELIMITER $$
CREATE PROCEDURE cleanup_test_data()
BEGIN
    -- Clean up remaining test patients and doctors
    DELETE FROM Patient WHERE paadharid IN ('PAT101', 'PAT201');
    DELETE FROM Doctor WHERE daadharid IN ('DOC102', 'DOC201');
END$$
DELIMITER ;

CALL cleanup_test_data();
DROP PROCEDURE cleanup_test_data;

SELECT 'Test suite execution completed.' AS '';