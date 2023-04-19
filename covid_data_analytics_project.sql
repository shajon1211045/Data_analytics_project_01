select * 
from portfolio_project .. covid_deaths
order by 3,4;

--Select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project .. covid_deaths
order by 1,2;

--Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project .. covid_deaths
order by 1,2;

--Looking at Total Cases vs Population

select location, date, total_cases, Population, (total_cases/population)*100 as percentage_of_population_affected
from portfolio_project .. covid_deaths
order by 1,2;

--Looking at Countries with Highest Infection Rate compared to Population

select location, max(total_cases) as HigestInfectionCount, Population, max((total_cases/population))*100 as percentage_of_population_affected
from portfolio_project .. covid_deaths
group by location,Population
order by percentage_of_population_affected desc;


--Showing the Countries with the Highest Death-Counts per Population

select location, max(cast(total_deaths as int)) as total_death_count
from portfolio_project .. covid_deaths
where continent is not null
group by location
order by total_death_count desc;


--Showing Continents with the Highest Death Count per Population

select continent, max(cast(total_deaths as int)) as total_death_count
from portfolio_project .. covid_deaths
where continent is not null
group by continent
order by total_death_count desc;



--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totat_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from portfolio_project .. covid_deaths
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totat_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from portfolio_project .. covid_deaths
where continent is not null
--group by date
order by 1,2;


-- Looking at Total Population vs Vaccinations
--Using common table expressions

with PopvsVac ( continent, location, date , population, new_vaccinations, cumulative_total) as
(Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cumulative_total
from portfolio_project .. covid_deaths cd
join portfolio_project ..covid_vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)

select * , (cumulative_total/population)*100 as cumulative_vaccination_percentage
from PopvsVac;



--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated

( continent  nvarchar(255),
  location   nvarchar(255),
  date     datetime,
  population numeric,
  new_vaccinations numeric,
  cumulative_total numeric
  )

insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cumulative_total
from portfolio_project .. covid_deaths cd
join portfolio_project ..covid_vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3


select * , (cumulative_total/population)*100 as cumulative_vaccination_percentage
from #PercentPopulationVaccinated;


--Creating View to Store Data for Later Visualizations
--drop view PercentPopulationVaccinated
create view PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cumulative_total
from portfolio_project .. covid_deaths cd
join portfolio_project ..covid_vaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null;
--order by 2,3

select * 
from PercentPopulationVaccinated;