/*
Covid Data Exploration
*/
SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2

--Total Case vs Total Deaths
--Show likely hood of dying if you contract in your country 

SELECT location, date, total_cases,total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location like '%Indonesia%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Show what percentage of population got Covid
SELECT location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%indonesia%'
ORDER BY 1,2

-- looking at country with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount ,(CONVERT(float,MAX(total_cases))/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Show Countries with Highest Death Count per Population

SELECT Location,MAX(CAST(total_deaths as numeric)) AS TotalDeathCount 
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent,MAX(CAST(total_deaths as numeric)) AS TotalDeathCount 
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Showing continents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths as numeric)) AS TotalDeathCount 
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--global numbers

SELECT SUM(CAST(new_cases as numeric)) as total_cases, SUM(CAST(new_deaths as numeric)) as total_deaths,SUM(CAST(new_deaths as numeric))/NULLIF(SUM(CAST(new_cases as numeric)),0)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%state%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at total Population vs Vaccinations

WITH PopvsVac(Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccination vac
	ON dea.location= vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccination vac
	ON dea.location= vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccination vac
	ON dea.location= vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated