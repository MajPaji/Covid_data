SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows liklihood of dying if you contract covid19 in your country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location like '%sweden%'
ORDER BY 1,2

-- Looking at the total cases vs population
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100 , 3) as CasePercentage
FROM PortfolioProject..CovidDeath
WHERE location like '%states%'
ORDER BY 1,2


-- which country has the highest infection rate to population
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX(ROUND((total_cases/population)*100 , 3)) as infection
FROM PortfolioProject..CovidDeath
GROUP BY location, population
ORDER BY infection DESC


-- Showing Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Showing Continet with highest death count

SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC

SELECT location, MAX(CAST(total_deaths as int))
FROM PortfolioProject..CovidDeath
WHERE location like '%world%'
GROUP BY location

-- Global numbers

SELECT location, date, MAX(total_cases) AS Global_total_case, MAX(cast(total_deaths as int)) AS Global_total_death
FROM PortfolioProject..CovidDeath
WHERE continent is null and location like '%world%'
GROUP BY date, location

SELECT SUM(new_cases) as new_c , SUM(cast(new_deaths as int)) as new_d, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM PortfolioProject..CovidDeath
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccination
-- CTE (common table expresion)
With VacvsPop (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as VacvsPop_per
FROM VacvsPop
ORDER BY 1, 2, 3


-- Use temp table
DROP TABLE IF EXISTS #VaccineVSPeopleTable
CREATE TABLE #VaccineVSPeopleTable
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #VaccineVSPeopleTable
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)/100 as Vaccination_per
FROM #VaccineVSPeopleTable
ORDER BY 1, 2, 3

-- Creating view to store data for later visualization

CREATE VIEW VaccineVSPeopleTable as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM VaccineVSPeopleTable