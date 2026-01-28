#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 3: create namespace and service account.

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

kubectl get ns dev >/dev/null 2>&1 || kubectl create ns dev
kubectl -n dev get sa app-sa >/dev/null 2>&1 || kubectl -n dev create sa app-sa
