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

manifest=/etc/kubernetes/manifests/kube-apiserver.yaml
check "apiserver manifest exists" "test -f $manifest"
check "anonymous auth disabled" "grep -q -- '--anonymous-auth=false' $manifest"
check "RBAC enabled" "grep -q -- '--authorization-mode=.*RBAC' $manifest"
check "TLS min version set" "grep -q -- '--tls-min-version=VersionTLS12' $manifest"
check "TLS cipher suites set" "grep -q -- '--tls-cipher-suites=' $manifest"

check "apiserver healthy" "kubectl get --raw /healthz 2>/dev/null | grep -qi '^ok'"

answers=/home/student/answers/q1-authz.txt
check "authz check saved" "test -f $answers"
check "authz denies secrets" "grep -qi '^no$' $answers"

exit $fail
