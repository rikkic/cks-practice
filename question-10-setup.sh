#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 10: create namespace.

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

kubectl get ns team-a >/dev/null 2>&1 || kubectl create ns team-a
