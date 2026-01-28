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

check "team-a namespace exists" "kubectl get ns team-a >/dev/null 2>&1"

check "resourcequota present" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','team-a','get','resourcequota','-o','json'])
obj = json.loads(raw)
items = obj.get('items', [])
if not items:
    sys.exit(1)
ok = False
for rq in items:
    hard = rq.get('spec', {}).get('hard', {})
    if 'cpu' in hard and 'memory' in hard and 'pods' in hard:
        ok = True
if not ok:
    sys.exit(1)
PY"

check "limitrange present" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','team-a','get','limitrange','-o','json'])
obj = json.loads(raw)
items = obj.get('items', [])
if not items:
    sys.exit(1)
ok = False
for lr in items:
    for lim in lr.get('spec', {}).get('limits', []):
        if lim.get('default') or lim.get('defaultRequest'):
            ok = True
if not ok:
    sys.exit(1)
PY"

check "service accounts exist" "kubectl -n team-a get sa cicd-sa runtime-sa >/dev/null 2>&1"

check "cicd can manage deployments" "kubectl auth can-i create deployments -n team-a --as=system:serviceaccount:team-a:cicd-sa | grep -q yes"
check "cicd can manage services" "kubectl auth can-i delete services -n team-a --as=system:serviceaccount:team-a:cicd-sa | grep -q yes"
check "runtime can read pods" "kubectl auth can-i list pods -n team-a --as=system:serviceaccount:team-a:runtime-sa | grep -q yes"
check "runtime cannot create deployments" "kubectl auth can-i create deployments -n team-a --as=system:serviceaccount:team-a:runtime-sa | grep -q no"

exit $fail
