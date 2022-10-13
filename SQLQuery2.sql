/*

Covid-19 Data exploration

*/



SELECT *
From SQLDataExploration..['Covid-Deaths']
Where continent is not null
order by 3,4


-- Select Data to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From SQLDataExploration..['Covid-Deaths']
order by 1,2

--- Total Cases vs Total Deaths

-- Shows likelehood of dying if you contract covid-19 in New Zealand

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100  as DeathPercentage
From SQLDataExploration..['Covid-Deaths']
Where location like '%new zealand%'
order by 1,2


--- Total Cases vs Population

-- Shows what percentage of New Zealanders have had covid

Select Location, date, Population, total_cases, (total_cases/population) * 100  as PercentPopInfected
From SQLDataExploration..['Covid-Deaths']
Where location like '%new zealand%'
order by 1,2

-- Countries with highest infection rate when compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From SQLDataExploration..['Covid-Deaths']
Group by Location, Population
order by PercentPopInfected desc

-- Countries with the highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From SQLDataExploration..['Covid-Deaths']
Where continent is not null
Group by Location
order by TotalDeathCount desc


---- CONTINENTAL EXPLORATION


-- Continental Death Count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From SQLDataExploration..['Covid-Deaths']
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQLDataExploration..['Covid-Deaths']
Where continent is not null
order by 1,2

-- Total Pop vs Vaccinations

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (PARTITION by death.location ORDER by death.location, death.date) as RollingPeopleVaccinated
From SQLDataExploration..['Covid-Deaths'] death
Join SQLDataExploration..['owid-covid-data1'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3


-- USE CTE to show what percentage of the population is vaccinated

With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (PARTITION by death.location ORDER by death.location, death.date) as RollingPeopleVaccinated
From SQLDataExploration..['Covid-Deaths'] death
Join SQLDataExploration..['owid-covid-data1'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac



-- Temp Table
DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentpopulationVaccinated

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (PARTITION by death.location ORDER by death.location, death.date) as RollingPeopleVaccinated
From SQLDataExploration..['Covid-Deaths'] death
Join SQLDataExploration..['owid-covid-data1'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentpopulationVaccinated


-- Creating view to store data for lata visualisations

Create view PercentpopulationVaccinated as 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (PARTITION by death.location ORDER by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From SQLDataExploration..['Covid-Deaths'] death
Join SQLDataExploration..['owid-covid-data1'] vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
--order by 2,3