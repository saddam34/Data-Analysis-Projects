
select * from PortfolioProject..Covid_Deaths
where continent is not null
order by 3,4;

--select * from PortfolioProject..Covid_Vaccinations
--order by 3,4;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Covid_Deaths
where continent is not null
order by 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Covid_Deaths
where location like '%India%' and continent is not null
order by 1,2;


-- Looking at Total Cases Vs Population
-- shows what percantage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
from Covid_Deaths
where location like '%India%' and continent is not null
order by 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as Highest_Infection_Count,
max((total_cases/population))*100 as PercentPopulationInfected
from Covid_Deaths
-- where location like '%India%'
where continent is not null
group by location, population
order by 4 desc;


-- Showing countries with highest Death count per population
select location,
max(cast(total_deaths as int)) as Total_Death_Counts
from Covid_Deaths
where continent is not null
group by location
order by 2 desc;


-- Showing continents with the highest death count per population
select continent, max(cast(Total_deaths as int)) as Total_Death_Count
from Covid_Deaths
where continent is not null
group by continent
order by Total_Death_Count desc;


-- GLOBAL NUMBERS
select sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as Death_Percentage
from Covid_Deaths
-- where location like '%India%'
where continent is not null
-- group by date
order by 1,2;


-- Total Populations Vs Vaccination
-- Shows Percentage of Population that has received at least one covid vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
-- ,(Rolling_People_Vaccinated/population)*100
from PortfolioProject..Covid_Deaths as dea
join PortfolioProject..Covid_Vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- Using CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%India%'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percent_People_Vaccinated
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%India%'
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
USE PortfolioProject;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create view Percent_Population_Vaccinated as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 2,3

select * from Percent_Population_Vaccinated;

select * from Covid_Deaths;
