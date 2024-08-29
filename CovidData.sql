select *
From Portfolio..CovidDeaths
order by 3,4

--select *
--From Portfolio..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
order by 1,2

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
order by 1,2

select location, date,population,total_cases, (total_cases/population)*100 as DeathPercentage
From Portfolio..CovidDeaths
order by 1,2

select location,population,Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
group by location,population
order by PercentPopulationInfected

select location,date,Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
where total_deaths is not null
group by location,date
order by TotalDeathCount desc

select sum(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where total_deaths is not null
order by 1,2


select *
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date



select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where new_vaccinations is not null 
order by 2,3

with PopvsVac (continent, location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where new_vaccinations is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where new_vaccinations is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations is not null 