#!/bin/bash

# Define variables
BACKUP_DIR="/vol/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATABASE="mangos"

# Function to back up a database
backup_database() {
  local db_name=$1
  echo "[VMaNGOS]: Backing up $db_name database..."
  mariadb-dump -h 127.0.0.1 -u mangos -p"$MYSQL_ROOT_PASSWORD" --single-transaction "$db_name" > "$BACKUP_DIR/${db_name}_${TIMESTAMP}.sql" \
    || { echo "Failed to back up $db_name"; exit 1; }
}

# Backup the database
backup_database "$DATABASE"

echo "[VMaNGOS]: Backup complete!"
