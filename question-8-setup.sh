#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 8: create namespace and API deployment/service.

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

kubectl get ns netpol >/dev/null 2>&1 || kubectl create ns netpol

kubectl -n netpol apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels:
    app: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: hashicorp/http-echo:0.2.3
        args: ["-listen=:8080", "-text=ok"]
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: api
  labels:
    app: api
spec:
  selector:
    app: api
  ports:
  - port: 8080
    targetPort: 8080
YAML
