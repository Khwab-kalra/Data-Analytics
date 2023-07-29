USE hr_analytics;
SELECT * FROM hr;
ALTER TABLE hr
CHANGE COLUMN ï»¿id id VARCHAR(32) NULL;

DESCRIBE hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;
SELECT birthdate FROM hr;

select hr.hire_date from hr
WHERE hire_date LIKE '%-%-%';

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
SELECT hire_date FROM hr;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;
SELECT termdate from hr;
SET sql_mode = 'ALLOW_INVALID_DATES';
ALTER TABLE hr
MODIFY COLUMN termdate DATE;
SELECT termdate FROM hr;

ALTER TABLE hr ADD COLUMN age INT;
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());
SELECT age FROM hr
order by age;


-- 1.what is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP By gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) as c FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY c DESC;

-- 3. What is the age distribution of employees in the company?
SELECT
	min(age) AS youngest,
    max(age) as Oldest
    FROM hr
    WHERE age>=18 AND termdate = '0000-00-00';
    
SELECT
	CASE
    WHEN age>=18 and age<=24 THEN '18-24'
    WHEN age>=25 and age<=34 THEN '25-34'
    WHEN age>=35 and age<=44 THEN '35-44'
    WHEN age>=45 and age<=54 THEN '45-54'
    WHEN age>=55 and age<=64 THEN '55-64'
    ELSE '65+'
    END AS age_group,
    count(*) AS c
    FROM hr
    WHERE age>=18 AND termdate = '0000-00-00'
    GROUP BY age_group
    ORDER BY age_group;
    SELECT age_group from hr;
    
     
SELECT
	CASE
    WHEN age>=18 and age<=24 THEN '18-24'
    WHEN age>=25 and age<=34 THEN '25-34'
    WHEN age>=35 and age<=44 THEN '35-44'
    WHEN age>=45 and age<=54 THEN '45-54'
    WHEN age>=55 and age<=64 THEN '55-64'
    ELSE '65+'
    END AS age_group, gender,
    count(*) AS c
    FROM hr
    WHERE age>=18 AND termdate = '0000-00-00'
    GROUP BY age_group, gender
    ORDER BY age_group, gender;
    
-- 4. How many employees work at headquarters versus remote locations?

SELECT location, count(*) AS c
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
round(avg(datediff(termdate, hire_date))/365,2) AS avg_emp_length
FROM hr
WHERE age>=18 AND termdate <> '0000-00-00' AND termdate<=curdate();
-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS c
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department, gender;


-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) as c
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 8. Which department has the highest turnover rate?
SELECT department, total_count, terminated_count, terminated_count/total_count AS termination_rate
FROM(
	SELECT department, count(*) as total_count,
    SUM(CASE WHEN termdate <>'0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
	WHERE age>=18
    GROUP BY department
    )AS sq
ORDER BY termination_rate DESC;
  

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, count(*) AS count
FROM hr
WHERE age>=18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
	year, hires, terminations,
    (hires-terminations) AS net_change,
    round((hires-terminations)/hires*100,2) AS net_Percent_change
FROM(
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
	FROM hr
	WHERE age>=18
	GROUP BY YEAR(hire_date)
    )AS sq
ORDER BY YEAR ASC;


-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365), 2) as avg_tenure
FROM hr
WHERE termdate<= curdate() AND termdate<> '0000-00-00' AND age>=18
GROUP BY department;

SELECT age, department, jobtitle, count(*) AS c
FROM hr
WHERE age>=18 AND age<=30
GROUP BY department
ORDER BY c DESC ;

