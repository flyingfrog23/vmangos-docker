#!/bin/bash

# Get variables defined in .env

source .env

# Handle script call from other directory

get_script_path() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
repository_path=$(dirname "$(get_script_path "$0")")
cd "$repository_path"

# Start

echo "[VMaNGOS]: Removing old target directory..."
rm -r ./vol/core_github

echo "[VMaNGOS]: Cloning github repository..."
git clone $VMANGOS_GIT_SOURCE_CORE_URL ./vol/core_github/

echo "[VMaNGOS]: Cloning github repository finished."
echo "[VMaNGOS]: Merging VMaNGOS core migrations..."
cd ./vol/core_github/sql/migrations
./merge.sh
cd "$repository_path"

echo "[VMaNGOS]: Shutting down environment..."
docker-compose down

echo "[VMaNGOS]: Building compiler image..."
docker build \
  --build-arg DEBIAN_FRONTEND=noninteractive \
  --no-cache \
  -t vmangos_build \
  -f ./docker/build/Dockerfile .

echo "[VMaNGOS]: Compiling VMaNGOS..."
docker run \
  -v "$repository_path/vol/ccache:/vol/ccache" \
  -v "$repository_path/vol/core:/vol/core" \
  -v "$repository_path/vol/core_github:/vol/core_github" \
  -e CCACHE_DIR=$CCACHE_DIR \
  -e VMANGOS_ANTICHEAT=$VMANGOS_ANTICHEAT \
  -e VMANGOS_CLIENT=$VMANGOS_CLIENT \
  -e VMANGOS_DEBUG=$VMANGOS_DEBUG \
  -e VMANGOS_EXTRACTORS=$VMANGOS_EXTRACTORS \
  -e VMANGOS_LIBCURL=$VMANGOS_LIBCURL \
  -e VMANGOS_MALLOC=$VMANGOS_MALLOC \
  -e VMANGOS_SCRIPTS=$VMANGOS_SCRIPTS \
  -e VMANGOS_THREADS=$VMANGOS_THREADS \
  -e VMANGOS_WORLD_DATABASE=$VMANGOS_WORLD_DATABASE \
  --rm \
  vmangos_build

echo "[VMaNGOS]: Compiling complete!"

echo "[VMaNGOS]: Starting up environment..."
docker-compose up -d
