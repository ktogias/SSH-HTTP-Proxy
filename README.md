
# SSH HTTP Proxy

This project sets up an HTTP proxy using Docker, Nginx, and SSH tunneling. It ensures secure and reliable communication with a remote HTTP server through an SSH tunnel.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Docker**: Installation instructions can be found [here](https://docs.docker.com/get-docker/).
2. **Docker Compose**: Installation instructions can be found [here](https://docs.docker.com/compose/install/).
3. **SSH Client**: Typically installed by default on Unix-based systems.

Additionally, ensure you have the following access and information:

1. **SSH Access to the Remote Server**:
   - You must have SSH access to the remote server where the Site or API is hosted.
   - Ensure you have the username (`SSH_USER`) and the host address (`SSH_HOST`) of the remote server.
   - Ensure you have the password for the user or that your SSH key is authorized on the remote server for passwordless access.
2. **Private URL of the API**:
   - You must have the private URL (IP or DNS) and port of the API.
   - Ensure you can access the API from the remote server, e.g. by connecting with `ssh` and using `curl`.

## Project Structure

```
SSH-HTTP-Proxy/
├── .env.dist
├── .gitignore
├── setup_ssh_keys.sh
├── build.sh
├── docker-compose.yml
├── .env
├── ssh/
│   ├── .gitkeep
│   └── .gitignore
└── build/
    ├── Dockerfile
    ├── entrypoint.sh
    └── nginx.conf
```

### Files and Directories

- **.env.dist**: Example environment file with variable placeholders.
- **.gitignore**: Git ignore file to exclude certain files and directories from version control.
- **setup_ssh_keys.sh**: Script to generate SSH keys and copy them to the remote server.
- **build.sh**: Script to build and tag the Docker image.
- **docker-compose.yml**: Docker Compose file to set up and run the containerized environment.
- **.env**: Environment file with actual variable values.
- **ssh/**: Directory to hold SSH keys.
  - **.gitkeep**: Placeholder to ensure the directory is tracked by Git.
  - **.gitignore**: Git ignore file for the SSH keys directory.
- **build/**: Directory containing build-related files.
  - **Dockerfile**: Dockerfile to build the Docker image.
  - **entrypoint.sh**: Entrypoint script for the Docker container.
  - **nginx.conf**: Nginx configuration file.

## Setup Instructions

### 1. Environment Variables

Copy the `.env.dist` file to `.env` and fill in the required environment variables.
    
    ### Environment Variables
    - **IMAGE_TAG**: The tag for the Docker image.
    - **SSH_USER**: The SSH username for the remote server.
    - **SSH_HOST**: The SSH host address of the remote server.
    - **SSH_KEY_SUFFIX**: The suffix for the SSH key files.
    - **SITE_IP**: The private IP address of the remote HTTP server.
    - **SITE_PORT**: The port of the remote HTTP server.
    - **LOCAL_PORT**: The port on localhost to forward the HTTP site or API.
    

```sh
cp .env.dist .env
```

### 2. Generate SSH Keys

Run the `setup_ssh_keys.sh` script to generate the SSH keys and copy the public key to the remote server.

```sh
./setup_ssh_keys.sh
```

### 3. Run the Docker Container

Use Docker Compose to run the container.

```sh
docker-compose up
```

### 4. Access the HTTP Site or API

Once the container is up and running, you can access the HTTP proxy at `http://localhost:{LOCAL_PORT}`.

## Scripts

### setup_ssh_keys.sh

This script generates an SSH key pair, copies the public key to the remote server, and retrieves the server's SSH host key.

### build.sh

This script builds and tags the Docker image for the API proxy. It can also push the image to a Docker registry if the `--push` argument is provided.

Usage:

To build the Docker image:
```sh
./build.sh
```

To build and push the Docker image:
```sh
./build.sh --push
```

## Docker Configuration

### Dockerfile

The Dockerfile sets up an Alpine-based container with OpenSSH and Nginx.

### entrypoint.sh

The entrypoint script sets up the SSH tunnel and starts Nginx.

### nginx.conf

The Nginx configuration file sets up Nginx as a reverse proxy to forward requests from the container to the remote server over the SSH tunnel.

## License

This project is licensed under the MIT License.
