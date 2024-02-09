
USE PROJECT;

--SELECT *
--FROM [Covid Deaths]
--ORDER BY 3,4;

--SELECT *
--FROM [Covid Vaccinations]
--ORDER BY 3,4;

--SELECT DATA THA WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Deaths]
ORDER BY 1,2;

--LOOKING OUT TOTAL CASES AND TOTAL DEATHS
--shows the likelihood of death in your country

SELECT Location, date, total_cases, total_deaths
FROM [Covid Deaths]
WHERE Location LIKE '%states%'
ORDER BY 1,2;

--looking at total cases vs population

SELECT Location, date, total_cases, population,  (total_cases/population)*100 as deathperc
FROM [Covid Deaths]
WHERE Location LIKE '%states%'
ORDER BY 1,2;

--looking at countries with hihest infection rate compare to population

SELECT Location,population, MAX(total_cases) AS HIGHESTCOUNT,  MAX((total_cases/population))*100 as POPULATIONINFECTED
FROM [Covid Deaths]
--WHERE Location LIKE '%states%'--
GROUP BY location, population
ORDER BY POPULATIONINFECTED DESC;

--SHOWING COUNTRIES HIGHEST DEATH COUNT

SELECT Location, MAX(total_deaths) AS HIGHESTCOUNT
FROM [Covid Deaths]
--WHERE Location LIKE '%states%'--
GROUP BY location
ORDER BY HIGHESTCOUNT DESC;

SELECT *
FROM [Covid Deaths]
ORDER BY 3,4;

SELECT location, MAX(Total_deaths) as deathcount
FROM [Covid Deaths]
WHERE location is not NULL
GROUP BY  location
ORDER BY deathcount desc;

--showing the continent with highest deathcount

SELECT continent, MAX(Total_deaths) as deathcount
FROM [Covid Deaths]
WHERE continent is not NULL
GROUP BY  continent
ORDER BY deathcount desc;

--global numbers

SELECT SUM(new_cases) AS CASES, SUM(CAST(new_deaths AS INT)) AS DEATHS, SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 AS deathperc 
FROM [Covid Deaths]
WHERE continent is not null
ORDER BY 1,2;

SELECT *
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date;

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3;


SELECT *
FROM [Covid Deaths]
ORDER BY 3,4;

SELECT location, MAX(Total_deaths) as deathcount
FROM [Covid Deaths]
WHERE location is not NULL
GROUP BY  location
ORDER BY deathcount desc;

--showing the continent with highest deathcount

SELECT continent, MAX(Total_deaths) as deathcount
FROM [Covid Deaths]
WHERE continent is not NULL
GROUP BY  continent
ORDER BY deathcount desc;

--global numbers

SELECT SUM(new_cases) AS CASES, SUM(CAST(new_deaths AS INT)) AS DEATHS, SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 AS deathperc 
FROM [Covid Deaths]
WHERE continent is not null
ORDER BY 1,2;

SELECT *
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date;

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3;

SELECT *
FROM [Covid Deaths]
ORDER BY 3,4;

SELECT location, MAX(Total_deaths) as deathcount
FROM [Covid Deaths]
WHERE location is not NULL
GROUP BY  location
ORDER BY deathcount desc;

--showing the continent with highest deathcount

SELECT continent, MAX(Total_deaths) as deathcount
FROM [Covid Deaths]
WHERE continent is not NULL
GROUP BY  continent
ORDER BY deathcount desc;

--global numbers

SELECT SUM(new_cases) AS CASES, SUM(CAST(new_deaths AS INT)) AS DEATHS, SUM(new_deaths)/SUM(CAST(new_cases AS INT))*100 AS deathperc 
FROM [Covid Deaths]
WHERE continent is not null
ORDER BY 1,2;

SELECT *
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date;

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3;

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(Cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.Date) AS rollingpeoplevaccinated
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac

--TEMP TABLE


DROP TABLE IF EXISTS #PERCPOPVAC
CREATE TABLE #PERCPOPVAC
(
continent NVARCHAR (255),
location NVARCHAR (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
) 
INSERT INTO #PERCPOPVAC
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT (INT, VAC.new_vaccinations )) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.Date) AS rollingpeoplevaccinated
FROM [Covid Deaths]  DEA
JOIN [Covid Vaccinations]  VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date

SELECT *,  (rollingpeoplevaccinated/population)*100
FROM #PERCPOPVAC;

--CREATE VEIWS

CREATE VIEW percpopvac AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(Cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.Date) AS rollingpeoplevaccinated
FROM [Covid Deaths] AS DEA
JOIN [Covid Vaccinations] AS VAC
  ON DEA.location = VAC.location
  AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
