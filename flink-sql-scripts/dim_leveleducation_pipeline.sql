CREATE TABLE dim_leveleducation_source (
    id INT,
    description STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_dim_leveleducation.public.topleveleducation',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);


CREATE TABLE dim_leveleducation_sink (
    id INT,
    description STRING,
    TopLevel STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_level_education',
    'username' = 'postgres',
    'password' = 'postgres'
);

INSERT INTO dim_leveleducation_sink
SELECT
  id,
   description,
  CASE LOWER(description)
    WHEN 'licence' THEN 'Bac +3'
    WHEN 'master' THEN 'Bac +5'
    WHEN 'ingenieur' THEN 'Bac +5'
    WHEN 'doctorat' THEN 'Bac +8'
    ELSE NULL
  END AS TopLevel,

  __deleted,
  __op,
  __source_ts_ms

FROM dim_leveleducation_source;