CREATE TABLE Matching_score (
    id INT,
    id_candidat INT,
    id_job INT,
    score Double
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/userprofile_db',
    'table-name' = 'matching_score',
    'username' = 'postgres',
    'password' = 'postgres'
);



CREATE TABLE fact_job_application_source (
    id INT,
    candidateid INT,
    jobid INT,
    applicationdate INT,
    status STRING,
    candidature_complete Boolean,
    temps_moyen_reponse INT,
    canal_candidature STRING,
    ancien_candidat Boolean,
    feedback_refus STRING,
    __deleted STRING,
    __op STRING,
    __source_ts_ms BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'userprofile_fact_job_application.public.job_application',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);


CREATE TABLE fact_job_application_sink (
    id INT,
    candidateid INT,
    jobid INT,
    applicationdate DATE,
    status VARCHAR(50),
    candidature_complete BOOLEAN,
    temps_moyen_reponse INT,
    canal_candidature VARCHAR(100),
    ancien_candidat BOOLEAN,
    feedback_refus VARCHAR(255),
    Score_matching FLOAT,
    __deleted VARCHAR(10),
    __op VARCHAR(10),
    __source_ts_ms BIGINT,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://13.39.236.161:32050/datawarehouse_db',
    'table-name' = 'fact_job_application',
    'username' = 'postgres',
    'password' = 'postgres'
);



INSERT INTO fact_job_application_sink
SELECT
    c.id ,
    c.candidateid ,
    c.jobid ,
    TO_DATE(FROM_UNIXTIME(CAST(c.applicationdate AS BIGINT) * 86400)) AS applicationdate,
    c.status ,
    c.candidature_complete ,
    c.temps_moyen_reponse ,
    c.canal_candidature ,
    c.ancien_candidat ,
    c.feedback_refus ,
    CAST(s.score AS FLOAT) as Score_matching ,
    c.__deleted ,
    c.__op ,
    c.__source_ts_ms 
FROM fact_job_application_source c
LEFT JOIN Matching_score s
  ON c.candidateid = s.id_candidat and c.jobid=s.id_job
WHERE c.id IS NOT NULL;

