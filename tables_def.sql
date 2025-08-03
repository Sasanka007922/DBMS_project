CREATE SCHEMA IF NOT EXISTS nova;
USE nova;

-- Doctor table with primary key daadharid
CREATE TABLE Doctor (
    daadharid VARCHAR(12) PRIMARY KEY,
    d_name VARCHAR(100) NOT NULL,
    speciality VARCHAR(100),
    years_of_experience INT NOT NULL CHECK (years_of_experience >= 0)
);

-- Patient table with primary key paadharid and reference to primary physician
CREATE TABLE Patient (
    paadharid VARCHAR(12) PRIMARY KEY,
    p_name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age >= 0),
    address VARCHAR(100) NOT NULL,
    p_daadharid VARCHAR(12) NOT NULL,
    FOREIGN KEY (p_daadharid) REFERENCES Doctor(daadharid)
);

-- Treats relationship table between Doctor and Patient
CREATE TABLE Treats (
    pid VARCHAR(12) NOT NULL,
    did VARCHAR(12) NOT NULL,
    PRIMARY KEY (pid, did),
    FOREIGN KEY (pid) REFERENCES Patient(paadharid) ON DELETE CASCADE,
    FOREIGN KEY (did) REFERENCES Doctor(daadharid) ON DELETE CASCADE
);

-- Pharmaceutical Company table
CREATE TABLE PharmaceuticalCompany (
    company_name VARCHAR(100) PRIMARY KEY,
    phone_number VARCHAR(15) NOT NULL
);

-- Drug table with composite unique constraint
CREATE TABLE Drug (
    drug_id INT AUTO_INCREMENT PRIMARY KEY,
    trade_name VARCHAR(100) NOT NULL,
    formula VARCHAR(200) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    UNIQUE (trade_name, company_name),
    FOREIGN KEY (company_name) REFERENCES PharmaceuticalCompany(company_name) ON DELETE CASCADE
);

-- Pharmacy table
CREATE TABLE Pharmacy (
    address VARCHAR(200) PRIMARY KEY,
    pname VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- Sells relationship table between Pharmacy and Drug
CREATE TABLE Sells (
    ph_address VARCHAR(200) NOT NULL,
    drug_id INT NOT NULL,
    PRIMARY KEY (drug_id, ph_address),
    stock INT NOT NULL CHECK (stock >= 0) DEFAULT 0,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (ph_address) REFERENCES Pharmacy(address) ON DELETE CASCADE,
    FOREIGN KEY (drug_id) REFERENCES Drug(drug_id) ON DELETE CASCADE
);

-- Prescription table with composite unique constraint
CREATE TABLE Prescription (
    pres_id INT AUTO_INCREMENT PRIMARY KEY,
    pid VARCHAR(12) NOT NULL,
    did VARCHAR(12) NOT NULL,
    pres_date DATE NOT NULL,
    FOREIGN KEY (pid) REFERENCES Patient(paadharid) ON DELETE CASCADE,
    FOREIGN KEY (did) REFERENCES Doctor(daadharid) ON DELETE CASCADE,
    UNIQUE (pid, did)
);

-- Contains_drug table to represent drugs in a prescription
CREATE TABLE Contains_drug (
    pres_id INT NOT NULL,
    drug_id INT NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    PRIMARY KEY (pres_id, drug_id),
    FOREIGN KEY (pres_id) REFERENCES Prescription(pres_id) ON DELETE CASCADE,
    FOREIGN KEY (drug_id) REFERENCES Drug(drug_id) ON DELETE CASCADE
);

-- Contract table between Pharmaceutical Company and Pharmacy
CREATE TABLE Contract (
    company_name VARCHAR(100) NOT NULL,
    ph_address VARCHAR(200) NOT NULL,
    PRIMARY KEY (company_name, ph_address),
    content TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    supervisor VARCHAR(100) NOT NULL,
    FOREIGN KEY (company_name) REFERENCES PharmaceuticalCompany(company_name) ON DELETE CASCADE,
    FOREIGN KEY (ph_address) REFERENCES Pharmacy(address) ON DELETE CASCADE,
    CHECK (start_date <= end_date)
);
