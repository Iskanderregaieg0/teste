#!/bin/bash

echo "🔌 Déploiement des connecteurs Debezium..."

# Chemin des fichiers JSON
CONNECTOR_DIR="debezium-connector"

# Adresse de l'API Kafka Connect (peut être adapté si tu es sur EC2)
CONNECT_URL="http://localhost:8083/connectors"

# Boucle sur tous les fichiers JSON
for json_file in $CONNECTOR_DIR/*.json; do
  connector_name=$(basename "$json_file" .json)
  echo "→ Création du connecteur : $connector_name"

  # Envoie la requête POST à l'API Kafka Connect
  curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    --data "@$json_file" \
    $CONNECT_URL | grep -q "201"

  # Vérification du succès
  if [ $? -eq 0 ]; then
    echo "✅ Connecteur $connector_name créé avec succès."
  else
    echo "⚠️ Connecteur $connector_name déjà existant ou erreur."
  fi
done
