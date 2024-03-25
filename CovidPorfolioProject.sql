select * 
from PortfolioProject..CovidDeaths
order by 3,4  --location and date (3rd and 4th colunm)

select * 
from PortfolioProject..CovidVacinations
order by 3,4

----select the data that we are going to be using

select location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

---- loking at totales cases vs total Deaths

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where location = 'Venezuela'
order by 1,2

----total cases vs population
select location, date,total_cases, population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location = 'Venezuela'
order by 1,2

-- countries whit highest infection rate
select location, population,  max(total_cases) as TotalCases ,max((total_cases/population))*100 as Total_infected_Percentage
from PortfolioProject..CovidDeaths
Group by Location, Population
order by Total_infected_Percentage desc

--showing the countries with the highes deaths porcentage by population

select location,  max(total_deaths) as TotalDeaths --, population ,max((total_deaths/population))*100 as Total_deaths_Percentage --cast(colunmName as int) to conver a colunm to integer
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location--, population 
order by TotalDeaths desc

-- lets break things down by continent

select continent,  max(total_deaths) as TotalDeaths --, population ,max((total_deaths/population))*100 as Total_deaths_Percentage --cast(colunmName as int) to conver a colunm to integer
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent--, population 
order by TotalDeaths desc

select location,  max(total_deaths) as TotalDeaths --, population ,max((total_deaths/population))*100 as Total_deaths_Percentage --cast(colunmName as int) to conver a colunm to integer
from PortfolioProject..CovidDeaths
where continent is null
Group by location--, population 
order by TotalDeaths desc

-- Global numbers

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


SELECT
    date,
    SUM(new_cases) AS new_cases,
    SUM(COALESCE(CAST(new_deaths AS int), 0)) AS total_deaths,
    SUM(COALESCE(CAST(new_deaths AS int), 0)) / SUM(new_cases) * 100 AS DeathsPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    date, new_cases

--looking at total vaccinations vs total population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(COALESCE(convert(int, new_vaccinations),0)) over (partition by dea.location Order by dea.location, dea.Date) as Total_population_vaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- use cte

with Pop_vs_Vac (continent, location, Date, population, new_vaccinations ,Total_population_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(COALESCE(convert(int, new_vaccinations),0)) over (partition by dea.location Order by dea.location, dea.Date) as Total_population_vaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (Total_population_vaccinated/population)*100 as Vaccinated_Population_Porcentage
from Pop_vs_Vac

 temp table

drop table if exists #Vaccinated_Population_Porcentage_
create table #Vaccinated_Population_Porcentage_
(
    continent nvarchar(255),
    location nvarchar(255),
    Date datetime,
    population numeric,
    new_vaccinations numeric,
    Total_population_vaccinated numeric
)

insert into #Vaccinated_Population_Porcentage_
select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(COALESCE(convert(numeric, new_vaccinations),0)) over (partition by dea.location Order by dea.location, dea.Date) as Total_population_vaccinated
FROM 
    PortfolioProject..CovidDeaths dea
join 
    PortfolioProject..CovidVaccinations vac
on 
    dea.location=vac.location
    and dea.date=vac.date
where 
    dea.continent is not null

select 
    *, 
    (Total_population_vaccinated/population)*100 as Vaccination_Percentage
from 
    #Vaccinated_Population_Porcentage_

-- Creating View to store data for later visualizations

create view VaccinatedPopulationPorcentage as
select 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(COALESCE(convert(numeric, new_vaccinations),0)) over (partition by dea.location Order by dea.location, dea.Date) as Total_population_vaccinated
FROM 
    PortfolioProject..CovidDeaths dea
join 
    PortfolioProject..CovidVaccinations vac
on 
    dea.location=vac.location
    and dea.date=vac.date
where 
    dea.continent is not null

select *
from VaccinatedPopulationPorcentage