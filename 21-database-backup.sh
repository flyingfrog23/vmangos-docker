#!/bin/bash

# Load environment variables
source .env-script

# Define variables
CONTAINER_NAME="vmangos-database"
BACKUP_DIR="./vol/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DBS=("characters" "realmd" "logs")

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to back up a database
backup_database() {
  local db_name=$1
  echo "[VMaNGOS]: Backing up $db_name database..."
  docker exec "$CONTAINER_NAME" mysql-dump -h 127.0.0.1 -u mangos -p"$MYSQL_ROOT_PASSWORD" --single-transaction "$db_name" > "$BACKUP_DIR/${db_name}_${TIMESTAMP}.sql" \
    || { echo "Failed to back up $db_name"; exit 1; }
}

# Backup databases
for db in "${DBS[@]}"; do
  backup_database "$db"
done

echo "[VMaNGOS]: Backup complete!"
