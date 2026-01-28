#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 2: weaken kubelet settings and loosen /etc/kubernetes permissions.

if [[ -f /var/lib/kubelet/kubeadm-flags.env ]]; then
  sudo cp -f /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/kubeadm-flags.env.bak
  sudo python3 - <<'PY'
from pathlib import Path
import re

p = Path("/var/lib/kubelet/kubeadm-flags.env")
text = p.read_text()

m = re.search(r'KUBELET_KUBEADM_ARGS="(.*)"', text)
if not m:
    raise SystemExit("KUBELET_KUBEADM_ARGS not found")

args = m.group(1)
for flag in [
    "--read-only-port=10255",
    "--anonymous-auth=true",
    "--authorization-mode=AlwaysAllow",
    "--authentication-token-webhook=false",
]:
    if flag not in args:
        args = args + " " + flag

new_text = re.sub(r'KUBELET_KUBEADM_ARGS=".*"', f'KUBELET_KUBEADM_ARGS="{args}"', text)

p.write_text(new_text)
PY
fi

# Loosen permissions to create a remediation target.
if [[ -d /etc/kubernetes ]]; then
  sudo chmod -R 777 /etc/kubernetes
fi

# Restart kubelet to apply changes.
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl restart kubelet || true
fi
