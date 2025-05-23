-- fichier: dim_job_pipeline.sql

CREATE TABLE dim_job_source (
    id INT,
    id_company_details  INT,
    titre STRING,
    type_emploi  STRING,
    date_de_publication INT,
    date_expiration INT,
    status STRING,
    salaire_min INT,
    salaire_max INT,
    nb_experience_min INT,
    seniorite STRING,
    lieu_travail  STRING,
    disponibilite STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_dim_job.public.job',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);

CREATE TABLE dim_job_sink (
    id INT,
    id_company_details  INT,
    titre STRING,
    type_emploi  STRING,
    date_de_publication DATE,
    date_expiration DATE,
    status STRING,
    salaire_min INT,
    salaire_max INT,
    nb_experience_min INT,
    seniorite STRING,
    lieu_travail  STRING,
    disponibilite STRING,
    range_salaire STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT,
     PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_jobs',
    'username' = 'postgres',
    'password' = 'postgres'
);

INSERT INTO dim_job_sink
SELECT
    id,
    id_company_details,
    titre,
    type_emploi,
    TO_DATE(FROM_UNIXTIME(CAST(date_de_publication AS BIGINT) * 86400)) AS date_de_publication,
    TO_DATE(FROM_UNIXTIME(CAST(date_expiration AS BIGINT) * 86400)) AS date_expiration,
    status,
    salaire_min,
    salaire_max,
    nb_experience_min,
    seniorite,
    lieu_travail,
    disponibilite,
    CONCAT(CAST(salaire_min AS STRING), '€ - ', CAST(salaire_max AS STRING), '€') AS range_salaire,
    __deleted,
    __op,
    __source_ts_ms
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY id ORDER BY __source_ts_ms DESC) AS row_num
    FROM dim_job_source
)
WHERE row_num = 1;



