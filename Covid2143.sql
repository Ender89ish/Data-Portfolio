--Select *
--From [Portfolio Project]..CovidDeaths
--Order By 3,4

----Select *
----From [Portfolio Project]..CovidVaccinations
----Order By 3,4

--Select Location, date, total_cases, new_cases, total_deaths, [Column 62] AS population
--From [Portfolio Project]..CovidDeaths
--Order By 1,2

----Determining death rate

Select Location, date,  
cast(total_cases as bigint) as total_cases,
cast(total_deaths as bigint) as total_deaths,
(cast(total_deaths as bigint)/Nullif (cast(total_cases as bigint), 0))*100 as Death_Rate
From [Portfolio Project]..CovidDeaths
Order By 1,2


--Convert to floats when using division else return x/0 or 0

Select Location, date,  
total_cases, total_deaths,
(convert(float, total_deaths)/Nullif (convert(float, total_cases), 0))*100 as Death_Rate
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order By 1,2

--Determine infection rate

Select Location, date, [Column 62] as population, total_cases, total_deaths, 
(convert(float, total_deaths)/Nullif (convert(float, total_cases), 0))*100 as Death_Rate,
(convert(float, total_cases)/Nullif (convert(float, [Column 62]), 0))*100  as Daily_Infect_Percent
From [Portfolio Project]..CovidDeaths
Order By 1,2


--Highest infection rate compared to pop

Select Location, [Column 62] as population, MAX(convert(float, total_cases)) as highestInfectCount,
MAX((convert(float, total_cases)/Nullif(convert(float, [Column 62]), 0)))*100  as Infect_Percent
From [Portfolio Project]..CovidDeaths
--Where location like '%montenegro%'
Group BY Location, [Column 62]
Order By Infect_Percent desc

--Countries with highest number of fatalities 
--Would have been easier to filter from the original csv

Select location, MAX(convert(float, total_deaths)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where location NOT IN('Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
and  continent is not null
Group BY location
Order By TotalDeathCount desc



--Continents with highest death count per population

Select continent, MAX(convert(float, total_deaths)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group BY continent
Order By TotalDeathCount desc


--Global numbers


Select date, Sum(convert(float, new_cases)) as new_cases, Sum(convert(float, new_deaths)) as NewDeathCount,
(convert(float, new_deaths)/Nullif (convert(float, new_cases), 0))*100 as Death_Rate
From [Portfolio Project]..CovidDeaths
Where location NOT IN('Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
and  continent is not null
Group BY date, (convert(float, new_deaths)/Nullif (convert(float, new_cases), 0))*100 
Order By 1, 2

--Population vaccinated


Select dea.continent, dea.location, convert(DATE,dea.date) as date, dea.[Column 62] as population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Population_Vaxed
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.location NOT IN('International','Oceania', 'Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
	 and dea.continent is not null
	 Group by dea.date, dea.continent, dea.location, dea.[Column 62], vac.new_vaccinations
	 Order by 2,3

 --Use CTE for further calculations
With PopvsVac(continent, location, date, population, new_vaccinations, Population_Vaxed)
as (
Select dea.continent, dea.location, convert(DATE,dea.date) as date, dea.[Column 62] as population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Population_Vaxed
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.location NOT IN('International','Oceania', 'Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
	 and dea.continent is not null
	 Group by dea.date, dea.continent, dea.location, dea.[Column 62], vac.new_vaccinations)
	 Select *, (Population_Vaxed/population)*100 as RollingPercVac
	 From PopvsVac
	 Order by 2,3

--Create a temp table
Drop Table if exists #PopulationVaccinated
 Create Table #PopulationVaccinated
 (
Continent nvarchar(255),
location nvarchar(255),
Date date,
population float,
new_vaccinations float,
Population_Vaxed float
)
Insert into #PopulationVaccinated
Select dea.continent, dea.location, convert(DATE,dea.date) as date, dea.[Column 62] as population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Population_Vaxed
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.location NOT IN('International','Oceania', 'Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
	 and dea.continent is not null
	 Group by dea.date, dea.continent, dea.location, dea.[Column 62], vac.new_vaccinations
	  Select *, (Population_Vaxed/population)*100 as RollingPercVac
	 From #PopulationVaccinated
	 Order by 2,3

	 --views for table


	 Create view PopulagtionVaccinated as
Select dea.continent, dea.location, convert(DATE,dea.date) as date, dea.[Column 62] as population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, convert(DATE,dea.date)) as Population_Vaxed
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.location noT IN('International','Oceania', 'Asia', 'European Union', 'Europe', 'High income', 'Upper middle income', 'Lower middle income', 'North America', 'World', 'United States', 'South America', 'Africa', 'Low income')
	 and dea.continent is not null
	 Group by dea.date, dea.continent, dea.location, dea.[Column 62], vac.new_vaccinations
	 Order by 2,3,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
	 Offset 0 rows

