SELECT * 
From [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM [Portfolio Project]..CovidVax

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1, 2


-- Looking at the Total Cases vs Total Deaths
-- Indicates the likelyhood of dying because of Covid in each country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Tunisia'
ORDER BY 1, 2


-- Looking at the Total Cases vs Population
-- Shows what percentage of popuation got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Tunisia'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
-- WHERE location = 'Tunisia'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with the Highest Death Count

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
-- WHERE location = 'Tunisia'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC 



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
-- WHERE location = 'Tunisia'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVax vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVax vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric, 
New_vaccinatinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVax vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated



-- Creating View To store data for visualization purposes

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVax vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated