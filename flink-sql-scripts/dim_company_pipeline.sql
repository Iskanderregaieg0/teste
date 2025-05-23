CREATE TABLE dim_company_source (
    id INT,
    id_secteur INT,
    name STRING,
    location STRING,
    country STRING,
    size STRING,
    website STRING,
    phone_number STRING,
    employee_count INT,
    company_size STRING,
    headquarters STRING,
    founded_year INT,
    specializations STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_dim_company.public.company',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);



CREATE TABLE dim_company_sink (
    id INT,
    id_secteur INT,
    name STRING,
    location STRING,
    country STRING,
    size STRING,
    website STRING,
    phone_number STRING,
    employee_count INT,
    company_size STRING,
    headquarters STRING,
    founded_year INT,
    specializations STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_company',
    'username' = 'postgres',
    'password' = 'postgres'
);


INSERT INTO dim_company_sink
SELECT
    id,
    id_secteur,
    name,
    location,
    country,
    size,
    website,
    phone_number,
    employee_count,
    company_size,
    headquarters,
    founded_year,
    specializations,
    __deleted,
    __op,
    __source_ts_ms
FROM dim_company_source
WHERE id IS NOT NULL;
