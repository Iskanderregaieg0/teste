#!/bin/bash

# Supprimer le connecteur s'il existe déjà
curl -X DELETE http://localhost:8083/connectors/postgres-connector

# Attendre un peu (au cas où)
sleep 2

# Recréer le connecteur à partir d'un fichier JSON
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @connector_debezuim.json 
