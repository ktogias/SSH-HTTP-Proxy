#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Load environment variables from .env file
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/.env"

# Check if the keys already exist
if [ -f "${SCRIPT_DIR}/ssh/id_${SSH_KEY_SUFFIX}" ] && [ -f "${SCRIPT_DIR}/ssh/id_${SSH_KEY_SUFFIX}.pub" ]; then
  echo "SSH keys already exist."
else
  # Generate SSH key pair
  ssh-keygen -t rsa -b 4096 -f "${SCRIPT_DIR}/ssh/id_${SSH_KEY_SUFFIX}" -N "" -C "${SSH_USER}@${SSH_HOST}"
  echo "SSH key pair generated."
fi

# Copy the public key to the remote server
ssh-copy-id -i "${SCRIPT_DIR}/ssh/id_${SSH_KEY_SUFFIX}.pub" "${SSH_USER}@${SSH_HOST}"
echo "Public key copied to ${SSH_HOST}."

# Retrieve the server's SSH host key and save it to known_hosts
ssh-keyscan -H "${SSH_HOST}" > "${SCRIPT_DIR}/ssh/known_hosts"
echo "Server's SSH host key saved to known_hosts."
