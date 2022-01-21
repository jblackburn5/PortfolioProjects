SELECT *
FROM PortfolioProject..Covid_Deaths
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..Covid_Vaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
order by 1,2


-- Looking at the total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (Total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..Covid_Deaths
--Where location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..Covid_Deaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing the countries with the highestdeath count per population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continent with the highest death count per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc




-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at total poplulation vs vaccingations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later vizualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated