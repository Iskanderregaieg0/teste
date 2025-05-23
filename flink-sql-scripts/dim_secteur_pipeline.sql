CREATE TABLE dim_secteur_source (
      id_secteur INT,
    name STRING,
    code STRING,
     description STRING,
     __deleted STRING,
     __op STRING,
      __source_ts_ms BIGINT
  ) WITH (
      'connector' = 'kafka',
      'topic' = 'userprofile_dim_secteur.public.secteur',
      'properties.bootstrap.servers' = 'kafka:9092',
      'properties.group.id' = 'flink-group',
      'scan.startup.mode' = 'earliest-offset',
      'format' = 'json',
      'json.ignore-parse-errors' = 'true'
 );


CREATE TABLE dim_secteur_sink (
     id_secteur INT,
     name STRING,
     code STRING,
     description STRING,
     __deleted STRING,
     __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (id_secteur) NOT ENFORCED
 ) WITH (
     'connector' = 'jdbc',
     'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
     'table-name' = 'dim_secteur',
     'username' = 'postgres',
    'password' = 'postgres'
);
INSERT INTO dim_secteur_sink
SELECT
    id_secteur,
    name,
    code,
    description,
    __deleted,
    __op,
    __source_ts_ms
FROM dim_secteur_source
WHERE id_secteur IS NOT NULL;

