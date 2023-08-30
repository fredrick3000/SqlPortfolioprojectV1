
--Cases I: Total Cases Vs Total Death
--Shows the tendency of dying after contraction in Nigeria

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project1..CovidDeaths$
Where location like 'Nigeria' and continent is not null
Order by date

--Case II: Total Cases Vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as Percent_population_infected
From Portfolio_Project1..CovidDeaths$
Where location like 'Nigeria' and continent is not null
order by date

--Case III: Countries in Africa with highest infection rate compared to populaton

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Percent_population_infected
From Portfolio_Project1..CovidDeaths$
Where continent like 'Africa' and continent is not null
Group by location, population 
Order by Percent_population_infected desc

--Case IV: Countries in Africa with highest death rate compared to populaton

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_deaths as int)) as HighestDeathCount 
From Portfolio_Project1..CovidDeaths$
Where continent like 'Africa' and continent is not null
Group by location, population 
Order by HighestDeathCount desc

--Case V: Total Cases Vs Total Death by Continent

Select continent, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project1..CovidDeaths$
Where continent is not null
group by continent
order by HighestDeathCount desc

--Case VI: Global Death Percentage
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project1..CovidDeaths$
order by 1,2

--Case VII: Total Vaccination As against Population 
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
From Portfolio_Project1..CovidDeaths$ Dea
join Portfolio_Project1..CovidVaccinations$_xlnm#_FilterDatabase Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

--Case VII(a): Rolling People Vaccinated 
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER(Partition by Dea.location order by Dea.location) as Rolling_People_Vac		
From Portfolio_Project1..CovidDeaths$ Dea
join Portfolio_Project1..CovidVaccinations$_xlnm#_FilterDatabase Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3


--Case VII(b): Rolling People Vaccinated vs Population With CTE
With VacVsPop ( continent, location, date, population, new_vaccinations, Rolling_People_Vac)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER(Partition by Dea.location order by Dea.location) as Rolling_People_Vac		
From Portfolio_Project1..CovidDeaths$ Dea
join Portfolio_Project1..CovidVaccinations$_xlnm#_FilterDatabase Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
)
Select*, (Rolling_People_Vac/population)*100
From VacVsPop


--Case VII(c): Rolling People Vaccinated vs Population With Temp table

Drop Table if exists #VaccVsPop
Create Table #VaccVsPop
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vac numeric
)
Insert into #VaccVsPop
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER(Partition by Dea.location order by Dea.location) as Rolling_People_Vac		
From Portfolio_Project1..CovidDeaths$ Dea
join Portfolio_Project1..CovidVaccinations$_xlnm#_FilterDatabase Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 1,2 
Select*, (Rolling_People_Vac/population)*100
From #VaccVsPop

----Case VIII: Creating View to store data for later visualization
--View I 
Create view VaccVsPop as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as int)) OVER(Partition by Dea.location order by Dea.location) as Rolling_People_Vac		
From Portfolio_Project1..CovidDeaths$ Dea
join Portfolio_Project1..CovidVaccinations$_xlnm#_FilterDatabase Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null

--View II Total Cases Vs Total Death by Continent
Create view TtCasesVsTtDeath as
Select continent, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project1..CovidDeaths$
Where continent is not null
group by continent

--View III: Countries in Africa with highest infection rate compared to population
Create view Deathrateafrica as
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Percent_population_infected
From Portfolio_Project1..CovidDeaths$
Where continent like 'Africa' and continent is not null
Group by location, population 

