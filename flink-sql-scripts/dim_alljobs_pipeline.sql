CREATE TABLE dim_jobsall_source (
    id INT,
    description STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_dim_alljob.public.alljobs',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors'= 'true'
);



CREATE TABLE dim_alljobs_sink (
    id INT,
    description STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'dim_alljobs',
    'username' = 'postgres',
    'password' = 'postgres'
);

INSERT INTO dim_alljobs_sink
SELECT
  id,
  description,
  __deleted,
  __op,
  __source_ts_ms
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY description ORDER BY __source_ts_ms  DESC) AS rownum
  FROM dim_jobsall_source
)
WHERE rownum = 1 AND description IS NOT NULL;





