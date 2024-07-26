#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Load environment variables from .env file
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/.env"

# Function to build the Docker image
build_image() {
    docker build -t "${IMAGE_TAG}" "${SCRIPT_DIR}/build"
}

# Function to push the Docker image
push_image() {
    docker push "${IMAGE_TAG}"
}

# Build the Docker image
build_image

# Check for the --push argument
if [ "$1" == "--push" ]; then
    push_image
fi
