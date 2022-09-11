SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/CAST(total_cases AS numeric)) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths 
ORDER BY 1,2


-- looking at the Total cases vs Population
-- Shows what percentage of populaton got covid

SELECT location, date, population, total_cases, (total_cases/CAST(population AS numeric)) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to popuation

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/CAST(population AS numeric))) * 100 AS MaxInfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location IS NOT NULL
GROUP BY location, population
ORDER BY MaxInfectionRate DESC


-- Showing the countries with highest death count per population

SELECT location, population, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC


-- LETS BREAK THINGS BY CONTINENT 
-- Showing continents with highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
-- Total cases and total deaths overall

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(CAST(new_cases AS numeric))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


-- Total cases and total deaths grouped by date 

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(CAST(new_cases AS numeric))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- JOINING TWO TABLES THAT WE ARE GOING TO WORK ON 

SELECT *
FROM PortfolioProject..CovidDeaths AS  Dea 
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date


-- Looking at Total Population vs Total Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS Dea
INNER JOIN PortfolioProject..CovidVaccinations AS Vac
  ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3


-- Adding day by day vaccination numbers 

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       SUM(CAST(Vac.new_vaccinations AS numeric)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS Dea
INNER JOIN PortfolioProject..CovidVaccinations AS Vac
  ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL AND Dea.location LIKE 'India'
ORDER BY 2,3


-- Creating a CTE table for use  

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       SUM(CAST(Vac.new_vaccinations AS numeric)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS Dea
INNER JOIN PortfolioProject..CovidVaccinations AS Vac
  ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL 
)

SELECT *, (CAST(RollingPeopleVaccinated AS numeric)/population)*100 AS RollingVaccinationPercentage
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date date,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       SUM(CONVERT(numeric, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS Dea
INNER JOIN PortfolioProject..CovidVaccinations AS Vac
  ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingVaccinationPercentage
FROM PercentPopulationVaccinated



-- Creating view to store date later for visualization

CREATE VIEW PopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
       SUM(cast(Vac.new_vaccinations AS numeric)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS Dea
INNER JOIN PortfolioProject..CovidVaccinations AS Vac
  ON Dea.location = Vac.location 
  AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL



-- retreving the data from created view 

SELECT * 
FROM PopulationVaccinated
