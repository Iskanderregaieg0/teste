CREATE TABLE fact_experience_source (
      id INT,
    candidateid INT,
    entreprise_id_details INT,
     jobidall INT,
     start_date int,
     end_date int,
     description String,
     poste_occupe String,
     type_contrat String,
     niveau_responsabilite String,
     __deleted STRING,
     __op STRING,
      __source_ts_ms BIGINT
  ) WITH (
      'connector' = 'kafka',
      'topic' = 'userprofile_experience.public.experience',
      'properties.bootstrap.servers' = 'kafka:9092',
      'properties.group.id' = 'flink-group',
      'scan.startup.mode' = 'earliest-offset',
      'format' = 'json',
      'json.ignore-parse-errors' = 'true'
 );


CREATE TABLE fact_experience_sink (
    id INT,
    candidateid INT,
    entreprise_id_details INT,
     jobidall INT,
     start_date Date,
     end_date Date,
     description String,
     poste_occupe String,
     type_contrat String,
     niveau_responsabilite String,
     __deleted STRING,
     __op STRING,
      __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
 ) WITH (
     'connector' = 'jdbc',
     'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
     'table-name' = 'fact_experience',
     'username' = 'postgres',
    'password' = 'postgres'
);
INSERT INTO fact_experience_sink
SELECT
    id  ,
    candidateid  ,
    entreprise_id_details  ,
     jobidall  ,
     TO_DATE(FROM_UNIXTIME(CAST(start_date AS BIGINT) * 86400)) AS start_date,
     TO_DATE(FROM_UNIXTIME(CAST(end_date AS BIGINT) * 86400)) AS end_date,
     description  ,
     poste_occupe  ,
     type_contrat  ,
     niveau_responsabilite  ,
    __deleted,
    __op,
    __source_ts_ms
FROM fact_experience_source
WHERE id IS NOT NULL;

