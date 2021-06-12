--Select Data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid-deaths$']


--Looking at total cases vs total deaths in Poland
-- Shows what percentage die due to covid

Select location, date, total_cases, total_deaths, (convert(nvarchar, (round((convert(float, total_deaths))/(convert(float, total_cases)), 4)*100)) + '%') as Cases_Percentage
From PortfolioProject..['covid-deaths$']
where location = 'poland'
and continent is not NULL
 

--Looking at total cases vs population in Poland
-- Shows what percentage of population got coivd

Select location, date, total_cases, population, (convert(nvarchar, (round((convert(float, total_cases))/(convert(float, population)), 4)*100)) + '%') as Cases_Percentage
From PortfolioProject..['covid-deaths$']
where location = 'poland'
and continent is not NULL

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS Highest_Infection,  MAX((round((convert(float, total_cases))/(convert(float, population)), 4))*100) as Cases_Percentage
From PortfolioProject..['covid-deaths$']
where continent is not NULL
Group by population, location
order by Cases_Percentage desc

--Showing countries with highest death count per population

Select location, population, MAX(cast(total_deaths as float)) as Total_Death_Count
From PortfolioProject..['covid-deaths$']
where continent is not NULL
Group by location, population
order by 3 desc

--Showing continents with highest death count per population

Select location, MAX(cast(total_deaths as float)) as Total_Death_Count
From PortfolioProject..['covid-deaths$']
where continent is NULL
Group by location
order by 2 desc

--Global Numbers

Select SUM(cast(new_cases as float)) as cases, SUM(cast(new_deaths as float)) as deaths, convert(nvarchar, (round(SUM((convert(float, new_deaths)))/SUM((convert(float, new_cases))), 4)*100)) + '%' as Cases_Percentage
From PortfolioProject..['covid-deaths$']                                                      
--where location = 'poland'
where continent is not NULL
--group by date
order by 1, 2

--Total population vs vacciantion

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) as VaccinationProgression,
--(VaccinationProgression/population) as Vaccination_per_population
from PortfolioProject..['covid-deaths$'] dea
join PortfolioProject..['owid-covid-data project$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 order by 2, 3


-- USE CTE

With PopvsVac (Continent, Localtion, date, population, new_vaccinations, VaccinationProgression)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) as VaccinationProgression
--(VaccinationProgression/population) as Vaccination_per_population
from PortfolioProject..['covid-deaths$'] dea
join PortfolioProject..['owid-covid-data project$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 )
	 
	 Select*, (convert(nvarchar, (round((convert(float, VaccinationProgression))/(convert(float, population)), 4)*100)) + '%') as vaccination_percent
	 from PopvsVac



	 --Temp table

Drop table if exists #Percentvacc
Create Table #Percentvacc
(
Continent nvarchar(255), 
Location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
VaccinationProgression numeric
)

Insert into #Percentvacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) as VaccinationProgression
--(VaccinationProgression/population) as Vaccination_per_population
from PortfolioProject..['covid-deaths$'] dea
join PortfolioProject..['owid-covid-data project$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 

 Select*, (convert(nvarchar, (round((convert(float, VaccinationProgression))/(convert(float, population)), 4)*100)) + '%') as vaccination_percent
	 from #Percentvacc

	 --Creating View for visualization

	 Create View Percentvacc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (partition by dea.location order by dea.location,dea.date) as VaccinationProgression
--(VaccinationProgression/population) as Vaccination_per_population
from PortfolioProject..['covid-deaths$'] dea
join PortfolioProject..['owid-covid-data project$'] vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2, 3


	 



	 


	 