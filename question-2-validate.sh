#!/usr/bin/env bash
set -euo pipefail

fail=0

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing command: $1" >&2
    exit 1
  fi
}

check() {
  local name="$1"
  if ! eval "$2"; then
    echo "FAIL: $name" >&2
    fail=1
  else
    echo "PASS: $name"
  fi
}

require_cmd kubectl

check_kubelet_secure() {
  if [[ -f /var/lib/kubelet/config.yaml ]]; then
    python3 - <<'PY'
import re
from pathlib import Path
p = Path("/var/lib/kubelet/config.yaml")
text = p.read_text()
patterns = [
    r"readOnlyPort:\s*0",
    r"authentication:.*anonymous:.*enabled:\s*false",
    r"authentication:.*webhook:.*enabled:\s*true",
    r"authorization:.*mode:\s*Webhook",
]
for pat in patterns:
    if not re.search(pat, text, flags=re.S):
        raise SystemExit(1)
PY
    return $?
  fi

  if [[ -f /var/lib/kubelet/kubeadm-flags.env ]]; then
    grep -q -- '--read-only-port=0' /var/lib/kubelet/kubeadm-flags.env || return 1
    grep -q -- '--anonymous-auth=false' /var/lib/kubelet/kubeadm-flags.env || return 1
    grep -q -- '--authentication-token-webhook=true' /var/lib/kubelet/kubeadm-flags.env || return 1
    grep -q -- '--authorization-mode=Webhook' /var/lib/kubelet/kubeadm-flags.env || return 1
    return 0
  fi

  return 1
}

check "kubelet secure config" "check_kubelet_secure"

check "kubernetes dir not group/other readable" "! find /etc/kubernetes -perm /077 -print | grep -q ."

check "kubelet client cert rotated (recent mtime)" "python3 - <<'PY'
import os, time
p = '/var/lib/kubelet/pki/kubelet-client-current.pem'
if not os.path.exists(p):
    raise SystemExit(1)
mtime = os.stat(p).st_mtime
if time.time() - mtime > 24*3600:
    raise SystemExit(1)
PY"

check "node worker1 Ready" "kubectl get node worker1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"

exit $fail
