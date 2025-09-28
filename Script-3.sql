CREATE TABLE universities (
    university TEXT,
    coord TEXT,
    inception TEXT,
    universityLabel text,
    countryLabel text
);
ALTER TABLE universities 
ALTER COLUMN universityLabel TYPE VARCHAR(128);


select * from universities u 


 --Count how many universities per countryLabel
select countryLabel,count(*) as total_universities
from universities 
group by countryLabel

--Find all universities founded before 1900

SELECT inception
FROM universities
WHERE CAST(SUBSTRING(NULLIF(inception,'') ,1,4) AS INT) < 1900;


--Order universities by inception descending

SELECT *
FROM universities
WHERE inception IS NOT NULL       -- NULL চেক
  AND inception <> ''             -- খালি স্ট্রিং চেক
  AND inception ~ '^[0-9]{4}'    -- প্রথম ৪ অঙ্ক numeric কি না চেক
ORDER BY LEFT(inception, 4)::INT DESC;  -- descending order

--  Universities whose name contains 'University'
SELECT *
FROM universities
WHERE universityLabel LIKE '%University%';

-- First 5 universities from Italy
SELECT *
FROM universities
WHERE countryLabel = 'Italy'
LIMIT 5;

--  Display universities with missing coordinates
SELECT *
FROM universities
WHERE coord IS NULL OR coord = '';



--🟩 2 Intermediate-Level Solution


--Group by countryLabel and show average foundation year of universities

select countryLabel,
AVG(cast(SUBSTRING(inception,1,4)as int) as avg_foundation_year
from universities
group by countryLabel


-- 2. Top 3 oldest universities per country
SELECT universityLabel, countryLabel, inception
FROM (
  SELECT universityLabel,
         countryLabel,
         inception,
         ROW_NUMBER() OVER (
           PARTITION BY countryLabel
           ORDER BY CAST(SUBSTRING(NULLIF(inception,'') FROM 1 FOR 4) AS INT)
         ) AS rn
  FROM universities
  WHERE inception ~ '^[0-9]{4}'   -- প্রথম ৪টি অঙ্ক সংখ্যা কিনা চেক
) t
WHERE rn <= 3;

--  Count universities founded between 1950 and 2000 per country
SELECT countryLabel,
       COUNT(*) AS total_universities
FROM universities
WHERE inception ~ '^[0-9]{4}'   
  AND CAST(SUBSTRING(inception FROM 1 FOR 4) AS INT) BETWEEN 1950 AND 2000
GROUP BY countryLabel;

--Create a CASE column classifying universities:‘Ancient’ (<1900),‘Modern’ (1900–2000),‘Contemporary’ (>2000).

SELECT universityLabel,
       CASE
         WHEN LEFT(inception,4)::INT < 1900 THEN 'Ancient'
         WHEN LEFT(inception,4)::INT BETWEEN 1900 AND 2000 THEN 'Modern'
         ELSE 'Contemporary'
       END AS era
FROM universities
WHERE inception ~ '^[0-9]{4}'; 

-- 5. Countries with more than 5 universities
SELECT countryLabel
FROM universities
GROUP BY countryLabel
HAVING COUNT(*) > 5;

--Using a subquery, find universities older than the average inception year of their country.

select *
from universities u
where cast(substring(inception,1,4)as int)<
(select avg(cast (substring(inception,1,4)sd int))
from universiries
where countrylabel =u.u.countrylabel );

--Extract the latitude and longitude separately from the coord column.
SELECT universityLabel,
       countryLabel,
       CAST(NULLIF(split_part(replace(replace(coord,'Point(',''),')',''),' ',1), '') AS DECIMAL(9,6)) AS latitude,
       CAST(NULLIF(split_part(replace(replace(coord,'Point(',''),')',''),' ',2), '') AS DECIMAL(9,6)) AS longitude
FROM universities;

-- 8. Rank universities per country by founding year

SELECT universityLabel,
       countryLabel,
       inception,
       RANK() OVER (
         PARTITION BY countryLabel
         ORDER BY CAST(SUBSTRING(NULLIF(inception,'') FROM 1 FOR 4) AS INT)
       ) AS rank_in_country
FROM universities
WHERE inception ~ '^[0-9]{4}';


-- Cumulative count of universities per country ordered by inception
SELECT universityLabel,
       countryLabel,
       inception,
       COUNT(*) OVER (
         PARTITION BY countryLabel
         ORDER BY CAST(SUBSTRING(NULLIF(inception,'') FROM 1 FOR 4) AS INT)
       ) AS cumulative_count
FROM universities
WHERE inception ~ '^[0-9]{4}';


-- 10. Create a view summarizing each country
CREATE VIEW country_summary AS
SELECT countryLabel,
       COUNT(*) AS total_universities,
       MIN(CAST(SUBSTRING(inception,1,4) AS INT)) AS earliest_inception,
       MAX(CAST(SUBSTRING(inception,1,4) AS INT)) AS latest_inception
FROM universities            
GROUP BY countryLabel


---3 Advanced / Analytical-Level Solutions

--  CTE: oldest university per country

WITH oldest AS (
  SELECT countryLabel,
         universityLabel,
         inception,
         ROW_NUMBER() OVER (
           PARTITION BY countryLabel
           ORDER BY CAST(SUBSTRING(NULLIF(inception,'') FROM 1 FOR 4) AS INT)
         ) AS rn
  FROM universities
  WHERE inception ~ '^[0-9]{4}'
)
SELECT countryLabel, universityLabel, inception
FROM oldest
WHERE rn = 1;

-- Median founding year per country (PostgreSQL syntax)
SELECT countryLabel,
       PERCENTILE_CONT(0.5) 
         WITHIN GROUP (ORDER BY LEFT(inception,4)::INT) AS median_year
FROM universities
WHERE inception ~ '^[0-9]{4}' 
GROUP BY countryLabel;

--  Top 10% oldest universities globally
SELECT *
FROM (
  SELECT *,
         NTILE(10) OVER (
           ORDER BY LEFT(inception,4)::INT
         ) AS decile
  FROM universities
  WHERE inception ~ '^[0-9]{4}'
) t
WHERE decile = 1;

--  Pivot the dataset to show counts of universities founded in each century per country.
SELECT countryLabel,
       SUM(CASE WHEN LEFT(inception,4)::INT < 1800 THEN 1 ELSE 0 END) AS before_1800,
       SUM(CASE WHEN LEFT(inception,4)::INT BETWEEN 1800 AND 1899 THEN 1 ELSE 0 END) AS "1800s",
       SUM(CASE WHEN LEFT(inception,4)::INT BETWEEN 1900 AND 1999 THEN 1 ELSE 0 END) AS "1900s",
       SUM(CASE WHEN LEFT(inception,4)::INT >= 2000 THEN 1 ELSE 0 END) AS "2000s"
FROM universities
WHERE inception ~ '^[0-9]{4}'
GROUP BY countryLabel;


--  Countries where >50% universities founded after 2000

WITH valid AS (
  SELECT countryLabel, LEFT(inception,4)::INT AS year
  FROM universities
  WHERE inception ~ '^[0-9]{4}'   -- শুধু valid ৪ অঙ্কের বছর
)
SELECT countryLabel
FROM valid
GROUP BY countryLabel
HAVING SUM(CASE WHEN year > 2000 THEN 1 ELSE 0 END)::float 
       / COUNT(*) > 0.5;


-- Correlation between latitude and founding year (conceptual)

WITH coords AS (
  SELECT 
    LEFT(inception,4)::INT AS year,
    CAST(NULLIF(split_part(replace(replace(coord,'Point(',''),')',''),' ',2),'') AS DECIMAL(9,6)) AS latitude
  FROM universities
  WHERE inception ~ '^[0-9]{4}'    -- শুধু ৪ অঙ্কের valid বছর
)
SELECT CORR(latitude, year) AS corr_latitude_year
FROM coords;


-- 7. Age of each university
SELECT universityLabel, countryLabel,
       EXTRACT(YEAR FROM CURRENT_DATE) - CAST(SUBSTRING(inception,1,4) AS INT) AS age_years
FROM universities;

-- Categorize universities into “Global Old Guard” if before 1800, “Modern Era” if between 1800 and 1950, “Recent Era” otherwise.
SELECT universityLabel,
       CASE
         WHEN LEFT(inception,4)::INT < 1800 THEN 'Global Old Guard'
         WHEN LEFT(inception,4)::INT BETWEEN 1800 AND 1950 THEN 'Modern Era'
         ELSE 'Recent Era'
       END AS category
FROM universities
WHERE inception ~ '^[0-9]{4}';


--  Ranking countries by average age of universities
WITH ages AS (
  SELECT countryLabel,
         EXTRACT(YEAR FROM CURRENT_DATE) - LEFT(inception,4)::INT AS age
  FROM universities
  WHERE inception ~ '^[0-9]{4}' 
),
avg_ages AS (
  SELECT countryLabel,
         AVG(age) AS avg_age
  FROM ages
  GROUP BY countryLabel
)
SELECT countryLabel,
       avg_age,
       RANK() OVER (ORDER BY avg_age DESC) AS country_rank
FROM avg_ages;


-- Create a composite score combining “age” and “latitude” (just for analytical exercise
SELECT universityLabel,
       (EXTRACT(YEAR FROM CURRENT_DATE) - LEFT(inception,4)::INT) 
       * CAST(NULLIF(split_part(replace(replace(coord,'Point(',''),')',''),' ',2),'') AS DECIMAL(9,6)) 
       AS composite_score
FROM universities
WHERE inception ~ '^[0-9]{4}'
  AND coord IS NOT NULL
ORDER BY composite_score DESC;

