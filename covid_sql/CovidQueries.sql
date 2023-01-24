
--Exploration of COVID Data using SQL

-- Select data to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total cases vs total deaths
-- Likelihood of death if contract COVID in UK

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 2

-- Total cases vs Population
-- Percentage of population that had COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 2

-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as TotalInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with highest death rate

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

-- Deaths by continent

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income' AND location NOT IN ('European Union','World','International')
GROUP BY location
ORDER BY 2 DESC

-- Deaths by income group

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location LIKE '%income'
GROUP BY location
ORDER BY 2 DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths AS int)) as GlobalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1

-- JOINING DEATHS AND VACCINATION DATA
-- Total Population vs Vaccinations

SELECT dea.location, dea.date, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

--USING CTE
WITH PopvsVac (Location, Population, Date, NewVaccinations, TotalVaccinations)
AS
(
SELECT dea.location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (TotalVaccinations/Population)*100
FROM PopvsVac
ORDER BY 1,2,3

--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Location nvarchar(255),
Population numeric,
Date datetime,
NewVaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (TotalVaccinations/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3


--CREATING VIEWS TO STORE DATA FOR VISUALISATION

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

CREATE VIEW DeathsByIncome AS
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location LIKE '%income'
GROUP BY location