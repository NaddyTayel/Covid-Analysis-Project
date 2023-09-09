select *
from CovidDeath
where continent is not null

-- Select data that we are going to be using

select location, date, population, total_cases, new_cases , total_deaths
from CovidDeath
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage

select location, date, total_cases, total_deaths, 
(convert(float, total_deaths) / nullif (convert(float, total_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%egypt%' 
and continent is not null
order by 1,2

-- looking at total cases vs population
-- showing what percentage of population got covid
select location, date, population, total_cases, 
(convert(float, total_cases) / nullif (convert(float, population),0))*100 as PopulationPercentage
from PortfolioProject..CovidDeath
where continent is not null
--where location like '%egypt%'
order by 1,2


-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, 
max((convert(float, total_cases) / nullif (convert(float, population),0)))*100 as PopulationPercentage
from PortfolioProject..CovidDeath
--where location like '%egypt%'
where continent is not null
group by location, population
order by PopulationPercentage desc

-- showing countries with highest death count per population
select location, max(total_deaths) as HighestTotalDeaths 
from PortfolioProject..CovidDeath
--where location like '%egypt%'
where continent is not null
group by location
order by HighestTotalDeaths desc


----let's break things down by continent
--select continent, max(total_deaths) as HighestTotalDeaths 
--from PortfolioProject..CovidDeath
----where location like '%egypt%'
--where continent is not null
--group by continent
--order by HighestTotalDeaths desc

--let's break things down by continent
select continent, max(total_deaths) as HighestTotalDeaths 
from PortfolioProject..CovidDeath
--where location like '%egypt%'
where continent is not null
group by continent
order by HighestTotalDeaths desc


-- showing continents with the highest death count per population
select continent, max(total_deaths) as HighestTotalDeaths 
from PortfolioProject..CovidDeath
--where location like '%egypt%'
where continent is not null
group by continent
order by HighestTotalDeaths desc

-- global numbers
select  sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeath,
sum((convert(float, new_deaths) / nullif (convert(float, new_cases),0)))*100 as DeathPercentage
from PortfolioProject..CovidDeath
--where location like '%egypt%' 
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by date
order by 3,4


-------------------------

with PopvsVac (continent, location , date , population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated

from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by date
--order by 3,4
)

select *, (RollingPeopleVaccinated / population) * 100 
from PopvsVac

-- create tem table 
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent varchar(155),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--group by date
order by 3,4

select *, (RollingPeopleVaccinated / population) * 100 
from #PercentagePopulationVaccinated


-- create view
create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--group by date
--order by 3,4

select *
from PercentagePopulationVaccinated