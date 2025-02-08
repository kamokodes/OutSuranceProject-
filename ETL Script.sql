--  Create temporary tables for importing SourceLists
CREATE TABLE SecureInvestCustomers (
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    CountryOfBirth VARCHAR(50),
    DateOfBirth VARCHAR(10),
    CustomerID CHAR(6),
    SourceSystem VARCHAR(50),
    PolicyType VARCHAR(50),
    PolicyCode CHAR(7),
    PolicyActivationDate VARCHAR(10)
);

CREATE TABLE RetInvestCustomers (
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    CountryOfBirth VARCHAR(50),
    DateOfBirth VARCHAR(10),
    CustomerID CHAR(6),
    SourceSystem VARCHAR(50),
    PolicyType VARCHAR(50),
    PolicyCode CHAR(7),
    PolicyActivationDate VARCHAR(10)
);

CREATE TABLE LifeInvestCustomers (
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    CountryOfBirth VARCHAR(50),
    DateOfBirth VARCHAR(10),
    CustomerID CHAR(6),
    SourceSystem VARCHAR(50),
    PolicyType VARCHAR(50),
    PolicyCode CHAR(7),
    PolicyActivationDate VARCHAR(10)
);

-- Step 2: Import SourceLists data into MySQL
LOAD DATA INFILE 'C:/SecureInvest.csv'
INTO TABLE SecureInvestCustomers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/RetInvest.csv'
INTO TABLE RetInvestCustomers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/LifeInvest.csv'
INTO TABLE LifeInvestCustomers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Convert DateOfBirth and PolicyActivationDate to DATE format
-- Convert dates for SecureInvest_Customers
ALTER TABLE SecureInvestCustomers
ADD COLUMN ConvertedDateOfBirth DATE,
ADD COLUMN ConvertedPolicyActivationDate DATE;

UPDATE SecureInvestCustomers
SET 
    ConvertedDateOfBirth = STR_TO_DATE(DateOfBirth, '%d %m %Y'),
    ConvertedPolicyActivationDate = STR_TO_DATE(PolicyActivationDate, '%d %m %Y');

-- Convert dates for RetInvest_Customers
ALTER TABLE RetInvestCustomers
ADD COLUMN ConvertedDateOfBirth DATE,
ADD COLUMN ConvertedPolicyActivationDate DATE;

UPDATE RetInvestCustomers
SET 
    ConvertedDateOfBirth = STR_TO_DATE(DateOfBirth, '%d %m %Y'),
    ConvertedPolicyActivationDate = STR_TO_DATE(PolicyActivationDate, '%d %m %Y');

-- Convert dates for LifeInvest_Customers
ALTER TABLE LifeInvestCustomers
ADD COLUMN ConvertedDateOfBirth DATE,
ADD COLUMN ConvertedPolicyActivationDate DATE;

UPDATE LifeInvestCustomers
SET 
    ConvertedDateOfBirth = STR_TO_DATE(DateOfBirth, '%d %m %Y'),
    ConvertedPolicyActivationDate = STR_TO_DATE(PolicyActivationDate, '%d %m %Y');

-- Drop old VARCHAR date columns
ALTER TABLE SecureInvestCustomers
DROP COLUMN DateOfBirth,
DROP COLUMN PolicyActivationDate;

ALTER TABLE RetInvestCustomers
DROP COLUMN DateOfBirth,
DROP COLUMN PolicyActivationDate;

ALTER TABLE LifeInvestCustomers
DROP COLUMN DateOfBirth,
DROP COLUMN PolicyActivationDate;

-- Rename converted columns
ALTER TABLE SecureInvestCustomers
CHANGE COLUMN ConvertedDateOfBirth DateOfBirth DATE,
CHANGE COLUMN ConvertedPolicyActivationDate PolicyActivationDate DATE;

ALTER TABLE RetInvestCustomers
CHANGE COLUMN ConvertedDateOfBirth DateOfBirth DATE,
CHANGE COLUMN ConvertedPolicyActivationDate PolicyActivationDate DATE;

ALTER TABLE LifeInvestCustomers
CHANGE COLUMN ConvertedDateOfBirth DateOfBirth DATE,
CHANGE COLUMN ConvertedPolicyActivationDate PolicyActivationDate DATE;

-- Step 4: Create Unified_Customers table with PolicyCode as the primary key
CREATE TABLE UnifiedCustomers (
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    CountryOfBirth VARCHAR(50),
    DateOfBirth DATE,
    CustomerID CHAR(6),
    SourceSystem VARCHAR(50),
    PolicyType VARCHAR(50),
    PolicyCode CHAR(7) PRIMARY KEY,
    PolicyActivationDate DATE,
    MasterRecord BOOLEAN
);

-- Step 5: Insert data from LifeInvest with MasterRecord set to TRUE
INSERT INTO UnifiedCustomers (
    FirstName, LastName, CountryOfBirth, DateOfBirth, CustomerID, SourceSystem, PolicyType, PolicyCode, PolicyActivationDate, MasterRecord
)
SELECT 
    FirstName, 
    LastName,
    CountryOfBirth, 
    DateOfBirth, 
    CustomerID,
    'LifeInvest' AS SourceSystem, 
    PolicyType, 
    PolicyCode,
    PolicyActivationDate, 
    TRUE AS MasterRecord
FROM LifeInvestCustomers;

-- Insert RetInvest data
INSERT INTO UnifiedCustomers (
    FirstName, LastName, CountryOfBirth, DateOfBirth, CustomerID, SourceSystem, PolicyType, PolicyCode, PolicyActivationDate, MasterRecord
)
SELECT 
    FirstName, 
    LastName,
    CountryOfBirth, 
    DateOfBirth, 
    CustomerID,
    SourceSystem, 
    PolicyType, 
    PolicyCode,
    PolicyActivationDate, 
    FALSE AS MasterRecord
FROM RetInvestCustomers ;

-- Insert SecureInvest data
INSERT INTO UnifiedCustomers (
    FirstName, LastName, CountryOfBirth, DateOfBirth, CustomerID, SourceSystem, PolicyType, PolicyCode, PolicyActivationDate, MasterRecord
)
SELECT 
    FirstName, 
    LastName,
    CountryOfBirth, 
    DateOfBirth, 
    CustomerID,
    SourceSystem, 
    PolicyType, 
    PolicyCode,
    PolicyActivationDate, 
    FALSE AS MasterRecord
FROM SecureInvestCustomers;


-- Ensure all LifeInvest records are marked as master
UPDATE UnifiedCustomers
SET MasterRecord = TRUE
WHERE SourceSystem = 'LifeInvest';

-- Sort data by PolicyActivationDate asc to find latest entry and set its MasterRecord to true 
UPDATE UnifiedCustomers
SET MasterRecord = TRUE
WHERE PolicyCode = '5548' ;

UPDATE UnifiedCustomers
SET MasterRecord = TRUE
WHERE PolicyCode = 'I-6414' ;

-- Query to show all customers and create report 1  

Select * from UnifiedCustomers;



-- Create Table to store SanctionedList
Create Table SanctionedList ( 
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
    CountryOfBirth VARCHAR(50),
	DateOfBirth VARCHAR(10),
    PassportNumber VARCHAR(7)
    ); 
    
LOAD DATA INFILE 'C:/SanctionedList.csv'
INTO TABLE SanctionedList
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Step 1: Add a new DATE column
ALTER TABLE SanctionedList
ADD COLUMN DateOfBirthConverted DATE;

-- Step 2: Convert and populate the new column
UPDATE SanctionedList
SET DateOfBirthConverted = STR_TO_DATE(DateOfBirth, '%d %m %Y'); -- Adjust format if needed

-- Step 4: Drop old column and rename the new column
ALTER TABLE SanctionedList
DROP COLUMN DateOfBirth;

ALTER TABLE SanctionedList
CHANGE COLUMN DateOfBirthConverted DateOfBirth DATE;


-- Create a table to store matches
CREATE TABLE SanctionedCustomers (
    CustomerID CHAR(6),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    CountryOfBirth VARCHAR(50),
    SourceSystem VARCHAR(50),
    MasterRecord VARCHAR(1),
    MatchCount INT
);

-- Insert matches into the table
INSERT INTO SanctionedCustomers (CustomerID, FirstName, LastName, CountryOfBirth, SourceSystem, MasterRecord, MatchCount)
SELECT 
    uc.CustomerID,
    uc.FirstName,
    uc.LastName,
    uc.CountryOfBirth,
    uc.SourceSystem,
    'Y' AS MasterRecord,
    COALESCE(COUNT(sl.PassportNumber), 0) AS MatchCount
FROM 
    UnifiedCustomers uc
LEFT JOIN 
    SanctionedList sl
ON 
    uc.FirstName = sl.FirstName
    AND uc.LastName = sl.LastName
    AND uc.CountryOfBirth = sl.CountryOfBirth
GROUP BY 
    uc.CustomerID,
    uc.FirstName,
    uc.LastName,
    uc.CountryOfBirth,
    uc.SourceSystem;

-- Use Select to create report 2  
SELECT 
    CustomerID AS 'Customer ID',
    FirstName AS 'First Name',
    LastName AS 'Last Name',
    CountryOfBirth AS 'Country of Origin',
    SourceSystem AS 'Source System Name',
    MasterRecord AS 'Master Record',
    MatchCount AS 'Number of Source System Matches'
FROM 
    SanctionedCustomers
Where 
    MatchCount > 0 
Order by 
	MatchCount desc;

-- Query to ONLY show top 10% using procedure

DELIMITER //

CREATE PROCEDURE GetTopTenPercent()
BEGIN
    DECLARE total_count INT;
    DECLARE top_ten_percent INT;

    -- Calculate the total number of rows
    SELECT COUNT(*) INTO total_count FROM SanctionedCustomers;

    -- Calculate 10% of the total number of rows
    SET top_ten_percent = CEIL(total_count * 0.1);

    -- Retrieve the top 10% rows based on MatchCount
    SELECT *
    FROM SanctionedCustomers
    ORDER BY MatchCount DESC
    LIMIT top_ten_percent;
END //

DELIMITER ;

-- Call Procedure to create report 3
CALL GetTopTenPercent();










