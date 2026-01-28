#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 9: create namespace, suspect deployment, and an audit log entry.

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

kubectl get ns finance >/dev/null 2>&1 || kubectl create ns finance

kubectl -n finance apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fin-app
  labels:
    app: fin-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fin-app
  template:
    metadata:
      labels:
        app: fin-app
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "while true; do wget -qO- http://198.51.100.20 || true; sleep 20; done"]
YAML

# Append a synthetic audit log entry for investigation.
if [[ -d /var/log/kubernetes ]]; then
  sudo touch /var/log/kubernetes/audit.log
  sudo bash -c 'cat <<EOF >> /var/log/kubernetes/audit.log
{"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"RequestResponse","stage":"ResponseComplete","verb":"patch","user":{"username":"evil-user"},"objectRef":{"resource":"deployments","namespace":"finance","name":"fin-app"},"requestReceivedTimestamp":"2026-01-28T12:34:56Z","stageTimestamp":"2026-01-28T12:34:56Z"}
EOF'
fi
