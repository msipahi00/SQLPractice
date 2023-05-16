
--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 1, 2

-- looking at total cases v total deaths
-- shows liklihood of dynig if you have get covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1, 2


-- looking at total cases v Population  
--Shows that percentage of population got covid
SELECT Location, date, total_cases, Population, (total_cases*1.0/Population)*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population 
--CREATE VIEW [HighestInfectedRateandCount] as
Select Location, Population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases*1.0/Population))*100 as HighestInfectedRate
FROM PortfolioProject.dbo.CovidDeaths
--WHERE LOCATION LIKE '%states%'
GROUP BY Location, Population
ORDER BY HighestInfectedRate DESC

-- Showing countries with highest death count per population 

Select Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
order by 3, 4

--LET'S BREAK THINGS DOWN BY CONTINENT

--Create view [TotalDeathCountByContinent] as
Select location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers 
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 100*SUM(new_deaths)/SUM(new_cases) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


-- looking at total population vs. vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (1.0*RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255), 
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_Vaccinations numeric, 
    RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualizations

--DROP VIEW if exists [PercentPopulationVaccinated]
--CREATE VIEW [PercentPopulationVaccinated] as 





