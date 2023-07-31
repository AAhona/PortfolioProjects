

SELECT *
FROM PortfolioProject..CovidDeaths
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

SELECT Location, date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths


SELECT Location, date, total_cases,total_deaths,(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
Order by 2


-- Total cases vs population

SELECT Location, date, total_cases, population,(CAST(total_cases AS int) / CAST(population AS bigint))*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
Order by 2

SELECT Location,MAX(total_cases) as HighestInfected, population,MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)))*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
Group by location, population
Order by CasePercentage desc

-- Counties with highest death count

SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not NULL
Group by location
Order by TotalDeathCount desc

-- Global Numbers

SELECT  SUM(new_cases),SUM(new_deaths),Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
where new_cases<>0
and continent is not null
--Group by date
Order by 1,2

--Looking at total population vs vaccination

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- CTE TABLE

With PopvsVac (Continenet, Location, Date, Population,New_Vaccination, RollingVac)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingVac/Population)*100
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopVac
Create Table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingVac numeric
)

Insert into #PercentPopVac
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingVac/Population)*100
from #PercentPopVac



-- Creating View

CREATE VIEW PercentPopVac2 as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopVac2