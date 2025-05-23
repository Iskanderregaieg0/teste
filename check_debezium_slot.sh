#!/bin/bash

# Variables
PGUSER="postgres"
PGDATABASE="userprofile_db"
SLOT_NAME="debezium_slot"

echo "🔍 Vérification du slot de réplication '$SLOT_NAME' dans la base '$PGDATABASE'..."

# Commande SQL
QUERY="SELECT slot_name, plugin, slot_type, active, confirmed_flush_lsn, restart_lsn FROM pg_replication_slots WHERE slot_name = '$SLOT_NAME';"

# Exécution de la requête
psql -U $PGUSER -d $PGDATABASE -c "$QUERY"
