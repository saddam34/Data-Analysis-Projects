use PortfolioProject;

/*
Queries used for Tableau Covid19 Visualization Project
*/



-- 1. Table _1 : [ total_cases, total_deaths, deathpercentage] 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. Table_2 : [ location, TotalDeathCount]

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Table_3 : [ Location, Population, HighestInfectionCount, PercentPopulationInfected]

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Table_4 : [ Location, Population, HighestInfectionCount, PercentPopulationInfected]



Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


