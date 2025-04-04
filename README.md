use [Covid 19]
SELECT * FROM CovidDeaths ORDER BY 3,4;
SELECT * FROM CovidVaccinations ORDER BY 3,4;

--SELECT DATA THA WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths ORDER BY 1,2;

--LOOKING OUT TOTAL CASES AND TOTAL DEATHS --shows the likelihood of death in your country

SELECT Location, date, total_cases, total_deaths FROM CovidDeaths WHERE Location LIKE '%states%' ORDER BY 1,2;

--looking at total cases vs population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as deathperc FROM CovidDeaths
WHERE Location LIKE '%states%' ORDER BY 1,2;

--looking at countries with hihest infection rate compare to population

SELECT Location,population, MAX(total_cases) AS HIGHESTCOUNT, MAX((total_cases/population))*100 as POPULATIONINFECTED FROM CovidDeaths
WHERE Location LIKE '%states%' GROUP BY location, population ORDER BY POPULATIONINFECTED DESC;

--SHOWING COUNTRIES HIGHEST DEATH COUNT

SELECT Location, MAX(total_deaths) AS HIGHESTCOUNT FROM CovidDeaths
WHERE Location LIKE '%states%' GROUP BY location ORDER BY HIGHESTCOUNT DESC;

SELECT * FROM CovidDeaths ORDER BY 3,4;

SELECT location, MAX(Total_deaths) as deathcount FROM CovidDeaths
WHERE location is not NULL GROUP BY location ORDER BY deathcount desc;

--showing the continent with highest deathcount

SELECT continent, MAX(Total_deaths) as deathcount FROM CovidDeaths
WHERE continent is not NULL GROUP BY continent ORDER BY deathcount desc;

--global numbers

SELECT SUM(new_cases) AS CASES, SUM(CAST(new_deaths AS INT)) AS DEATHS, SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 AS deathperc 
FROM CovidDeaths
WHERE continent is not null ORDER BY 1,2;

SELECT * FROM CovidDeaths AS DEA JOIN CovidVaccinations AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date;

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
FROM CovidDeaths AS DEA 
JOIN CovidVaccinations AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date 
WHERE DEA.continent IS NOT NULL ORDER BY 2,3;

SELECT * FROM CovidDeaths ORDER BY 3,4;

SELECT location, MAX(Total_deaths) as deathcount 
FROM CovidDeaths WHERE location is not NULL GROUP BY location ORDER BY deathcount desc;

--showing the continent with highest deathcount

SELECT continent, MAX(Total_deaths) as deathcount 
FROM CovidDeaths WHERE continent is not NULL GROUP BY continent ORDER BY deathcount desc;

--global numbers

SELECT SUM(new_cases) AS CASES, SUM(CAST(new_deaths AS INT)) AS DEATHS,
SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 AS deathperc 
FROM CovidDeaths WHERE continent is not null ORDER BY 1,2;

SELECT * FROM CovidDeaths AS DEA JOIN CovidVaccinations AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date;

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM CovidDeaths AS DEA 
JOIN CovidVaccinations AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date WHERE DEA.continent IS NOT NULL ORDER BY 2,3;

SELECT * FROM CovidDeaths ORDER BY 3,4;

SELECT location, MAX(Total_deaths) as deathcount 
FROM CovidDeaths
WHERE location is not NULL GROUP BY location ORDER BY deathcount desc;

--showing the continent with highest deathcount

SELECT continent, MAX(Total_deaths) as deathcount 
FROM CovidDeaths 
WHERE continent is not NULL GROUP BY continent ORDER BY deathcount desc;

--global numbers

SELECT SUM(new_cases) AS CASES, SUM(CAST(new_deaths AS INT)) AS DEATHS, SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 AS deathperc 
FROM CovidDeaths WHERE continent is not null ORDER BY 1,2;

SELECT * FROM [Covid Deaths] AS DEA JOIN [Covid Vaccinations] AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date;

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
FROM CovidDeaths AS DEA 
JOIN CovidVaccinations AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date WHERE DEA.continent IS NOT NULL ORDER BY 2,3;


WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) AS 
( SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(Cast(VAC.new_vaccinations as int)) 
OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS rollingpeoplevaccinated 
FROM CovidDeaths AS DEA 
JOIN CovidVaccinations AS VAC ON DEA.location = VAC.location AND DEA.date = VAC.date WHERE DEA.continent IS NOT NULL ) 
SELECT *, (rollingpeoplevaccinated/population)*100 FROM popvsvac

--TEMP TABLE

DROP TABLE IF EXISTS #PERCPOPVAC CREATE TABLE #PERCPOPVAC ( continent NVARCHAR (255), location NVARCHAR (255), 
date datetime, population numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric )
INSERT INTO #PERCPOPVAC SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT (INT, VAC.new_vaccinations )) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.Date) AS rollingpeoplevaccinated 
FROM CovidDeaths DEA JOIN CovidVaccinations VAC ON DEA.location = VAC.location AND DEA.date = VAC.date

SELECT *, (rollingpeoplevaccinated/population)*100 FROM #PERCPOPVAC;

--CREATE VEIWS

CREATE VIEW percpopvac AS 
SELECT 
    DEA.continent, 
    DEA.location, 
    DEA.date, 
    DEA.population, 
    VAC.new_vaccinations, 
    SUM(COALESCE(CAST(VAC.new_vaccinations AS INT), 0)) 
    OVER (PARTITION BY DEA.Location ORDER BY DEA.Date) AS rollingpeoplevaccinated
FROM CovidDeaths AS DEA 
JOIN CovidVaccinations AS VAC 
    ON DEA.location = VAC.location 
    AND DEA.date = VAC.date 
WHERE DEA.continent IS NOT NULL;



SELECT *
FROM percpopvac;


CREATE VIEW TotalDeathCount AS
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
;

CREATE VIEW DeathPercentage AS
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL 
        ELSE SUM(CAST(new_deaths AS INT)) * 100.0 / SUM(new_cases) 
    END AS DeathPercentage
FROM [Covid 19]..CovidDeaths
WHERE continent IS NOT NULL;

CREATE VIEW HighestInfectionCount_Vs_PercentPopulationInfected AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population;


CREATE VIEW HighestInfectionCount_ AS
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population, date;

Create View PeopleVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population;
