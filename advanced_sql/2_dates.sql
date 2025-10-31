/*
    Write a query to find companies (include company name) that 
    have posted jobs offering health insurance, where those 
    postings were made in the second quarter of 2023. 
    Use date extraction to filter by quarter.
*/

SELECT DISTINCT
    jobs.job_id,
    jobs.job_health_insurance,
    companies.name
FROM
    job_postings_fact AS jobs
LEFT JOIN
    company_dim AS companies
    ON jobs.company_id = companies.company_id
WHERE
    job_health_insurance = true AND
    EXTRACT(QUARTER FROM job_posted_date) = 2 AND
    EXTRACT(YEAR FROM job_posted_date) = 2023