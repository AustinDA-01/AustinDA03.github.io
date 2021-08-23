/*
Covid 19 Data Exploration

In this Project I used Joins, CTE's, Temp tables, Windows Function, Agregate Fundcitons, Creating Views, Covering Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- Select Data we will be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Lookoing at the Total Cases vs the Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at countries with highest Infection rate compared to population

Select Location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Break it down by continents
-- Showing the continents with the highest death count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Breaking downn the numbers globally

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

-- Looking at the total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order  by 2,3

-- Use CTE 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order  by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table 

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order  by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View for stored data 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
