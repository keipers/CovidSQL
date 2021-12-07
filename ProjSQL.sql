SELECT continent, location, MAX(Cast(total_cases as int)) MaxCases, MAX((cast(total_cases as int)/population)) * 100 CasesperPop
FROM CovidDeaths
WHERE continent is not null or location is not null
group by continent, location
order by location



--GLOBAL NUMBERS

SELECT date, SUM(new_cases) nc, SUM(CAST(new_deaths as int)) nd, SUM(CAST(new_deaths as int))/SUM(new_cases)  * 100 DeathePercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date;

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (Partition by CD.location order BY CD.location, CD.date ) AS RollVac
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent is not NULL --AND CV.new_vaccinations is not null
ORDER BY CD.location, CD.date;


--Use CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollVac
)
AS(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (Partition by CD.location order BY CD.location, CD.date ) AS RollVac
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent is not NULL)


SELECT *, RollVac/population * 100 VacPer
FROM
PopvsVac


---View of data

CREATE View vwPerPopVaccinated as
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(bigint, CV.new_vaccinations)) OVER (Partition by CD.location order BY CD.location, CD.date ) AS RollVac
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent is not NULL
