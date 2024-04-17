select *
from PortfolioProject..CovidVaccinations$
order by 3,4

select*
from PortfolioProject..CovidDeaths
order by 3,4

-- select date we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
--shows death percent of india
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercent
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- total cases vs population

Select location,date,total_cases,(total_cases/population)*100 as infectedpercent
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


--countries with highest infection rate as compared to population

Select location,population,MAX(total_cases) as HighestInfectionCoun,MAX((total_cases/population))*100 as infectedpercent
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by infectedpercent desc

--countries with highest Death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--breaking by continents
--continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date,sum(new_cases),sum(cast(new_deaths as int)),SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

--population vs vaccination
--shows percentage of population that has received one vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 1,2


 select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinated
 from PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.date=vac.date
 and dea.location=vac.location
 where dea.continent is not null
 order by dea.location

 -- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopuVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
