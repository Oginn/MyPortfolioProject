-- WORKING WITH COVID DATA SET
Select *
From PortfolioProject..Coviddeath
where continent is not null
order by 3,4

--Select *
--From PortfolioProject. .Covidvancination
--order by 3,4
-- Selecting the Data that i will be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject. .Coviddeath
where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
--Filtering for Nigeria

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject. .Coviddeath
where location like '%nigeria%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covids
-- Nigeria in General
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationinffected
From PortfolioProject. .Coviddeath
where location like '%nigeria%'
order by 1,2



-- Looking at countries with Highest Infection Rate to Population
Select Location, Population, MAX(total_cases) as HighestinfectionCount, Max((total_cases/population))*100 as PercentPopulationinffected
From PortfolioProject. .Coviddeath
-- where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationinffected desc



-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .Coviddeath
-- where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Group by Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .Coviddeath
-- where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- The Correct Number is using Location

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .Coviddeath
-- where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


-- Showing the continent with the highest eath count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject. .Coviddeath
-- where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc



-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as Deathpercentage
From PortfolioProject. .Coviddeath
-- where location like '%nigeria%'
where continent is not null
Group by date
order by 1,2



-- Total Cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as Deathpercentage
From PortfolioProject. .Coviddeath
-- where location like '%nigeria%'
where continent is not null
-- Group by date
order by 1,2


-- Joinning the two database by location and date
-- Looking at total population by vaccination


select*
From PortfolioProject..Coviddeath dea
Join PortfolioProject..Covidvancination vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population by vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath dea
Join PortfolioProject..Covidvancination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath dea
Join PortfolioProject..Covidvancination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 PercentVacinated
From PopvsVac



-- TEMP TABLE
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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath dea
Join PortfolioProject..Covidvancination vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





--- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeath dea
Join PortfolioProject..Covidvancination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From #PercentPopulationVaccinated
