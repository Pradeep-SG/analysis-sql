/*
	Covid-19 Data import and cleaning
*/
-- Created two table as 'coviddeaths' and 'covidvaccination'

LOAD DATA LOCAL INFILE 'C:\\Users\\prade\\Documents\\Data Analysis\\Portfolio\\CovidDeaths.csv' 
INTO TABLE coviddeaths
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:\\Users\\prade\\Documents\\Data Analysis\\Portfolio\\CovidVaccination.csv' 
INTO TABLE covidvaccination
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE coviddeaths
SET date = STR_TO_DATE(date, '%d-%m-%Y');

UPDATE covidvaccination
SET date = STR_TO_DATE(date, '%d-%m-%Y');