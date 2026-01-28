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

check "payments namespace restricted" "kubectl get ns payments -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' | grep -q restricted"

check "payments deployment compliant" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','payments','get','deploy','payments','-o','json'])
obj = json.loads(raw)
pt = obj['spec']['template']
ps = pt['spec']
containers = ps.get('containers', [])
if not containers:
    sys.exit(1)

# Find /tmp volume mount and emptyDir volume
volumes = {v['name']: v for v in ps.get('volumes', [])}
for c in containers:
    sc = c.get('securityContext', {})
    if not sc.get('runAsNonRoot', False):
        sys.exit(1)
    if not sc.get('runAsUser', 0):
        sys.exit(1)
    if sc.get('allowPrivilegeEscalation', True):
        sys.exit(1)
    if not sc.get('readOnlyRootFilesystem', False):
        sys.exit(1)
    caps = sc.get('capabilities', {})
    if 'ALL' not in caps.get('drop', []):
        sys.exit(1)
    seccomp = sc.get('seccompProfile', {})
    if seccomp.get('type') != 'RuntimeDefault':
        # allow pod-level seccomp
        psec = ps.get('securityContext', {}).get('seccompProfile', {})
        if psec.get('type') != 'RuntimeDefault':
            sys.exit(1)

    mounts = {m['mountPath']: m['name'] for m in c.get('volumeMounts', [])}
    if '/tmp' not in mounts:
        sys.exit(1)
    v = volumes.get(mounts['/tmp'])
    if not v or 'emptyDir' not in v:
        sys.exit(1)

PY"

exit $fail
