select *
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProjects..CovidVaccinations
order by 3,4

select location, date, population, total_cases, total_deaths
from PortfolioProjects..CovidDeaths
order by 1,2


-- Looking at Total cases vs Total Deaths for a Specific Country
-- Shows the liklihood of someone dying from contracting Covid-19

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%Nigeria%'
order by 1,2

-- Looking at the Total cases vs Population 
-- Shows percentage of population has gotten covid-19

select location, date, total_cases, population, (total_cases / population) * 100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
-- where location like '%Nigeria%'
order by 1,2

-- Looking at Countries with the Highest Infection Rate vs Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
-- where location like '%Nigeria%'
group by location, population
order by PercentPopulationInfected DESC 

-- Showing the countries with the highest Death per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

-- Breaking things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Showing the continents with the highest death count per Population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC


-- Global Numbers
select date, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(new_cases) as TotalCases,
	SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
-- where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

-- Total world deaths, cases and DeathPercentage
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
-- where location like '%Nigeria%'
where continent is not null
-- group by date
order by 1,2



-- Exploring Vaccinations
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 










 