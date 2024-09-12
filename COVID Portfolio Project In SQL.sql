

SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4 

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4 


--Select Data

Select Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
order by 1,2 


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  
FROM PortfolioProject..CovidDeaths
order by 1,2 
 

 -- Looking at Total Cases vs Population
 -- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected   
FROM PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing continents with Highest Death Count per Population 

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select date, Sum(new_cases) as GlobalCases, Sum(cast(new_deaths as bigint)) as GlobalDeaths,
Sum(cast(new_deaths as bigint))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null 
Group by date 
order by 1,2 


-- Looking at Total Population vs Vaccinations per day

SELECT deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) 
AS TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths deat
JOIN PortfolioProject..CovidVaccinations vac
	ON deat.location = vac.location
	AND deat.date = vac.date
WHERE deat.continent IS NOT NULL
ORDER BY 2,3


-- TEMPORARY TABLE

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
SELECT deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) 
AS TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths deat
JOIN PortfolioProject..CovidVaccinations vac
	ON deat.location = vac.location
	AND deat.date = vac.date
WHERE deat.continent IS NOT NULL
ORDER BY 2,3

Select *, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY deat.location ORDER BY deat.location, deat.date) 
AS TotalPeopleVaccinated
FROM PortfolioProject..CovidDeaths deat
JOIN PortfolioProject..CovidVaccinations vac
	ON deat.location = vac.location
	AND deat.date = vac.date
WHERE deat.continent IS NOT NULL


SELECT * 
FROM PercentPopulationVaccinated
