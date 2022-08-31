drop table if exists covid_deaths;
-- create table 
create table covid_deaths (

iso_code varchar(10),
	continent varchar(30),
	location varchar(50),
	date date,
	total_cases float,
	new_cases float,
	new_cases_smoothed float,
	total_deaths float, 
	new_deaths float,
	new_deaths_smoothed float,
	total_cases_per_million float,
	new_cases_per_million float,	
	new_cases_smoothed_per_million float,
	total_deaths_per_million float,
	new_deaths_per_million float,					   
	new_deaths_smoothed_per_million float,
	reproduction_rate float,
	icu_patients float,					   
	icu_patients_per_million float,				   
	hosp_patients int, 	
	hosp_patients_per_million float,
						   
	weekly_icu_admissions float,
	weekly_icu_admissions_per_million float,
	weekly_hosp_admissions float,
	weekly_hosp_admissions_per_million float,
	new_tests int,
	total_tests int,
	total_tests_per_thousand float,
	new_tests_per_thousand float,
	new_tests_smoothed int,
	new_tests_smoothed_per_thousand float,
	positive_rate float,
	tests_per_case float,
	tests_units varchar(30),
	total_vaccinations int,
	people_vaccinated int,
	people_fully_vaccinated int,
	new_vaccinations int,
	new_vaccinations_smoothed int,
	total_vaccinations_per_hundred float,
	people_vaccinated_per_hundred float,
	people_fully_vaccinated_per_hundred float,
	new_vaccinations_smoothed_per_million int,
	stringency_index float,
	population BIGINT,
	population_density float,
	median_age float,
	aged_65_older float,
	aged_70_older float,
	gdp_per_capita float,
	extreme_poverty	float,
	cardiovasc_death_rate float,
	diabetes_prevalence float,
	female_smokers float,
	male_smokers float,
	handwashing_facilities float,
	hospital_beds_per_thousand float,
	life_expectancy float,
	human_development_index float
)

select * FROM covid_deaths;

-- import dataset 
copy covid_deaths from 'C:\Users\Pavan\Desktop\SQL\Project4\CovidDeaths.csv' with CSV HEADER encoding 'windows-1251';


select * FROM covid_deaths;

--- create 2nd table

drop table if exists covid_vaccine;
-- create table 
create table covid_vaccine (
iso_code varchar(10),
	continent varchar(30),
	location varchar(50),
	date date,
	new_tests int,
	total_tests int,
	total_tests_per_thousand float,
	new_tests_per_thousand float,
	new_tests_smoothed int,
	new_tests_smoothed_per_thousand float,
	positive_rate float,
	tests_per_case float,
	tests_units varchar(30),
	total_vaccinations int,
	people_vaccinated int,
	people_fully_vaccinated int,
	new_vaccinations int,
	new_vaccinations_smoothed int,
	total_vaccinations_per_hundred float,
	people_vaccinated_per_hundred float,
	people_fully_vaccinated_per_hundred float,
	new_vaccinations_smoothed_per_million int,
	stringency_index float,
	--population BIGINT,
	population_density float,
	median_age float,
	aged_65_older float,
	aged_70_older float,
	gdp_per_capita float,
	extreme_poverty	float,
	cardiovasc_death_rate float,
	diabetes_prevalence float,
	female_smokers float,
	male_smokers float,
	handwashing_facilities float,
	hospital_beds_per_thousand float,
	life_expectancy float,
	human_development_index float
);

select * FROM covid_vaccine;

-- import dataset2 covid_vaccine
copy covid_vaccine from 'C:\Users\Pavan\Desktop\SQL\Project4\CovidVaccinations.csv' with CSV HEADER encoding 'windows-1251';


select * FROM covid_vaccine;
---------------------
--- check all tables in database

SELECT
    table_schema || '.' || table_name
FROM
    information_schema.tables
WHERE
    table_type = 'BASE TABLE'
AND
    table_schema NOT IN ('pg_catalog', 'information_schema');
	
	
-----------------------	

-- select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2

-- looking at total cases vs total cases
Select Location, date, total_cases, total_deaths, round( CAST((total_deaths/total_cases)*100 as numeric), 2) as deathPercentage
from covid_deaths
where location like '%States%'
order by 1,2

-- looking at total cases vs population

Select Location, date, population, total_cases, round( CAST((total_cases/population)*100 as numeric), 2) as pupulationPer
from covid_deaths
--where location like '%States%'
order by 1,2

-- looking at countries with highest infection rate campared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/ population))*100 
as percentPopulationInfected
from covid_deaths
group by Location, Population
order by percentPopulationInfected desc;

-- showing contries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is not null
group by Location
order by TotalDeathCount desc;

-- group by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/ sum(New_Cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
Group by date 
order by 1,2

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from covid_deaths as dea 
join 
covid_vaccine as vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_deaths dea
Join covid_vaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_deaths dea
Join covid_vaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3 ;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PerPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_deaths dea
Join covid_vaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PerPopulationVaccinated;

---- done---
