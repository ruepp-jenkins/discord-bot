#!/bin/bash
set -e
echo "Starting build workflow"

scripts/docker_initialize.sh

cd source/DiscordBot

# run build
echo "[${BRANCH_NAME}] Building images: ${IMAGE_FULLNAME}"
if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]
then
    docker build \
        -t ${IMAGE_FULLNAME}:latest \
        -f Dockerfile \
        --push .
else
    docker build \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME} \
        -f Dockerfile \
        --push .
fi
