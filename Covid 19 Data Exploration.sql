SELECT * 
FROM PortfolioProject1..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject1..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1, 2 

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in US

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY InfectedPercentage DESC

-- Showing countries with highest death count per population

SELECT Location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent

--Showing continents with the highest death count

--SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
--FROM PortfolioProject1..CovidDeaths
----WHERE location like '%states%'
--Where continent is null
--GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
where continent is not null 
--Group By date
ORDER BY 1, 2 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%'
where continent is not null 
Group By date
ORDER BY 1, 2 

-- Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(Convert (int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null 
--ORDER BY  2, 3
)

Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

 --Temp Table

 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location	nvarchar(255),
 Date datetime, 
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(Convert (int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null 
--ORDER BY  2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store date for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated