# Simple static page with Traefik as ingress

- [Simple static page with Traefik as ingress](#simple-static-page-with-traefik-as-ingress)
  - [Description](#description)
  - [URLs](#urls)
    - [Environment URLs](#environment-urls)
  - [How to deploy localy](#how-to-deploy-localy)
    - [Prerequisites](#prerequisites)
    - [Deploying process](#deploying-process)
      - [Deploy all at once](#deploy-all-at-once)
      - [Cleanup](#cleanup)
      - [Individual Tasks](#individual-tasks)

## Description

This project has simple Go app as static page generator and Traefik as ingress. Application deployment is done as `dev` and `prod` environments.

The system consists of the following components:

1. **Static Site Application** - A Go web server that:
   - Serves a simple HTML page
   - Displays the current environment (dev/prod)
   - Shows a secret message injected as an environment variable
   - Provides a health check endpoint at `/health`

2. **Traefik Ingress** - Acts as the entry point that:
   - Routes traffic based on hostnames
   - Terminates TLS with self-signed certificates
   - Provides load balancing

3. **Helm Charts** - For easy deployment:
   - Universal static-site chart with environment-specific values
   - Separate releases for dev and prod environments

## URLs

It's expected that local K8S deployment will bind to localhost. To access sites you need to modify your `/etc/hosts` file with such content:

```plain
127.0.0.1 dev.static-site.local
127.0.0.1 static-site.local
```

### Environment URLs

- dev: [dev.static-site.local](dev.static-site.local)
- prod: [static-site.local](static-site.local)

## How to deploy localy

### Prerequisites

All deployment happens with [Task](https://taskfile.dev/). Here is [link](https://taskfile.dev/installation/) to the documentation on how to install this tool.

As kubernetes platform was used OrbStack.

### Deploying process

#### Deploy all at once

To deploy everything in one go:

```shell
task
```

This will run following tasks:

1. **Create Kubernetes Namespaces**
   - Creates namespace `traefik` for the Traefik ingress controller
   - Creates namespace `app-dev` for the development environment
   - Creates namespace `app-prod` for the production environment

2. **Start Local Docker Registry**
   - Starts a local Docker registry container on port 5000
   - Creates ConfigMaps in the dev and prod namespaces for local registry hosting

3. **Build and Push Docker Image**
   - Builds the static site container from the `static_site` directory
   - Pushes the image to the local registry with tag `localhost:5000/static-site:latest`

4. **Deploy Applications**
   - Generates TLS certificates for dev and prod environments
   - Deploys Traefik as the ingress controller
     - Adds Traefik Helm repository
     - Installs Traefik with custom values
   - Deploys the static site application
     - Installs the dev environment using `values-dev.yaml`
     - Installs the prod environment using `values-prod.yaml`

#### Cleanup

To remove all deployed resources:

```shell
task delete-apps
```

This will perform the following cleanup steps:

1. **Delete Applications**
   - Uninstalls the static site from the dev namespace
   - Uninstalls the static site from the prod namespace

2. **Delete Traefik**
   - Uninstalls Traefik from the ingress namespace

3. **Delete Namespaces**
   - Removes the app-dev, app-prod, and ingress namespaces

4. **Cleanup Docker Resources**
   - Stops and removes the local registry container
   - Prunes Docker networks and volumes

#### Individual Tasks

You can also run specific parts of the deployment process using the following tasks:

```shell
# Create namespaces only
task create-namespaces

# Start the local registry only
task start-registry

# Build and push the Docker image only
task docker-push

# Deploy applications only (TLS, Traefik, and static site)
task deploy-apps

# Deploy only the dev environment
task deploy-app-dev

# Deploy only the prod environment
task deploy-app-prod

# Delete only the static site applications
task delete-app

# Delete only Traefik
task delete-traefik
```
