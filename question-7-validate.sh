#!/usr/bin/env bash
set -euo pipefail

fail=0

check() {
  local name="$1"
  if ! eval "$2"; then
    echo "FAIL: $name" >&2
    fail=1
  else
    echo "PASS: $name"
  fi
}

runtime=""
if command -v docker >/dev/null 2>&1; then
  runtime=docker
elif command -v podman >/dev/null 2>&1; then
  runtime=podman
else
  echo "missing container runtime (docker/podman)" >&2
  exit 1
fi

image=registry.local/hardened-web:1.0

check "image exists" "$runtime image inspect $image >/dev/null 2>&1"

check "image runs as non-root" "python3 - <<PY
import json, subprocess, sys
info = json.loads(subprocess.check_output(['$runtime','image','inspect','$image']))[0]
user = info.get('Config', {}).get('User', '')
if not user or user in ('0', 'root'):
    sys.exit(1)
PY"

check "no package manager in image" "bash -c '\
set +e\
$out=$($runtime run --rm --entrypoint /bin/sh $image -c "command -v apt-get apk yum dnf microdnf" 2>/dev/null); rc=$?;\
if [ $rc -ne 0 ]; then exit 0; fi;\
if [ -n "$out" ]; then exit 1; fi;\
exit 0\
'"

check "sbom present" "test -s /home/student/answers/q7-sbom.json"

exit $fail
