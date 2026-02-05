#!/usr/bin/env bash
set -euo pipefail

JOB_PATH="${1:-}"
if [[ -z "$JOB_PATH" ]]; then
  echo "Usage: $0 <path/to/job.json>" >&2
  exit 2
fi
if [[ ! -f "$JOB_PATH" ]]; then
  echo "Missing job file: $JOB_PATH" >&2
  exit 2
fi

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 2; }; }
need jq
need sha256sum
need tee

JOB_ID="$(jq -r '.id' "$JOB_PATH")"
if [[ -z "$JOB_ID" || "$JOB_ID" == "null" ]]; then
  echo "Job id missing in $JOB_PATH" >&2
  exit 2
fi

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="evidence/${JOB_ID}/${RUN_ID}"
mkdir -p "$OUT/logs" "$OUT/artifacts"

cp "$JOB_PATH" "$OUT/job.json"

echo "{\n  \"runId\": \"$RUN_ID\",\n  \"jobId\": \"$JOB_ID\",\n  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\n  \"gitCommit\": \"$(git rev-parse HEAD 2>/dev/null || echo unknown)\",\n  \"uname\": \"$(uname -a | sed 's/\\"/\\\\\"/g')\"\n}" > "$OUT/environment.json"

: > "$OUT/commands.jsonl"

log_cmd() {
  local name="$1"; shift
  local cmd="$*"
  local start end code
  start="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "{\"event\":\"start\",\"name\":\"$name\",\"command\":\"$cmd\",\"ts\":\"$start\"}" >> "$OUT/commands.jsonl"

  bash -lc "$cmd" 2>&1 | tee "$OUT/logs/${name}.log"
  code=${PIPESTATUS[0]}

  end="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "{\"event\":\"end\",\"name\":\"$name\",\"exitCode\":$code,\"ts\":\"$end\"}" >> "$OUT/commands.jsonl"
  return $code
}

# Run all tests. For expected failures, the job spec should encode expectations.
# For v0 we interpret expected outcomes with a simple convention:
# - if expected contains "exit non-zero" then non-zero is pass
# - otherwise expected is exit 0

FAIL=0
idx=0
jq -c '.acceptance.tests[]' "$JOB_PATH" | while read -r t; do
  idx=$((idx+1))
  name="$(echo "$t" | jq -r '.name')"
  cmd="$(echo "$t" | jq -r '.command')"
  expected="$(echo "$t" | jq -r '.expected')"

  safe_name=$(printf '%02d_%s' "$idx" "$name" | tr ' /' '__' | tr -cd '[:alnum:]_\-')

  set +e
  log_cmd "$safe_name" "$cmd"
  code=$?
  set -e

  if echo "$expected" | rg -q "exit non-zero"; then
    if [[ "$code" -eq 0 ]]; then
      echo "FAIL: $name expected non-zero exit" | tee -a "$OUT/verifier_errors.log" >&2
      FAIL=1
    fi
  else
    if [[ "$code" -ne 0 ]]; then
      echo "FAIL: $name expected exit 0" | tee -a "$OUT/verifier_errors.log" >&2
      FAIL=1
    fi
  fi

done

# shellcheck disable=SC2034
if [[ "$FAIL" -eq 0 ]]; then
  echo "VERIFIER_PASS" | tee "$OUT/verdict.txt"
else
  echo "VERIFIER_FAIL" | tee "$OUT/verdict.txt"
fi

(
  cd "$OUT"
  find . -type f -maxdepth 4 -print0 | sort -z | xargs -0 sha256sum
) > "$OUT/hashes.txt"

[[ "$FAIL" -eq 0 ]]
