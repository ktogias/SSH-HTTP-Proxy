#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
SSH_KEY_PATH=/ssh/id_${SSH_KEY_SUFFIX}
SSH_KEY_PUB_PATH=/ssh/id_${SSH_KEY_SUFFIX}.pub
SSH_KNOWN_HOSTS=/ssh/known_hosts
REMOTE_COMMAND_DIR="/remote_command"
REMOTE_COMMAND_SCRIPT="run.sh"

# Check if the SSH key files exist
if [ ! -f "${SSH_KEY_PATH}" ] || [ ! -f "${SSH_KEY_PUB_PATH}" ]; then
  echo "SSH key files not found in /mnt/ssh/"
  exit 1
fi

# Create .ssh directory if it doesn't exist
mkdir -p /root/.ssh

# Copy SSH keys to the .ssh directory
cp "${SSH_KEY_PATH}" /root/.ssh/id
cp "${SSH_KEY_PUB_PATH}" /root/.ssh/id.pub
cp "${SSH_KNOWN_HOSTS}" /root/.ssh/known_hosts


# Set the correct permissions
chmod 600 /root/.ssh/id
chmod 644 /root/.ssh/id.pub
chmod 644 /root/.ssh/known_hosts

# Start Nginx
nginx -g 'daemon on;'


# Function to run SSH tunnel
run_ssh_tunnel() {
  ssh \
    -N \
    -L "10000:${SITE_IP}:${SITE_PORT}" \
    "${SSH_USER}"@"${SSH_HOST}" \
    -i /root/.ssh/id || true
}

# Function to run remote command
run_remote_command() {
  if [ -f "${REMOTE_COMMAND_DIR}/${REMOTE_COMMAND_SCRIPT}" ]; then
    echo "Found ${REMOTE_COMMAND_SCRIPT}, copying ${REMOTE_COMMAND_DIR}/ to remote host and executing..."

    # Copy the whole /remote_command dir to the remote server's /tmp
    scp -i /root/.ssh/id \
      -o ProxyCommand="ssh -i /root/.ssh/id -W %h:%p ${SSH_USER}@${SSH_HOST}" \
      -r "${REMOTE_COMMAND_DIR}" "${SITE_SSH_USER}@${SITE_IP}:/tmp/"

    # Run the script remotely
    ssh -i /root/.ssh/id \
      -o ProxyCommand="ssh -i /root/.ssh/id -W %h:%p ${SSH_USER}@${SSH_HOST}" \
      "${SITE_SSH_USER}@${SITE_IP}" "sh /tmp/${REMOTE_COMMAND_DIR}/${REMOTE_COMMAND_SCRIPT}"
  else
    echo "No ${REMOTE_COMMAND_SCRIPT} found in ${REMOTE_COMMAND_DIR}. Skipping remote command."
    return 0
  fi
}

# Run SSH tunnel and restart Nginx if SSH tunnel fails
while true; do
  if ! run_remote_command; then
    echo "Remote command failed. Skipping tunnel setup. Retrying in 5 seconds..."
    sleep 5
    continue
  fi
  echo "Establishing SSH tunnel"
  run_ssh_tunnel
  echo "SSH tunnel failed. Restarting in 5 seconds..."
  sleep 5
done
