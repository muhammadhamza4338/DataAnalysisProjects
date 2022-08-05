
select * from CovidDeaths


--Infected percentage of total population
select location, date,population,total_cases, (total_cases/population)*100 as PerctangeInfected
from CovidDeaths
where location like '%states%'
order by location,date

-- maximum percentage of infected population in a country
select location, population, max(total_cases) as Maximum_Total_Cases, max((total_cases/population))*100 as Maximum_Percentage
from CovidDeaths
group by location,population
order by Maximum_Percentage desc


-- RollingPeopleVaccination
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



--common table expression cte

with percentageVaccinated (continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select continent,location,date,population,new_vaccination,(rollingpeoplevaccinated/population)*100 as PercentageOfVaccinatedPopulation
from percentageVaccinated


-- Temp Table
drop table if exists #PercentagePeopleVaccinated
create table #PercentagePeopleVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #PercentagePeopleVaccinated
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * from #PercentagePeopleVaccinated


--View

create view percetagePeopleVaccinated as
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 as VaccinationPercentage from percetagePeopleVaccinated