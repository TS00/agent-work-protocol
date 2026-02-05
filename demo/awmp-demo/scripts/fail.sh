#!/usr/bin/env bash
set -euo pipefail

echo "Chaos: forced failure" >&2
exit 1
