Select*
From CovidPortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Order by 3,4

Select*
From CovidPortfolioProject..CovidVaccinations
Order by 3,4

--Selecting data which is going to be used
Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total deaths per total cases
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)
From CovidPortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total deaths per total cases percentage
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Order by 1,2

--Looking at DeathPercentage in India
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like 'Indi%'
Order by 1,2

--Looking at DeathPercentage in US
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%States%'
Order by 1,2

--Looking at CasePercentage in India
Select location, date, total_cases, Population, (total_cases/Population)*100 as CasePercentage
From CovidPortfolioProject..CovidDeaths
Where location='India'
Order by 1,2

--Looking at CasePercentage Worldwide
Select location, date, total_cases, Population, (total_cases/Population)*100 as CasePercentage
From CovidPortfolioProject..CovidDeaths
Order by 1,2

--Locations with highest infection rate compared to population
Select location, Population, max(total_cases) as HighestInfectionCount, Max((total_cases/Population)*100) 
as PercentagePopulationInfected
From CovidPortfolioProject..CovidDeaths
Group by Location,population
Order by PercentagePopulationInfected Desc

--Locations with highest death count per location
Select location,  max(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Group by Location
Order by TotalDeathCount Desc

--Continents with highest DeathCount
Select Continent,  max(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Group by Continent
Order by TotalDeathCount Desc

--Global Numbers-daily cases 
Select date, sum(new_cases)
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global Numbers-daily cases and daily deaths
Select date, sum(cast(new_cases as int)), sum(cast(new_deaths as int))
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global Numbers-daily cases, daily deaths, daily death percentage
Select date, sum(cast(new_cases as float)) as Daily_New_cases, sum(cast(new_deaths as float)) as Daily_New_deaths, 
(sum(cast(new_deaths as float)))/(sum(cast(new_cases as float))) * 100  as Daily_Death_Percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global DeathPercentage
Select sum(cast(new_cases as float)) as Daily_New_cases, sum(cast(new_deaths as float)) as Daily_New_deaths, 
(sum(cast(new_deaths as float)))/(sum(cast(new_cases as float))) * 100  as Daily_Death_Percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Joining 2 tables
Select * 
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations Vacc
	On dea.location=vacc.location
	and dea.date=vacc.date
	Where dea.continent is not null

--Population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null
Order by 2,3

--Population vs vaccination by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location)as Total_Vaccinations_Per_Location
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null
Order by 2,3

--Daily Totalled Vaccinations per location-Population vs vaccination by location ordered by location, date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date)as Daily_Totalled_Vaccinations_Per_Location
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null
Order by 2,3

--Percentage Rolling People Vaccinated 
--CTE to be used, as column name alias can't be used in Rolling People Vaccinated Percentage formula

With PopVsVac(Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated_Per_Location)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date)as Rolling_People_Vaccinated_Per_Location
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null)
--Order by 2,3 Commented, since error
Select*,((Rolling_People_Vaccinated_Per_Location/Population)*100) as Rolling_People_Vaccinated_Percentage
From PopVsVac

--Using Temp Table for Same
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
Rolling_People_Vaccinated_Per_Location float
)

--Temp Table
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated_Per_Location
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null
--Order by 2,3 Commented, since error
Select*,(Rolling_People_Vaccinated_Per_Location/Population)*100 as Rolling_People_Vaccinated_Percentage
From #PercentPopulationVaccinated

--Creating View for later data visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated_Per_Location
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null
--Order by 2,3 Commented, since error

Select*
From PercentPopulationVaccinated
