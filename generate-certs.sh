#!/bin/bash

# Script to generate self-signed certificates for dev and prod environments

# Create a directory for certificates
CERT_DIR="./certs"
mkdir -p $CERT_DIR

# Generate self-signed certificates for dev environment
echo "Generating self-signed certificate for dev environment..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $CERT_DIR/dev.key -out $CERT_DIR/dev.crt \
    -subj "/CN=dev.static-site.local/O=Static Site Dev" \
    -addext "subjectAltName = DNS:dev.static-site.local"

# Generate self-signed certificates for prod environment
echo "Generating self-signed certificate for prod environment..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $CERT_DIR/prod.key -out $CERT_DIR/prod.crt \
    -subj "/CN=static-site.local/O=Static Site Prod" \
    -addext "subjectAltName = DNS:static-site.local"

# Create Kubernetes TLS secrets
kubectl create secret generic static-site-tls-dev \
    --from-file=tls.key=$CERT_DIR/dev.key \
    --from-file=tls.crt=$CERT_DIR/dev.crt \
    --dry-run=client -o yaml >$CERT_DIR/tls-secret-dev.yaml

kubectl create secret generic static-site-tls-prod \
    --from-file=tls.key=$CERT_DIR/prod.key \
    --from-file=tls.crt=$CERT_DIR/prod.crt \
    --dry-run=client -o yaml >$CERT_DIR/tls-secret-prod.yaml

echo "Certificate and secret YAML files generated in $CERT_DIR"
kubectl apply -n app-dev -f $CERT_DIR/tls-secret-dev.yaml
kubectl apply -n app-prod -f $CERT_DIR/tls-secret-prod.yaml
