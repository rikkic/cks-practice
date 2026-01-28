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

check "validating admission policy requires digest" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','get','validatingadmissionpolicy','-o','json'])
obj = json.loads(raw)
items = obj.get('items', [])
for pol in items:
    if pol.get('metadata', {}).get('name') != 'require-image-digest-secure':
        continue
    vals = pol.get('spec', {}).get('validations', [])
    for v in vals:
        expr = v.get('expression', '')
        if '@sha256:' in expr:
            sys.exit(0)
sys.exit(1)
PY"

check "secure namespace labeled for binding" "kubectl get ns secure -o jsonpath='{.metadata.labels.cks-lab}' | grep -q question-6"

check "policy bound only to namespace secure via selector" "python3 - <<'PY'
import json, subprocess, sys
bindings = json.loads(subprocess.check_output(['kubectl','get','validatingadmissionpolicybinding','-o','json']))
for b in bindings.get('items', []):
    if b.get('metadata', {}).get('name') != 'require-image-digest-secure-binding':
        continue
    if b.get('spec', {}).get('policyName') != 'require-image-digest-secure':
        continue
    ns_sel = b.get('spec', {}).get('matchResources', {}).get('namespaceSelector', {})
    ml = ns_sel.get('matchLabels', {})
    if ml.get('cks-lab') == 'question-6':
        sys.exit(0)
    for expr in ns_sel.get('matchExpressions', []):
        if expr.get('key') == 'cks-lab' and 'question-6' in expr.get('values', []):
            sys.exit(0)

sys.exit(1)
PY"

check "secure-app uses digest and label" "python3 - <<'PY'
import json, subprocess, sys
raw = subprocess.check_output(['kubectl','-n','secure','get','deploy','secure-app','-o','json'])
obj = json.loads(raw)
pt = obj['spec']['template']
labels = pt.get('metadata', {}).get('labels', {})
if labels.get('cosign-verified') != 'true':
    sys.exit(1)
imgs = [c.get('image','') for c in pt['spec'].get('containers', [])]
if not imgs or any('@sha256:' not in i for i in imgs):
    sys.exit(1)
PY"

exit $fail
