USE PortfolioProject

--Looking at Total cases vs Total deaths
--Showing the likelihood of dying if you contract covid in your country
DECLARE @location VARCHAR(255)
SET @location = 'United States'
SELECT continent, location, date, total_deaths, total_cases, ROUND((total_deaths/total_cases)*100, 0) AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE location = @location AND CONTINENT IS NOT NULL
ORDER BY 2,3

--Looking at Total cases VS Population
--Shows what percentage of the population got covid
--Showing the likelihood of you contracting covid in your country
DECLARE @location VARCHAR(255)
SET @location = 'United States'
SELECT continent, location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths
WHERE location = @location AND continent IS NOT NULL
ORDER BY 2,3

--Looking at countries with highest infection rates compared to population
SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY 5 DESC

--Showing countries with highest deaths per population
SELECT continent, location, population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDeaths
FROM PortfolioProject..coviddeaths
WHERE CONTINENT IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentPopulationDeaths DESC

--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

--USE CTE
WITH PopVSVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths AS dea
INNER JOIN PortfolioProject..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationVSPopulation
FROM PopVSVac

--TEMP TABLE
CREATE TABLE #PercentagePopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths AS dea
INNER JOIN PortfolioProject..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationVSPopulation
FROM #PercentagePopulationVaccinated

--Creating view to store data for later visualization
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths AS dea
INNER JOIN PortfolioProject..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

CREATE VIEW TotalDeathsVSTotalCases AS
SELECT continent, location, date, total_deaths, total_cases, ROUND((total_deaths/total_cases)*100, 0) AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE location = 'United States' AND CONTINENT IS NOT NULL
--ORDER BY 2,3

CREATE VIEW PercentagePeopleInfected AS
SELECT continent, location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS PercentPopulationInfected
FROM PortfolioProject..coviddeaths
WHERE location = 'United States' AND continent IS NOT NULL
--ORDER BY 2,3

CREATE VIEW HighestDeathCount AS
SELECT continent, location, population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDeaths
FROM PortfolioProject..coviddeaths
WHERE CONTINENT IS NOT NULL
GROUP BY continent, location, population
--ORDER BY PercentPopulationDeaths DESC

CREATE VIEW TotalDeathCount AS
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC

CREATE VIEW GlobalNumber AS
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY date

CREATE VIEW RollingPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths AS dea
INNER JOIN PortfolioProject..covidvaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

