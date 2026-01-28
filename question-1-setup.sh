#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 1: create auditor kubeconfig and (optionally) weaken API server flags.

answers_dir=/home/ubuntu/answers
mkdir -p "$answers_dir"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; skipping cluster setup." >&2
  exit 0
fi

# Create an auditor service account with no extra RBAC.
kubectl -n default get sa auditor >/dev/null 2>&1 || kubectl -n default create sa auditor

# Create a token-backed kubeconfig for the auditor service account.
cluster_name=$(kubectl config view -o jsonpath='{.contexts[?(@.name=="'"$(kubectl config current-context)'"")].context.cluster}')
server=$(kubectl config view -o jsonpath='{.clusters[?(@.name=="'"$cluster_name'"")].cluster.server}')
ca_data=$(kubectl config view --raw -o jsonpath='{.clusters[?(@.name=="'"$cluster_name'"")].cluster.certificate-authority-data}')

# Kubernetes 1.24+ supports token creation via kubectl.
token=$(kubectl -n default create token auditor)

cat > /home/ubuntu/auditor.kubeconfig <<KUBECONFIG
apiVersion: v1
kind: Config
clusters:
- name: ${cluster_name}
  cluster:
    server: ${server}
    certificate-authority-data: ${ca_data}
users:
- name: auditor
  user:
    token: ${token}
contexts:
- name: auditor@${cluster_name}
  context:
    cluster: ${cluster_name}
    user: auditor
    namespace: default
current-context: auditor@${cluster_name}
KUBECONFIG

chmod 600 /home/ubuntu/auditor.kubeconfig

# If the API server static pod manifest exists, make it intentionally weak.
manifest=/etc/kubernetes/manifests/kube-apiserver.yaml
if [[ -f "$manifest" ]]; then
  sudo cp -f "$manifest" "${manifest}.bak"
  sudo python3 - <<'PY'
from pathlib import Path
import re

p = Path("/etc/kubernetes/manifests/kube-apiserver.yaml")
text = p.read_text()
lines = text.splitlines()

out = []
has_anon = False
has_authz = False

for line in lines:
    if "--anonymous-auth=" in line:
        out.append(re.sub(r"--anonymous-auth=.*", "--anonymous-auth=true", line))
        has_anon = True
        continue
    if "--authorization-mode=" in line:
        out.append(re.sub(r"--authorization-mode=.*", "--authorization-mode=AlwaysAllow", line))
        has_authz = True
        continue
    if "--tls-min-version=" in line or "--tls-cipher-suites=" in line:
        # Drop TLS hardening flags to simulate weak defaults.
        continue
    out.append(line)

# Insert missing flags after the kube-apiserver command line.
inserted = False
if not (has_anon and has_authz):
    new_out = []
    for line in out:
        new_out.append(line)
        if not inserted and re.search(r"-\s*kube-apiserver\s*$", line):
            indent = line[:line.find("-")]
            if not has_anon:
                new_out.append(f"{indent}- --anonymous-auth=true")
            if not has_authz:
                new_out.append(f"{indent}- --authorization-mode=AlwaysAllow")
            inserted = True
    out = new_out

p.write_text("\n".join(out) + "\n")
PY
fi
