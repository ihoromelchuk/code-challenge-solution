
-- 4. Develop the SQL to define a dimensional model schema for this data. (rationale behind my design choice is in the jupyter notebook)

--    the code below uses PostgreSQL dialect

--    companies table
CREATE TABLE companies (
  id integer PRIMARY KEY,
  company_name varchar,
  number_of_employees integer,
  establishment_date timestamp
);

--    locations table
CREATE TABLE locations (
  zip_code integer PRIMARY KEY,
  location_name varchar
);

--    jobs table
CREATE TABLE jobs (
  id integer PRIMARY KEY,
  current_state varchar,
  zip integer,
  price decimal,
  company_id integer,
  posted_at timestamp,
  expired_at timestamp,
  FOREIGN KEY (company_id) REFERENCES companies(id),
  FOREIGN KEY (zip) REFERENCES locations(zip_code)
);

-- job_states_history table
CREATE TABLE job_states_history (
  event_id integer PRIMARY KEY,
  job_id integer,
  event_type varchar,
  event_date timestamp,
  FOREIGN KEY (job_id) REFERENCES jobs(id)
);

-- 5.Using your dimensional model, write a SQL query that returns a list of jobs for each company, ordered and enumerated within each group by the posted_at date.

SELECT
    j.company_id,
    c.company_name,
    j.id,
    ROW_NUMBER() OVER (PARTITION BY j.company_id ORDER BY j.posted_at ASC) AS row_num
FROM
    jobs j
LEFT JOIN
    companies c ON j.company_id = c.id
ORDER BY 1,2,4;


-- 6. Discuss how you would obtain and model information (within your schema) about the duration of jobs (from posted to expired states).

SELECT 
    DATE_PART('day', COALESCE(expired_at, CURRENT_TIMESTAMP) -  posted_at) AS days_since_posted
FROM 
    jobs