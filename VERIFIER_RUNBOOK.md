# Verifier Runbook (Manual) — Verification Kernel Experiment

This runbook describes how to run the **canonical demo job** and produce a minimal evidence bundle.

> Target repo: this repo (`agent-work-protocol`) demo fixture at `demo/awmp-demo/`.

## 0) Preconditions
- You have a clean checkout of this repo.
- You have: `bash`, `make`, `rg` available.

## 1) Identify the job to verify
- Job spec: `examples/pr_for_escrow_job.json`
- Extract `job.id` and acceptance `tests[]`.

## 2) Create an evidence bundle folder
Choose a run id (timestamp):

```bash
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
JOB_ID="job_demo_verification_kernel_0001"
OUT="evidence/${JOB_ID}/${RUN_ID}"
mkdir -p "$OUT/logs" "$OUT/artifacts"
cp examples/pr_for_escrow_job.json "$OUT/job.json"
```

Record environment info:

```bash
echo "{\n  \"runId\": \"$RUN_ID\",\n  \"jobId\": \"$JOB_ID\",\n  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\n  \"gitCommit\": \"$(git rev-parse HEAD)\",\n  \"uname\": \"$(uname -a | sed 's/\\"/\\\\\"/g')\"\n}" > "$OUT/environment.json"
```

## 3) Run acceptance tests (capture logs + command transcript)

Create a structured command transcript file (JSON Lines):

```bash
: > "$OUT/commands.jsonl"
```

Helper to append command events:

```bash
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
```

Then run each test via `log_cmd`.


### Test 1 — ok path
```bash
log_cmd "01_make_ok" "cd demo/awmp-demo && make ok"
```

### Test 2 — fail path (expected non-zero)
```bash
set +e
log_cmd "02_make_fail" "cd demo/awmp-demo && make fail"
CODE=$?
set -e

echo "exitCode=$CODE" > "$OUT/artifacts/02_make_fail_exit_code.txt"

if [[ "$CODE" -eq 0 ]]; then
  echo "VERIFIER_FAIL: expected make fail to exit non-zero" | tee "$OUT/verdict.txt"
  exit 1
fi

if ! rg -q "Chaos: forced failure" "$OUT/logs/02_make_fail.log"; then
  echo "VERIFIER_FAIL: expected 'Chaos: forced failure' in stderr/log" | tee "$OUT/verdict.txt"
  exit 1
fi
```

### Test 3 — test harness asserts both
```bash
log_cmd "03_make_test" "cd demo/awmp-demo && make test"
```

## 4) Verdict
If all checks above complete:

```bash
echo "VERIFIER_PASS" | tee "$OUT/verdict.txt"
```

## 5) Hash manifest (tamper-evident-ish)
```bash
(
  cd "$OUT"
  find . -type f -maxdepth 4 -print0 | sort -z | xargs -0 sha256sum
) > "$OUT/hashes.txt"
```

## 6) What to submit
- The evidence folder: `evidence/<jobId>/<runId>/`
- A decision statement:
  - PASS → accept
  - FAIL → reject
