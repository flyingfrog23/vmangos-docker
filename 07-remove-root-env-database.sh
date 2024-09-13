#!/bin/bash

# Define variables
COMPOSE_FILE="docker-compose.yml"
SERVICE_NAME="vmangos-database"
ENV_FILE=".env"

# Comment out MYSQL_ROOT_PASSWORD in the .env file
echo "Clearing MYSQL_ROOT_PASSWORD in the $ENV_FILE file..."
sed -i '/^MYSQL_ROOT_PASSWORD=/s/^/#/' "$ENV_FILE"

# Restart the specified service
echo "Restarting $SERVICE_NAME..."
docker compose -f "$COMPOSE_FILE" stop "$SERVICE_NAME" && \
docker compose -f "$COMPOSE_FILE" up -d "$SERVICE_NAME"

echo "$SERVICE_NAME has been restarted, and MYSQL_ROOT_PASSWORD is now cleared."