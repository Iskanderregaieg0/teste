CREATE TABLE dim_company_details_source (
      id INT,
      id_company INT,
      id_location INT,
      __deleted STRING,
      __op STRING,
      __source_ts_ms BIGINT
  ) WITH (
      'connector' = 'kafka',
      'topic' = 'userprofile_dim_company_details.public.company_details',
      'properties.bootstrap.servers' = 'kafka:9092',
      'properties.group.id' = 'flink-group',
      'scan.startup.mode' = 'earliest-offset',
      'format' = 'json',
      'json.ignore-parse-errors' = 'true'
 );


CREATE TABLE dim_company_details_sink (
      id INT,
    id_company INT,
    id_location INT,
     __deleted STRING,
     __op STRING,
    __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
 ) WITH (
     'connector' = 'jdbc',
     'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
     'table-name' = 'dim_company_details',
     'username' = 'postgres',
    'password' = 'postgres'
);
INSERT INTO dim_company_details_sink
SELECT
     id ,
    id_company ,
    id_location ,
    __deleted,
    __op,
    __source_ts_ms
FROM dim_company_details_source
WHERE id IS NOT NULL;

