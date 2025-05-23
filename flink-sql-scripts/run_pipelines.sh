#!/bin/bash

echo "Lancement du pipeline dim_job..."
docker exec -i ubuntu_flink-jobmanager_1 ./bin/sql-client.sh -f /opt/sql/dim_job_pipeline.sql &
echo "dim_job lancé."

echo "Lancement du pipeline dim_secteur..."
docker exec -i ubuntu_flink-jobmanager_1 ./bin/sql-client.sh -f /opt/sql/dim_secteur_pipeline.sql &
echo "dim_secteur lancé."

wait
