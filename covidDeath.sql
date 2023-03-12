covidDeath.sql

/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--Exploring the data
Select *
From CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

--Looking at the total number of covid cases and death in the United States
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows the percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectedPopulationInPercent
From CovidDeaths
Where location like '%states%'
order by 1,2

/* The data shows that the population of US at 22-01-2020 is over 331 million and only one case was recorded
However, as at 12-07-2022 the number of covid cases has risen to 3,311,312 (1% of the population)  As at 20-4-2021,
32,346,971 cases have been recorded (10% population) */


-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected

From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

/*Andorra tends to have the highest infection rate at 17%, Montenegro at 15.5%, Czech comes third at 15.2%*/

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

/*United States happens to have highest number of death count with a total of 576232, Brazil has the second
highest number with 403781, while mexico has the third highest covid death 216907*/

-- Contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

/*Europe has the highest death toll at 1,016,750, followed by North America by 847,942, South America has the third
highest death toll at 672415*/


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From CovidDeaths death
Join CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With vaccinatedPopulace (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From CovidDeaths death
Join CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
)
--calculating the percentage of people that had recieved at atleast one covid vaccine
Select *, (RollingPeopleVaccinated/Population)*100
From vaccinatedPopulace


-- Creating View to store data for visualizations
Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From CovidDeaths death
Join CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 