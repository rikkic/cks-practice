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

check "audit summary saved" "test -s /home/ubuntu/answers/q9-audit.txt"

check "test-client pod exists" "kubectl -n finance-q9 get pod test-client >/dev/null 2>&1"

check "egress restricted in finance-q9" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','finance-q9','get','netpol','-o','json'])
obj = json.loads(raw)
items = obj.get('items', [])
if not items:
    sys.exit(1)

has_deny_eg = False
has_dns = False

for p in items:
    spec = p.get('spec', {})
    pt = set(spec.get('policyTypes', []))
    egress = spec.get('egress', [])
    if 'Egress' in pt and not egress:
        has_deny_eg = True
    for rule in egress:
        for to in rule.get('to', []):
            ipb = to.get('ipBlock', {})
            if ipb.get('cidr') == '0.0.0.0/0':
                sys.exit(1)
        for port in rule.get('ports', []):
            if port.get('port') == 53:
                has_dns = True

if not (has_deny_eg and has_dns):
    sys.exit(1)
PY"

exit $fail
