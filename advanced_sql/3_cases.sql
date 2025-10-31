/*
    Label new column as follows:
    - 'Anywhere' jobs as 'Remote'
    - 'New York, NY' jobs as 'Local'
    - Otherwise 'Onsite'
*/

SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category
LIMIT 10

/*
    I want to categorize the salaries from each job posting. 
    To see if it fits in my desired salary range.

    - Put salary into different buckets.
    - Define what’s a high, standard, or low salary with 
    our own conditions.
    - Why? It is easy to determine which job postings are 
    worth looking at based on salary. Bucketing is a common 
    practice in data analysis when viewing categories.
    - I only want to look at data analyst roles.
    - Order from highest to lowest.
*/

SELECT
    job_title_short,
    salary_year_avg,
    CASE
        WHEN salary_year_avg > 150000 THEN 'High salary'
        WHEN salary_year_avg > 75000 THEN 'Standard salary'
        ELSE 'Low salary'
    END AS salary_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC

SELECT *
FROM ( -- Subquery starts here
	SELECT *
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs
-- Subquery ends here

WITH january_jobs AS ( -- CTE definition starts here
	SELECT *
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) -- CTE definition ends here

SELECT *
FROM
	january_jobs;

-- Subquery
SELECT 
    company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN (
    SELECT 
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
    ORDER BY
        company_id
)

/*
    Find the companies that have the most job openings.
    - Get the total number of job postings per 
    company id (job_postings_fact).
    - Return the total number of jobs with the 
    company name (company_dim).
*/

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*)
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT *
FROM
    company_job_count;

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT
    name AS company_name,
    company_job_count.total_jobs
FROM
    company_dim
LEFT JOIN
    company_job_count
    ON company_job_count.company_id = company_dim.company_id
ORDER BY
    company_job_count.total_jobs DESC

/*
    Identify the top 5 skills that are most frequently mentioned 
    in job postings. Use a subquery to find the skill IDs 
    with the highest counts in the skills_job_dim table and then 
    join this result with the skills_dim table to get 
    the skills names.
*/

SELECT
    skills_dim.skills,
    skill_count.skill_count
FROM
    skills_dim
INNER JOIN (
        SELECT
            skill_id,
            COUNT(*) AS skill_count
        FROM
            skills_job_dim
        GROUP BY
            skill_id
        LIMIT 5
    ) AS skill_count
    ON skill_count.skill_id = skills_dim.skill_id
ORDER BY
    skill_count DESC

/*
    Determine the size category (’Small’, ‘Medium’, or ‘Large’) 
    for each company by first identifying the number of job 
    postings they have. Use a subquery to calculate the total 
    job postings per company. A company is considered ‘Small’ 
    if it is less than 10 job postings, ‘Medium’ if the number of 
    job postings is between 10 and 50, and ‘Large’ if it 
    has more than 50 job postings. Implement a subquery to aggregate 
    job counts per company before classifying them based on size.
*/

SELECT
    c.name AS company_name,
    company_postings_count.company_postings_count,
    CASE
        WHEN company_postings_count > 50 THEN 'Large'
        WHEN company_postings_count <= 50 AND
        company_postings_count >= 10 THEN 'Medium'
        ELSE 'Small'
    END AS size_category
FROM
    company_dim AS c
INNER JOIN
    (
        SELECT
            company_id,
            COUNT(*) AS company_postings_count
        FROM
            job_postings_fact
        GROUP BY
            company_id
    ) AS company_postings_count
    ON company_postings_count.company_id = c.company_id
ORDER BY
    company_postings_count DESC

/*
    Find the count of the number of remote job postings per skill.
    - Display the top 5 skills by their demand in remote jobs.
    - Include skill ID, name, and count of postings requiring 
    the skill.
*/

WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN
        job_postings_fact AS job_postings
        ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = true
    GROUP BY
        skill_id
)

SELECT
    skill.skill_id,
    skill.skills,
    skill_count
FROM
    remote_job_skills
INNER JOIN
    skills_dim AS skill
    ON skill.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5