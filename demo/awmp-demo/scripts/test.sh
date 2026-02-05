#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Expect ok to pass
"$ROOT_DIR/scripts/ok.sh" >/tmp/awmp_demo_ok.out

# Expect fail to fail
set +e
"$ROOT_DIR/scripts/fail.sh" >/tmp/awmp_demo_fail.out 2>/tmp/awmp_demo_fail.err
code=$?
set -e

if [[ "$code" -eq 0 ]]; then
  echo "FAIL: expected scripts/fail.sh to exit non-zero" >&2
  exit 1
fi

if ! rg -q "Chaos: forced failure" /tmp/awmp_demo_fail.err; then
  echo "FAIL: expected error message in stderr" >&2
  cat /tmp/awmp_demo_fail.err >&2 || true
  exit 1
fi

echo "OK: awmp-demo test" 
