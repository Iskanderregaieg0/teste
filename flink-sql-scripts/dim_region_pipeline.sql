
CREATE TABLE dim_region_source (
    idlocation INT,
    name STRING,
    city STRING,
    continent STRING,
    postalcoderange STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_dim_region.public.region',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);
CREATE TABLE dim_region_sink (
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
INSERT INTO dim_region_sink
SELECT
    idlocation,
    name,
    city,
    continent,
    postalcoderange,

    -- Génère l'adresse : name, city, continent
    CONCAT(name, ', ', city, ', ', postalcoderange) AS address,

    __deleted,
    __op,
    __source_ts_ms
FROM dim_region_source
WHERE idlocation IS NOT NULL;
