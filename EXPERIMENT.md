# Experiment: Option A — “Verification Kernel”

## Purpose
Prove that AWMP can drive a **minimal, end-to-end, trust-minimized job lifecycle**:

**Job spec (contract) → execution → independent verification → evidence bundle → settlement decision**

This experiment deliberately prioritizes **deterministic verification** over sophisticated sandboxing.

---

## What we are building (in-scope)

### 1) A canonical demo job
A single `awmp.job` example that a human can read and an executor can run.

- The job must have **explicit acceptance tests** (commands + expected outcomes).
- The job must have **objective criteria** that map to those tests.

### 2) A verifier run concept (even if manual at first)
A repeatable procedure (later: a CLI) that:

- starts from a **clean workspace** (fresh checkout / clean container)
- runs the job’s acceptance tests exactly as specified
- produces a **pass/fail verdict**
- emits an **evidence bundle** sufficient for a third party to audit

### 3) An evidence bundle definition (minimum viable)
An agreed list of artifacts to capture every time verification runs.

### 4) A settlement decision rule
A simple policy:

- **If verification passes** → `Decision=accept` → escrow release allowed
- **If verification fails** → `Decision=reject` → escrow release blocked

(Disputes/arbitration are out-of-scope for this experiment beyond “evidence exists”.)

---

## What we are NOT building (out-of-scope)

- Market dynamics: bidding, ranking, matching, reputation
- General-purpose secure compute / TEEs
- Broad secret brokerage or production credentials
- Running arbitrary untrusted workloads with open egress
- Multi-repo / multi-language generality

We will keep security claims modest: **fresh environment + deterministic verification + evidence capture**.

---

## Demo fixture: “Chaos Fault” (clarification)

The **Chaos Fault** is a *fixture* (a deterministic pass/fail lever), not the goal.

It exists to prove the verification kernel works:

- Fault ON → health endpoint should fail (500) in a recognizable way
- Fault OFF → health endpoint should pass (200)

The experiment’s outcome is the **verifier + evidence + decision rule**, not the feature itself.

---

## Success criteria

### Must-have
- The same job run in two fresh environments produces the same verdict.
- Acceptance is determined by the verifier (objective), not by the worker’s claim.
- Evidence bundle is sufficient to explain *why* pass/fail.
- The job spec is understandable by a human without reading protocol internals.

### Nice-to-have
- Verifier runs inside a minimal Docker container (fresh env story).
- A second demo job to show the pattern generalizes.

---

## Evidence bundle (minimum)
Capture these artifacts for every verification run:

- `job.json` (the exact AWMP job object)
- `environment.json` (timestamp, OS/tool versions, repo URL + commit SHA)
- `commands.jsonl` (each command executed + start/stop + exit code)
- `stdout.log` / `stderr.log` (or per-command logs)
- `artifacts/` (any test output files; e.g., curl bodies, junit, screenshots)
- `hashes.txt` (sha256 of the above files)

---

## Where to look
- Protocol overview: `rfcs/0001-awmp.md`
- Schemas: `schemas/`
- Demo job: `examples/pr_for_escrow_job.json`
