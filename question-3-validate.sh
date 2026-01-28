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

check "namespace dev exists" "kubectl get ns dev >/dev/null 2>&1"

check "role app-readonly rules" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','dev','get','role','app-readonly','-o','json'])
role = json.loads(raw)
rules = role.get('rules', [])
if len(rules) != 1:
    sys.exit(1)
rule = rules[0]
verbs = set(rule.get('verbs', []))
resources = set(rule.get('resources', []))
if verbs != {'get','list','watch'}:
    sys.exit(1)
if resources != {'pods','services'}:
    sys.exit(1)
PY"

check "rolebinding to app-sa" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','dev','get','rolebinding','app-readonly-binding','-o','json'])
rb = json.loads(raw)
subs = rb.get('subjects', [])
ok = any(s.get('kind')=='ServiceAccount' and s.get('name')=='app-sa' and s.get('namespace')=='dev' for s in subs)
if not ok:
    sys.exit(1)
PY"

check "default SA automount disabled" "kubectl -n dev get sa default -o jsonpath='{.automountServiceAccountToken}' | grep -qi false"

check "authz check saved" "test -f /home/student/answers/q3-can-i.txt"
check "authz check allows list" "grep -qi '^yes$' /home/student/answers/q3-can-i.txt"

exit $fail
