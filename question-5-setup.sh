#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 5: create a privileged deployment with hostPath.

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

kubectl get ns prod >/dev/null 2>&1 || kubectl create ns prod

kubectl -n prod apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-logger
  labels:
    app: legacy-logger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-logger
  template:
    metadata:
      labels:
        app: legacy-logger
    spec:
      containers:
      - name: logger
        image: busybox:1.36
        command: ["sh", "-c", "while true; do date >> /var/log/app/legacy.log; sleep 5; done"]
        securityContext:
          privileged: true
        volumeMounts:
        - name: host-logs
          mountPath: /var/log/app
      volumes:
      - name: host-logs
        hostPath:
          path: /var/log/legacy
          type: DirectoryOrCreate
YAML
