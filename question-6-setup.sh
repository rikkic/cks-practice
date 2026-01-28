#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 6: create namespace and (optionally) cosign keys.

if command -v kubectl >/dev/null 2>&1; then
  kubectl get ns secure >/dev/null 2>&1 || kubectl create ns secure
fi

# Create cosign keys if cosign is available and keys are missing.
if command -v cosign >/dev/null 2>&1; then
  if [[ ! -f /home/ubuntu/cosign.key || ! -f /home/ubuntu/cosign.pub ]]; then
    (cd /home/ubuntu && cosign generate-key-pair)
  fi
fi

# Note: Ensure an image like registry.local/secure-app@sha256:... is available in your lab registry.
