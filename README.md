# Stellar Validator at Home by Obsrvr

*A comprehensive, step-by-step guide to setting up and running your own Stellar Validator node at home using Docker and Docker Compose. Enhance your understanding of the Stellar network, contribute to its decentralization and security, and ensure reliable participation with Obsrvr’s expert instructions, best practices, and troubleshooting tips.*

---

## Table of Contents

- [Stellar Validator at Home by Obsrvr](#stellar-validator-at-home-by-obsrvr)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Architecture Overview](#architecture-overview)
  - [Installation](#installation)
    - [1. Install Docker and Docker Compose](#1-install-docker-and-docker-compose)
    - [2. Clone the Repository](#2-clone-the-repository)
    - [3. Configure Stellar Core](#3-configure-stellar-core)
  - [Running the Validator](#running-the-validator)
    - [1. Start the Services](#1-start-the-services)
    - [2. Verify the Setup](#2-verify-the-setup)
  - [Monitoring and Maintenance](#monitoring-and-maintenance)
    - [1. Monitoring Tools](#1-monitoring-tools)
    - [2. Regular Maintenance](#2-regular-maintenance)
  - [Security Best Practices](#security-best-practices)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [Contact](#contact)

---

## Introduction

Welcome to Obsrvr's **Stellar Validator at Home** guide using Docker and Docker Compose!

This repository provides a comprehensive walkthrough for individuals and organizations interested in setting up a Stellar Validator node from the comfort of their own home using containerization. By leveraging Docker, you simplify the deployment process, ensure consistency across environments, and facilitate easier updates and maintenance.

**Key Benefits:**

- **Ease of Deployment**: Quickly set up and run your validator node with minimal configuration.
- **Containerization Advantages**: Isolate your node environment, manage dependencies efficiently, and simplify scaling.
- **Contribute to Network Security**: Strengthen the Stellar network by adding a new validator.
- **Community Engagement**: Join the global community of Stellar network participants.

---

## Prerequisites

Before you begin, ensure you have the following:

- **Basic Docker Knowledge**: Familiarity with Docker and Docker Compose.
- **Hardware**: A dedicated machine or virtual server.
- **Operating System**: Ubuntu 20.04 LTS or later is recommended (Docker compatible OS).
- **Internet Connection**: Stable broadband connection.
- **Stellar Account**: Optional but recommended for network participation.

---

## Architecture Overview

![Architecture Diagram](./images/docker_architecture_diagram.png)

*An overview of the components involved in running a Stellar Validator node using Docker.*

- **Stellar Core Container**: Runs the Stellar Core software.
- **PostgreSQL Container**: Serves as the database backend for Stellar Core.
- **Docker Network**: Facilitates communication between containers.
- **Monitoring Tools**: Optional containers for monitoring node performance and network status.

---

## Installation

### 1. Install Docker and Docker Compose

**Docker Installation:**

Follow the official Docker installation guide for your operating system: [Get Docker](https://docs.docker.com/get-docker/)

**Docker Compose Installation:**

Docker Compose is now included with Docker Desktop on Windows and macOS. For Linux:

```bash
sudo apt update
sudo apt install -y docker-compose
```

Verify the installations:

```bash
docker --version
docker-compose --version
```

### 2. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/obsrvr/stellar-validator-at-home.git
cd stellar-validator-at-home
```

### 3. Configure Stellar Core

Copy the example environment file and customize it:

```bash
cp .env.example .env
```

Edit the `.env` file:

```bash
nano .env
```

### 3. Configure Stellar Core

Copy the example environment file and customize it:

```bash
cp .env.example .env
```


Generate a node seed (this will be your validator's unique identity):

```bash
docker run stellar/stellar-core:latest gen-seed
```


This command will output something like:

```
Secret seed: SDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Public: GDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Copy the output seed and paste it into the `.env` file where it says `NODE_SEED=`.

**Environment Variables:**

- `NODE_SEED`: Your node's secret seed (keep this secure).
- `NODE_IS_VALIDATOR`: Set to `true` to enable validation.
- `PUBLIC_HTTP_PORT`: Set to `true` to expose the HTTP port.
- `NETWORK_PASSPHRASE`: The network passphrase (default is for the public network).
- `DATABASE_URL`: Connection string for the PostgreSQL database.

**Example `.env` file:**

```ini
# Stellar Core Configuration
NODE_SEED=YOUR_NODE_SEED
NODE_IS_VALIDATOR=true
PUBLIC_HTTP_PORT=true
NETWORK_PASSPHRASE="Public Global Stellar Network ; September 2015"

# Database Configuration
DATABASE_URL=postgresql://stellar:stellar@postgres:5432/stellar

# Quorum Configuration
QUORUM_SET=["$self", "sdf1", "sdf2", "sdf3"]
THRESHOLD_PERCENT=67

# History Archives
HISTORY_ARCHIVE_URLS="https://history.stellar.org/prd/core-live/core_live_001/{0}"
```

**Note:** Replace `YOUR_NODE_SEED` with your actual node seed. Keep this seed secure and do not share it.

---

## Running the Validator

### 1. Start the Services

Use Docker Compose to build and start the containers:

```bash
docker-compose up -d
```

This command will:

- Build the Docker images (if not already built).
- Start the PostgreSQL and Stellar Core containers.
- Run Stellar Core with the configuration provided.

### 2. Verify the Setup

Check the status of the containers:

```bash
docker-compose ps
```

View the logs of Stellar Core:

```bash
docker-compose logs -f stellar-core
```

- **Tip:** Press `Ctrl+C` to exit the log stream.

Verify that Stellar Core is running and connected to peers:

```bash
docker-compose exec stellar-core stellar-core http-command 'info'
```

You should see output indicating the node's status, network connections, and ledger synchronization progress.

---

## Monitoring and Maintenance

### 1. Monitoring Tools

You can integrate additional containers for monitoring, such as Prometheus and Grafana.

**Example:**

Update `docker-compose.yml` to include monitoring services.

```yaml
services:
  # Existing services...

  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

Configure Prometheus to scrape metrics from Stellar Core and PostgreSQL.

### 2. Regular Maintenance

- **Updating Containers**:

  Pull the latest images and rebuild:

  ```bash
  docker-compose pull
  docker-compose up -d --build
  ```

- **Backing Up Data**:

  Back up the PostgreSQL data volume.

  ```bash
  docker-compose down
  tar czvf postgres_data_backup.tar.gz ./data/postgres
  docker-compose up -d
  ```

- **Cleaning Up**:

  Remove unused images and containers:

  ```bash
  docker system prune -f
  ```

---

## Security Best Practices

- **Secure Your Node Seed**: Ensure `NODE_SEED` is kept confidential.
- **Docker Secrets**: Consider using Docker Secrets to manage sensitive data.
- **Firewall Configuration**: Limit access to necessary ports.

  ```bash
  sudo ufw allow 11625/tcp   # Stellar peer port
  sudo ufw enable
  ```

- **Regular Updates**: Keep your Docker images and host system updated.
- **SSH Security**: Use key-based authentication and disable password logins.

---

## Troubleshooting

- **Containers Won't Start**: Check for errors in the Docker Compose logs.
- **Unable to Sync**: Ensure your network connection is stable and ports are open.
- **Database Errors**: Verify that the PostgreSQL container is running and accessible.
- **Stellar Core Logs**: Use `docker-compose logs stellar-core` for detailed error messages.

---

## Contributing

Contributions are welcome! If you have suggestions, improvements, or find issues, please open an issue or submit a pull request.

**To Contribute:**

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/your-feature-name`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin feature/your-feature-name`.
5. Open a pull request.

---



## Contact

For questions or support, please contact:

- **Obsrvr Team**
- **Email**: [support@obsrvr.com](mailto:support@obsrvr.com)
- **Website**: [www.obsrvr.com](https://www.obsrvr.com)

---

**Disclaimer:** Running a validator node requires technical expertise and a commitment to maintaining the node. Ensure you understand the responsibilities and security implications before proceeding.

---

*Thank you for contributing to the Stellar network by setting up your own validator node! Together, we strengthen the decentralization and resilience of the blockchain ecosystem.*
