SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs

/*
    Get the corresponding skill and skill type for each 
    job posting in Q1. Include those without any skills, too. 
    Why? Look at the skills and the type for each job in the 
    first quarter that has a salary > $70,000.
*/

SELECT
    job_title_short,
    salary_year_avg,
    skills,
    type
FROM (
    SELECT *
    FROM
        january_jobs
    UNION ALL
    SELECT *
    FROM
        february_jobs
    UNION ALL
    SELECT *
    FROM
        march_jobs
) AS job_postings_q1
LEFT JOIN
    skills_job_dim
    ON skills_job_dim.job_id = job_postings_q1.job_id
LEFT JOIN
    skills_dim
    ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE
    salary_year_avg > 70000
ORDER BY
    salary_year_avg DESC

/*
    Find job postings from the first quarter that have a salary greater than $70k. 
    Combine job posting tables from the first quarter of 2023 (Jan - Mar). 
    Get job postings with an average yearly salary > $70,000.
*/

SELECT
    job_title_short,
    job_location,
    job_via,
    job_posted_date::DATE,
    salary_year_avg
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    salary_year_avg > 70000 AND
    job_title_short = 'Data Analyst'
ORDER BY
    salary_hour_avg DESC