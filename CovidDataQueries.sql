select *
from Portfolio..CovidDeath$
order by 3,4

--select *
--from Portfolio..CovidVaccinations$
--order by 3,4

--Select data to use

select dea.Location, dea.date, dea.total_cases, dea.total_deaths, vac.population
from Portfolio..CovidDeath$ as dea
join portfolio..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
order by 1,2


--Look for total cases v deaths
--Shows likelihood of dying if contracting covid in respetive country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeath$
where location ='United states'
order by 1,2


--Looking at total cases vs population

select dea.Location, dea.date, dea.total_cases, vac.population, (dea.total_cases/vac.population)*100
from Portfolio..CovidDeath$ as dea
join portfolio..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location = 'United States'
order by 1,2


--Countries with highest infection rates

select dea.Location, vac.population, MAX(dea.total_cases) as HighestInfectionCount, MAX((dea.total_cases/vac.population))*100 as PercentPopulationInfected
from Portfolio..CovidDeath$ as dea
join portfolio..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
group by dea.Location, vac.Population
order by PercentPopulationInfected desc


--Continent with highest death counts

select continent, MAX(Total_deaths) as TotalDeathCount
from Portfolio..CovidDeath$ as dea
where continent is not null
group by continent
order by TotalDeathCount desc

-- Countries with highets death count per Popualtion

select Location, MAX(Total_deaths) as TotalDeathCount
from Portfolio..CovidDeath$ as dea
where continent is not null
group by location
order by TotalDeathCount desc


-- Global Numbers
--Per day
select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeath$
where continent is not null
and new_cases != 0
group by date
order by date

--Total
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeath$
where continent is not null

--Looking at toal population vs Vaccinations


select dea.continent, dea.location, vac.date, vac.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, vac.date) as RollingPopVaccinated,
from Portfolio..CovidDeath$ dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---Using CTE


With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPopVaccinated)
as
(
select dea.continent, dea.location, vac.date, vac.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, vac.date) as RollingPopVaccinated
from Portfolio..CovidDeath$ dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPopVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopualtionVaccinated
Create Table #PercentPopualtionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopualtionVaccinated
select dea.continent, dea.location, vac.date, vac.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, vac.date) as RollingPopVaccinated
from Portfolio..CovidDeath$ dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopualtionVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, vac.date, vac.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, vac.date) as RollingPopVaccinated
from Portfolio..CovidDeath$ dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated
