SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total cases vs Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%nigeria%'
ORDER BY 1, 2

-- Total cases vs Population

SELECT location, date, Population, total_cases, (total_cases/Population)*100 AS CovidCases
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%nigeria%'
ORDER BY 1, 2

-- Countries with the Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%nigeria%'
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%nigeria%'
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continents with the Highest Death Count per Population

SELECT Continent, MAX(cast(total_deaths AS int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%nigeria%'
GROUP BY Continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS(DAILY)

SELECT date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths AS INT)) TotalDeath, SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--GLOBAL NUMBERS(OVERALL)
SELECT SUM(new_cases) TotalCases, SUM(CAST(new_deaths AS INT)) TotalDeath, SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%nigeria%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


--Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--Using CTE

WITH PopVsVac AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated,  (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVac
FROM PopVsVac
WHERE continent IS NOT NULL
ORDER BY 2, 3


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATE VIEW

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

