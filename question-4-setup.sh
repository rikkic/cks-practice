#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 4: create a non-compliant deployment and enforce PSS restricted.

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

kubectl get ns payments >/dev/null 2>&1 || kubectl create ns payments

kubectl -n payments apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payments
  labels:
    app: payments
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payments
  template:
    metadata:
      labels:
        app: payments
    spec:
      containers:
      - name: app
        image: nginx:1.25
        ports:
        - containerPort: 8080
YAML

# Enforce restricted PSS and trigger admission failures on new pods.
kubectl label ns payments pod-security.kubernetes.io/enforce=restricted --overwrite
kubectl -n payments delete pod -l app=payments --ignore-not-found
