#!/bin/bash

echo "?? Job dim_job en cours..."
nohup /opt/flink/bin/sql-client.sh -f /opt/flink/insert_dim_job.sql > /opt/flink/job.log 2>&1 &

echo "?? Job dim_secteur en cours..."
nohup /opt/flink/bin/sql-client.sh -f /opt/flink/insert_dim_secteur.sql > /opt/flink/secteur.log 2>&1 &

echo "? Les deux jobs ont été lancés."
