/*
Exploring Covid 19 Dataset

The Dataset is found in https://ourworldindata.org/covid-deaths 

Skills showcased: Joins, Aggregate functions, Window Functions

*/

SELECT * 
FROM Covid_Data..Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 3,4

-- Data that this project focuses on

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Data..Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 1, 2

-- Total Cases vs Population
--- Shows the percentage of people who contracted COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS TestedPositive_Percentage
FROM Covid_Data..Covid_Deaths
WHERE location = 'United Kingdom' 
and continent is NOT NULL
ORDER BY 1, 2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM Covid_Data..Covid_Deaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

-- Total Cases vs Total Deaths
--- Shows the dying percentage rate if contracted COVID 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Data..Covid_Deaths
WHERE location = 'United Kingdom'
and continent is NOT NULL
ORDER BY 1, 2

-- Countries with Highest Death percentage compared to population

SELECT location, population, MAX(CAST(total_deaths AS int)) AS total_deaths, MAX((total_deaths/population))*100 AS death_percentage
FROM Covid_Data..Covid_Deaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY death_Percentage DESC

-- Continents with Highest Death Count

SELECT location AS continents, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM Covid_Data..Covid_Deaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC

-- Countries with Highest Death Count 

SELECT location, population, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM Covid_Data..Covid_Deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY total_death_count DESC

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Data..Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 1, 2

--SELECT *
--FROM Covid_Data..Covid_Vaccinations
--WHERE continent is NOT NULL

-- Total Population vs Vaccinated (Joins)

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location,
	D.Date) as rolling_people_vaccinated
-- (rolling_people_vaccinated/population)*100
FROM Covid_Data..Covid_Deaths AS D
JOIN Covid_Data..Covid_Vaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is NOT NULL
ORDER BY 2,3

-- Total Population vs Vaccinated (CTE)

With Pop_Vs_Vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location,
	D.Date) as rolling_people_vaccinated
--- (rolling_people_vaccinated/population)*100
FROM Covid_Data..Covid_Deaths AS D
JOIN Covid_Data..Covid_Vaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is NOT NULL
---ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 
FROM Pop_Vs_Vac

-- Temp Table

DROP TABLE if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location,
	D.Date) as rolling_people_vaccinated
-- (rolling_people_vaccinated/population)*100
FROM Covid_Data..Covid_Deaths AS D
JOIN Covid_Data..Covid_Vaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


-- Views

CREATE VIEW percent_population_vaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.location ORDER BY D.location,
	D.Date) as rolling_people_vaccinated
-- (rolling_people_vaccinated/population)*100
FROM Covid_Data..Covid_Deaths AS D
JOIN Covid_Data..Covid_Vaccinations AS V
	ON D.location = V.location
	and D.date = V.date
WHERE D.continent is NOT NULL

SELECT * 
FROM percent_population_vaccinated