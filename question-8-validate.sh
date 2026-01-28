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

check "netpol namespace exists" "kubectl get ns netpol >/dev/null 2>&1"

check "networkpolicies enforce requirements" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','netpol','get','netpol','-o','json'])
obj = json.loads(raw)
items = obj.get('items', [])

has_deny_ing = False
has_deny_eg = False
has_api_ing = False
has_egress = False

for p in items:
    spec = p.get('spec', {})
    pt = set(spec.get('policyTypes', []))
    ingress = spec.get('ingress', [])
    egress = spec.get('egress', [])
    if 'Ingress' in pt and not ingress:
        has_deny_ing = True
    if 'Egress' in pt and not egress:
        has_deny_eg = True

    sel = spec.get('podSelector', {}).get('matchLabels', {})
    if sel.get('app') == 'api':
        for rule in ingress:
            ports = rule.get('ports', [])
            if not any(p.get('port') == 8080 for p in ports):
                continue
            for src in rule.get('from', []):
                if src.get('podSelector', {}) == {}:
                    has_api_ing = True

    for rule in egress:
        ports = rule.get('ports', [])
        port_set = {p.get('port') for p in ports}
        # DNS allow
        if 53 in port_set:
            has_egress = True
        # External allow to 203.0.113.10/32:443
        for to in rule.get('to', []):
            ipb = to.get('ipBlock', {})
            if ipb.get('cidr') == '203.0.113.10/32' and 443 in port_set:
                has_egress = True

if not (has_deny_ing and has_deny_eg and has_api_ing and has_egress):
    sys.exit(1)
PY"

exit $fail
