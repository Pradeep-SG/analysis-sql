
SET GLOBAL local_infile=1;
SET SQL_SAFE_UPDATES = 0;

-- Bulk Insert

LOAD DATA LOCAL INFILE 'C:\\Users\\prade\\Documents\\Data Analysis\\Portfolio\\HousingData.csv' 
INTO TABLE housingdata
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM housingdata;

------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Date is weirdly formatted -> January 1, 2001
Making Date format as a SQL standard -> 2001-01-01
*/

-- Checking if it is correct

SELECT STR_TO_DATE(saledate, '%M %e, %Y')
FROM housingdata;                                   

-- Updating

UPDATE housingdata
SET saledate = STR_TO_DATE(saledate, '%M %e, %Y');  


------------------------------------------------------------------------------------------------------------------------------------------------------


/*
ParcelID in with decimal places
*/
UPDATE housingdata
SET parcelid = SUBSTRING_INDEX(parcelid, '.', 1);


------------------------------------------------------------------------------------------------------------------------------------------------------



/*
Formatting null values
*/
ALTER TABLE housingdata
ADD COLUMN property_address_wnull VARCHAR(255);

WITH nullcte(propertyaddress) AS
(
	SELECT IFNULL(h1.propertyaddress,h2.propertyaddress)
	FROM housingdata AS h1
		INNER JOIN housingdata AS h2
			ON h1.parcelid = h2.parcelid AND h1.uniqueid <> h2.uniqueid
)
UPDATE housingdata AS dest,
(
	SELECT *
    FROM nullcte
) AS src
SET dest.property_address_wnull = src.propertyaddress;

ALTER TABLE housingdata
DROP COLUMN propertyaddress;

ALTER TABLE housingdata
CHANGE property_address_wnull propertyaddress VARCHAR(255);


------------------------------------------------------------------------------------------------------------------------------------------------------



/* 
Breaking out property address and owner address to city and state
*/

-- Checking if it is working properly

SELECT
	SUBSTRING_INDEX(propertyaddress, ',', 1),
    SUBSTRING_INDEX(propertyaddress, ', ', -1)		
FROM housingdata;

-- Adding columns

ALTER TABLE housingdata													
ADD COLUMN property_c VARCHAR(255) AFTER propertyaddress;
-- ADD COLUMN property_address_new VARCHAR(255) AFTER propertyaddress,
-- ADD COLUMN owner_state VARCHAR(255) AFTER owneraddress,
-- ADD COLUMN owner_city VARCHAR(255) AFTER owneraddress,
-- ADD COLUMN owner_address_new VARCHAR(255) AFTER owneraddress;

-- Updating the columns

UPDATE housingdata														
SET property_address_new = SUBSTRING_INDEX(propertyaddress, ',', 1),
	property_city = SUBSTRING_INDEX(propertyaddress, ', ', -1),
    owner_address_new = SUBSTRING_INDEX(owneraddress, ',', 1),
    owner_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',',2), ', ', -1),
    owner_state  = SUBSTRING_INDEX(owneraddress, ', ', -1);


------------------------------------------------------------------------------------------------------------------------------------------------------



/*
SoldAsVacant column is not properly formatted for analysing
values are -> Yes, No, Y, N
*/

 -- Checking soldasvacant column by grouping
 
 SELECT soldasvacant, COUNT(soldasvacant)
 FROM housingdata
 GROUP BY soldasvacant;
 
 -- Updating (Y to Yes) & (N to No)
 
UPDATE housingdata
SET soldasvacant = 
(
	CASE
		WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
	END
);



------------------------------------------------------------------------------------------------------------------------------------------------------



/*
Removing Duplicates
*/
WITH rowcte AS 
(
	SELECT uniqueid, parcelid, propertyaddress, ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saledate, saleprice, legalreference, ownername, owneraddress ORDER BY parcelid) AS rownum
	FROM housingdata
)
DELETE FROM housingdata USING housingdata INNER JOIN rowcte ON housingdata.uniqueid = rowcte.uniqueid
WHERE rownum > 1;

ALTER TABLE housingdata
DROP COLUMN rownum;



------------------------------------------------------------------------------------------------------------------------------------------------------



/*
Deleting unwanted columns
*/
ALTER TABLE housingdata
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress;
