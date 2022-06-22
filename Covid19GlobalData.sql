--SELECT * 
--from PortfolioProject..CovidDeaths
--order by 3,4

--SELECT * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1,2

-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 PercentageofDeathLikelihood
from PortfolioProject..CovidDeaths
Where location like '%italy%'
order by 1,2

-- Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 PercentageofPopulation
from PortfolioProject..CovidDeaths
Where location like '%korea%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) HighestInfection, population, Max((total_cases/population))*100 PercentageofPopulation
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentageofPopulation desc

-- Countries with Highest Death Count per Population
Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Break by continent
Select continent, MAX(cast(total_deaths as int)) totalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers
Select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


SElect*
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date

-- Total Population vs Vaccination
SElect cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.location, cd.date) totalVaccination
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- USE CTE
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, totalVaccination)
as
(SElect cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.location, cd.date) totalVaccination
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
)

Select *, (totalVaccination/Population)*100
from PopVsVac

--TEMP TABLE
DROP TABLE if exists  #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated 
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
totalVaccination numeric)
Insert into #PercentPopulationVaccinated 
SElect cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.location, cd.date) totalVaccination
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

Select *, (totalVaccination/Population)*100
from #PercentPopulationVaccinated 

-- Create view to store data for visualizaation

Create View PercentPopulationVaccinated as
SElect cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.location, cd.date) totalVaccination
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null

SELECT * 
from PercentPopulationVaccinated
