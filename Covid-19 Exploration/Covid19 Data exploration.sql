/* 
 Covid-19 Data Exploration
*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths;


-- Total cases vs Total Deaths over the countries
-- Displays countries with Highest Death percentage to lowest
SELECT 
	location AS Country, 
	MAX(total_cases) AS Cases, 
    MAX(total_deaths) AS Deaths, 
    MAX(total_deaths)/MAX(total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent <> '' 
	AND total_cases >= 1000
GROUP BY location
ORDER BY DeathPercentage DESC;


-- Total Cases vs Population of the country
SELECT 
	location AS Country,
	population AS Population,
    MAX(total_cases) AS Cases,
    MAX(total_cases)/population*100 AS DiagnosedPercentage
FROM coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY DiagnosedPercentage DESC;


-- Cases count over the countries
SELECT
	location AS Country,
    MAX(total_cases) AS Cases
FROM coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY Cases DESC;


-- Deaths over the countries
SELECT
	location AS Country,
    MAX(total_deaths) AS Deaths
FROM coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY Deaths DESC;


-- Cases over the continents
SELECT
	continent AS Continent,
    SUM(new_cases) AS Cases
FROM coviddeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY Cases DESC;


-- Deaths over the continents
SELECT
	continent AS Continent,
    SUM(new_deaths) AS Deaths
FROM coviddeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY Deaths DESC;


-- Vaccination over the countries
SELECT 
	location as Country,
	population AS Population,
    MAX(people_vaccinated) AS Vaccination
FROM covidvaccination
WHERE continent <> ''
GROUP BY location
ORDER BY Vaccination DESC;


-- Vaccination in India Day by day
SELECT
	date AS Date,
    new_vaccinations AS New_Vaccination,
    SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date)
		AS Total_Vaccinations
FROM covidvaccination
WHERE location = 'India' 
	AND total_vaccinations > 0
ORDER BY date;


-- New Tests vs New Cases
-- Data shows how much percentage of people tested positive out of all people tested day by day.
SELECT
	d.date AS Date,
    SUM(v.new_tests) AS New_Tests,
    SUM(d.new_cases) AS New_Cases,
    SUM(d.new_cases)/SUM(v.new_tests)*100 AS Positive_Rate
FROM coviddeaths AS d
	JOIN covidvaccination AS v
		ON d.location = v.location 
			AND d.date = v.date
WHERE d.continent <> '' 
	AND d.date >= '2020-03-01'
GROUP BY d.date
ORDER BY Positive_Rate DESC;


-- New Tests vs New Cases In India
-- Data shows how much percentage of people tested positive out of all people tested day by day.
SELECT 
	d.date AS Date,
    v.new_tests AS New_Tests,
    d.new_cases AS New_Cases,
    d.new_cases/v.new_tests*100 AS Positive_Rate
FROM coviddeaths AS d
	JOIN covidvaccination AS v
		ON d.location = v.location 
			AND d.date = v.date
WHERE d.location = 'India'
	AND New_Tests > 0;


-- Percentage of people dead over the population of the country (CTE)
WITH deathratetable(Country, Deaths, Population)
AS (	
	SELECT
		location AS Country,
		MAX(total_deaths) AS Deaths,
		population AS Population
	FROM coviddeaths
	WHERE continent <> ''
    GROUP BY location
)
	SELECT *, Deaths/Population*100 AS DeathPercentage
    FROM deathratetable
    ORDER BY DeathPercentage DESC;

