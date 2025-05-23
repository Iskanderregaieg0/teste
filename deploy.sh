#!/bin/bash

echo "🚀 Déploiement complet du pipeline Flink/Debezium"

# === 1. Copier les .jar vers Flink ===
echo "📦 Copie des JARs dans Flink..."
docker cp flink-jars/. ubuntu_flink-jobmanager_1:/opt/flink/lib/
docker cp flink-jars/. ubuntu_flink-taskmanager_1:/opt/flink/lib/

# === 2. Copier les .sql vers Flink ===
echo "📜 Copie des scripts SQL..."
docker exec ubuntu_flink-jobmanager_1 mkdir -p /opt/flink/sql/
for sql_file in flink-sql-scripts/*.sql; do
  docker cp "$sql_file" ubuntu_flink-jobmanager_1:/opt/flink/sql/
done

# === 3. Redémarrer Flink ===
echo "🔁 Redémarrage de Flink..."
docker restart ubuntu_flink-jobmanager_1
docker restart ubuntu_flink-taskmanager_1

echo "⏳ Attente du démarrage de Flink..."
sleep 15

# === 4. Exécuter les scripts SQL ===
echo "🏗 Lancement des jobs SQL Flink..."
for sql_file in flink-sql-scripts/*.sql; do
  filename=$(basename "$sql_file")
  echo "→ Exécution : $filename"
  docker exec ubuntu_flink-jobmanager_1 /opt/flink/bin/sql-client.sh -f /opt/flink/sql/$filename
done

# === 5. Créer les connecteurs Kafka (Debezium) ===
echo "🔌 Déploiement des connecteurs Debezium..."
./create_connectors.sh

# === 6. Redémarrage de Prometheus Exporter (si queries.yml modifié) ===
if [ -f monitoring/queries.yml ]; then
  echo "📊 Mise à jour de Postgres Exporter (queries.yml)..."
  docker cp monitoring/queries.yml postgres_exporter:/etc/postgres_exporter/queries.yml
  docker restart postgres_exporter
fi

echo "✅ Déploiement terminé avec succès."
