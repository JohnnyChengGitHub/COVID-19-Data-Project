
SELECT *
FROM [DataExploration Portfolio Project]..CovidDeaths
Where continent is not null
ORDER BY 3,4

SELECT *
FROM [DataExploration Portfolio Project]..CovidVaccinations
ORDER BY 3,4


-- Likelihood of dying from contracting COVID-19 in respective countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [DataExploration Portfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Countries with highest infection rate per capita
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM [DataExploration Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- Countries with highest death count per capita
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [DataExploration Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Continents with highest death count per capita

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [DataExploration Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM [DataExploration Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM [DataExploration Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

---- Rolling people vaccinated for each country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population) * 100 as PercentageVaccinated
FROM [DataExploration Portfolio Project]..CovidDeaths as dea
JOIN [DataExploration Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


--USE Common Table Expression

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population) * 100 as PercentageVaccinated
FROM [DataExploration Portfolio Project]..CovidDeaths as dea
JOIN [DataExploration Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	)
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPercentagePeopleVaccinated
FROM PopvsVac




--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, MAX(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population) * 100 as PercentageVaccinated
FROM [DataExploration Portfolio Project]..CovidDeaths as dea
JOIN [DataExploration Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population) * 100 as PercentageVaccinated
FROM [DataExploration Portfolio Project]..CovidDeaths as dea
JOIN [DataExploration Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPercentagePeopleVaccinated
FROM #PercentPopulationVaccinated

--Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population) * 100 as PercentageVaccinated
FROM [DataExploration Portfolio Project]..CovidDeaths as dea
JOIN [DataExploration Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated
