/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- This SQL query selects all columns from the CovidDeaths table where the continent column is not NULL.
-- The results are ordered by the third and fourth columns.
SELECT 
	*
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL 
ORDER BY 
	3,4


-- This SQL query selects specific columns (Location, date, total_cases, new_cases, total_deaths, and population) from the CovidDeaths table where the continent column is not NULL.
-- The results are ordered by the Location column (1st column) and then by the date column (2nd column).
SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL 
ORDER BY 
	1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
-- This SQL query selects the Location, date, total_cases, total_deaths columns from the CovidDeaths table for records where the location is 'Canada' and the continent column is not NULL.
-- It also calculates the DeathPercentage as the percentage of total deaths out of total cases.
-- The results are ordered by the Location column (1st column) and then by the date column (2nd column).
SELECT 
	Location, 
	date, 
	total_cases,
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM 
	CovidDeaths
WHERE 
	location LIKE 'Canada'
			AND continent IS NOT NULL
ORDER BY 
	1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
-- This SQL query selects the Location, date, Population, and total_cases columns from the CovidDeaths table.
-- It calculates the PercentPopulationInfected as the percentage of total cases relative to the population.
-- The results are ordered by the Location column (1st column) and then by the date column (2nd column).
-- The WHERE clause has been commented out, so the query retrieves data for all locations.
SELECT 
	Location, 
	date, 
	Population, 
	total_cases,  
	(total_cases/population)*100 AS PercentPopulationInfected
FROM 
	CovidDeaths
--WHERE location LIKE 'Canada'
ORDER BY 
	1,2


-- Countries with Highest Infection Rate compared to Population
-- This SQL query selects the Location, Population, Maximum total_cases (as HighestInfectionCount), and the corresponding percentage of population infected (as PercentPopulationInfected) from the CovidDeaths table.
-- It calculates the PercentPopulationInfected as the maximum total_cases relative to the population, expressed as a percentage.
-- The results are grouped by Location and Population.
-- The WHERE clause has been commented out, so the query calculates the maximum infection count and percentage of population infected for all locations.
-- The results are ordered by the PercentPopulationInfected column in descending order.
SELECT 
	Location, 
	Population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM 
	CovidDeaths
--WHERE location LIKE 'Canada'
GROUP BY 
	Location, 
	Population
ORDER BY 
	PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
-- This SQL query selects the Location, population, maximum Total_deaths as TotalDeathCount, and the corresponding percentage of population dead (as PercentPopulationDead) from the CovidDeaths table.
-- It calculates the PercentPopulationDead as the maximum total_deaths relative to the population, expressed as a percentage.
-- The data is filtered to include records where the continent column is not NULL.
-- The results are grouped by Location and population.
-- The results are ordered by the PercentPopulationDead column in descending order.
SELECT 
	Location, 
	population,
	MAX(Total_deaths) AS TotalDeathCount,
	MAX((total_deaths/population))*100 AS PercentPopulationDead
FROM 
	CovidDeaths
--WHERE location LIKE 'Canada'
WHERE 
	continent IS NOT NULL
GROUP BY 
	Location,
	population
ORDER BY 
	PercentPopulationDead DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
-- This SQL query selects the continent and the maximum Total_deaths as TotalDeathCount from the CovidDeaths table.
-- It filters the data to include records where the continent column is not NULL.
-- The results are grouped by continent.
-- The WHERE clause has been commented out, so the query calculates the maximum total death count for all continents.
-- The results are ordered by the TotalDeathCount column in descending order.
SELECT 
	continent, 
	MAX(Total_deaths) AS TotalDeathCount
FROM 
	CovidDeaths
--WHERE location LIKE 'Canada'
WHERE 
	continent IS NOT NULL 
GROUP BY 
	continent
ORDER BY
	TotalDeathCount DESC



-- GLOBAL NUMBERS
-- This SQL query calculates the total cases, total deaths, and death percentage from the CovidDeaths table.
-- It sums up the new_cases and new_deaths columns to get the total cases and total deaths, respectively.
-- It calculates the DeathPercentage as the percentage of total deaths out of total cases.
-- The data is filtered to include records where the continent column is not NULL.
-- The results are ordered by the first column (total_cases) and then by the second column (total_deaths).
SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths)/SUM(new_Cases)*100 AS DeathPercentage
FROM 
	CovidDeaths
--WHERE location LIKE 'Canada'
WHERE 
	continent IS NOT NULL 
--GROUP BY date
ORDER BY 
	1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- This SQL query selects columns from the CovidDeaths and CovidVaccinations tables, combining data on deaths and vaccinations.
-- It calculates the RollingPeopleVaccinated as the cumulative sum of new_vaccinations over a partition defined by the location, ordered by location and date.
-- The WHERE clause filters records where the continent is not NULL.
-- The results are ordered by location and date.
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations)
	OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea
JOIN 
	CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND 
	dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL 
ORDER BY 
	2,3


-- Using CTE to perform Calculation on Partition By in previous query
-- This SQL query defines a Common Table Expression (CTE) named PopvsVac, which combines data from the CovidDeaths and CovidVaccinations tables.
-- It calculates the RollingPeopleVaccinated as the cumulative sum of new_vaccinations over a partition defined by the location, ordered by location and date.
-- The WHERE clause filters records where the continent is not NULL.
-- The main query selects all columns from the PopvsVac CTE and adds a new column, calculating the percentage of RollingPeopleVaccinated relative to the population.
WITH 
	PopvsVac 
	(
	Continent, 
	Location, 
	Date, 
	Population, 
	New_Vaccinations, 
	RollingPeopleVaccinated
	)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea
JOIN CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND 
	dea.date = vac.date
WHERE 
dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM 
	PopvsVac

	
-- Using Temp Table to perform Calculation on Partition By in previous query
-- This SQL script drops the temporary table #PercentPopulationVaccinated if it exists, and then creates a new temporary table with the specified columns:
DROP TABLE IF 
	exists #PercentPopulationVaccinated
CREATE TABLE 
	#PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

-- This SQL script inserts data into the temporary table #PercentPopulationVaccinated by selecting columns from the CovidDeaths and CovidVaccinations tables.
-- It calculates the RollingPeopleVaccinated as the cumulative sum of new_vaccinations over a partition defined by the location, ordered by location and date.
-- The WHERE clause, which filters records where the continent is not NULL, has been commented out.
-- The main query then selects all columns from the temporary table and adds a new column, calculating the percentage of RollingPeopleVaccinated relative to the population.
INSERT INTO 
	#PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations)
	OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea
JOIN 
	CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND 
	dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM 
#PercentPopulationVaccinated




-- Creating View to store data for later visualizations
-- This SQL script creates a view named PercentPopulationVaccinated.
-- The view selects columns from the CovidDeaths and CovidVaccinations tables, combining data on deaths and vaccinations.
-- It calculates the RollingPeopleVaccinated as the cumulative sum of new_vaccinations over a partition defined by the location, ordered by location and date.
-- The WHERE clause filters records where the continent is not NULL.
CREATE VIEW 
	PercentPopulationVaccinated 
AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) 
	OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM 
	CovidDeaths dea
	JOIN 
	CovidVaccinations vac
	ON 
	dea.location = vac.location
	AND 
	dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL 