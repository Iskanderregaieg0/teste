CREATE TABLE dim_region (
    idlocation INT,
    name STRING,
    city STRING,
    continent STRING,
    postalcoderange STRING,
    address STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (idlocation) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_region',
    'username' = 'postgres',
    'password' = 'postgres'
);

CREATE TABLE dim_level_education (
    id INT,
    description STRING,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_level_education',
    'username' = 'postgres',
    'password' = 'postgres'
);


CREATE TABLE dim_candidate_source (
    id INT,
    topleveleducation STRING,
    name STRING,
    city STRING,
    continent STRING,
    first_name STRING,
    last_name STRING,
    birthdate INT,
    gender STRING,
    phone_number STRING,
    email STRING,
    linkedin STRING,
    statut_professionnel STRING,
    mobilite BOOLEAN,
       
    created_at TIMESTAMP(3),
    updated_at TIMESTAMP(3),
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_dim_candidate.public.candidate',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);




CREATE TABLE dim_candidate_sink (
    id INT,
    id_topleveleducation INT,
    idlocation INT,
    Fullname STRING, 
    birthdate DATE,
    gender STRING,
    phone_number STRING,
    email STRING,
    linkedin STRING,
    statut_professionnel STRING,
    mobilite BOOLEAN,

    created_at DATE,
    updated_at DATE,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_candidate',
    'username' = 'postgres',
    'password' = 'postgres'
);

INSERT INTO dim_candidate_sink
SELECT
    c.id,
    le.id AS id_topleveleducation,
    r.idlocation AS idlocation,
    CONCAT(c.first_name, ' ', c.last_name) AS fullname,
    TO_DATE(FROM_UNIXTIME(CAST(c.birthdate AS BIGINT) * 86400)) as birthdate ,
     CASE 
        WHEN c.gender = 'f' THEN 'Female'
        WHEN c.gender = 'F' THEN 'Female'
        WHEN c.gender = 'female' THEN 'Female'
        WHEN c.gender = 'M' THEN 'Male'
        WHEN c.gender = 'm' THEN 'Male'
        WHEN c.gender = 'male' THEN 'Male'
        ELSE 'Other'
    END AS gender,
    c.phone_number,
    c.email ,
    c.linkedin ,
    c.statut_professionnel,
    c.mobilite,
TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(c.created_at AS STRING)))) AS created_at,
TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(c.updated_at AS STRING)))) AS updated_at,



    c.__deleted,
    c.__op,
    c.__source_ts_ms
FROM dim_candidate_source c
LEFT JOIN dim_level_education le
  ON LOWER(TRIM(c.topleveleducation)) = LOWER(TRIM(le.description))
LEFT JOIN dim_region r
  ON LOWER(TRIM(c.name)) = LOWER(TRIM(r.name))
 AND LOWER(TRIM(c.city)) = LOWER(TRIM(r.city))
 AND LOWER(TRIM(c.continent)) = LOWER(TRIM(r.continent))
WHERE c.id IS NOT NULL;

