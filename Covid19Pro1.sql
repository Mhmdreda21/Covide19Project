use Covid19Pro1

select * from CovidDeaths
Select * from CovidVaccinations

Select location , date , total_cases , new_cases , total_deaths , population 
from CovidDeaths

--- Death percentage over Total cases
Select location , date , total_cases , total_deaths , (total_deaths/ total_cases)*100 as deathpercentage
from CovidDeaths
where location like'%egypt%'

--- Cases Percentage over population
Select location , date , population , total_cases , (total_cases / population ) * 100 as casespercentage
from CovidDeaths
where location like '%egypt%'

--- the highest infection rate by population
Select Location , population , MAX(total_cases) as HighestInfection
from CovidDeaths
where continent is not null
group by  Location , population
order by HighestInfection desc

-- the highest death count per population
Select location , MAX(cast( total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null 
group by location 
order by DeathCount desc


-- the continent with the highest Total_Death per population

Select continent , MAX(cast( total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null 
group by continent 
order by DeathCount desc


-- Global Numbers
select SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_Deaths ,SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPersantage
from CovidDeaths
where continent is not null

--Total Population vs Vaccination
--Use CTE
with POPvsVCC (continent , location , data , population , new_vaccinations , RollingPeopleVaccinated)
as
(
select death.continent , death.location , death.date , death.population , vcc.new_vaccinations ,
SUM(convert(int,vcc.new_vaccinations)) over (partition by death.location order by death.date, 
death.location) as RollingPeopleVaccinated 
from CovidDeaths as death
join CovidVaccinations as vcc
	on death.location = vcc.location
	and death.date = vcc.date
where death.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 
from POPvsVCC


--Create Temp Table
 create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime ,
 Population numeric,
 New_Vaccination numeric,
 RollinPeopleVaccinated numeric
 )

 insert into #PercentPopulationVaccinated
 select death.continent , death.location , death.date , death.population , vcc.new_vaccinations ,
SUM(convert(int,vcc.new_vaccinations)) over (partition by death.location order by death.date, 
death.location) as RollingPeopleVaccinated 
from CovidDeaths as death
join CovidVaccinations as vcc
	on death.location = vcc.location
	and death.date = vcc.date

select * ,(RollinPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

-- Create View
create view PercentPopulationVaccinated
as 
select death.continent , death.location , death.date , death.population , vcc.new_vaccinations ,
SUM(convert(int,vcc.new_vaccinations)) over (partition by death.location order by death.date, 
death.location) as RollingPeopleVaccinated 
from CovidDeaths as death
join CovidVaccinations as vcc
	on death.location = vcc.location
	and death.date = vcc.date
where death.continent is not null

Select * from PercentPopulationVaccinated