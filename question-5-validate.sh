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

check "prod namespace restricted" "kubectl get ns prod -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' | grep -q restricted"

check "legacy-logger non-privileged and no hostPath" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','prod','get','deploy','legacy-logger','-o','json'])
obj = json.loads(raw)
ps = obj['spec']['template']['spec']
for c in ps.get('containers', []):
    sc = c.get('securityContext', {})
    if sc.get('privileged', False):
        sys.exit(1)
for v in ps.get('volumes', []):
    if 'hostPath' in v:
        sys.exit(1)
PY"

check "legacy-logger available" "kubectl -n prod get deploy legacy-logger -o jsonpath='{.status.availableReplicas}' | grep -qE '^[1-9]'
"

exit $fail
