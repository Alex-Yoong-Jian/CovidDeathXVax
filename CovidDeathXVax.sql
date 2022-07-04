SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER by 3,4

-- COVID DEATHS TABLE
SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER by 3,4

---- SELECT DATA THAT ARE TO BE USED 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

-- OBSERVING TOTAL CASES VS TOTAL DEATHS 
-- Shows likelihood of dying for the country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states'
ORDER BY Location, date

-- OBSERVING TOTAL CASES VS POPULATION
-- Shows the percentage of population infected with Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states'
ORDER BY Location, date

-- OBSERVING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- OBSERVING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT Location, population, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- OBSERVING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- OBSERVING TOTAL DEAT PERCENTAGE IN THE GLOBE AS A WHOLE
-- GLOBAL VIEW
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states'
WHERE continent IS NOT NULL
ORDER BY 1,2






-- COVID VACCINATIONS TABLE X COVID DEATHS TABLE

SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- OBSERVING Total Populations vs Vaccinations
-- USE CTE
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, CumulativeVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 AS PercentageVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (CumulativeVaccinations/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 AS PercentageVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativeVaccinations/Population)*100
FROM #PercentPopulationVaccinated






-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 AS PercentageVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


-- CALLING THE VIEW
SELECT * 
FROM PercentPopulationVaccinated