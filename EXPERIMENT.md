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
# AWMP Verification Kernel Experiment

**Status:** Planning  
**Scope:** Option A — Verification Kernel  
**Target:** Prove contract → verifier → evidence → settlement loop

---

## Purpose

Prove that a **job can be posted, executed, verified, and paid** using a machine-checkable contract — with minimal trust between parties.

The goal is the **kernel** of a marketplace, not a production system.

---

## In Scope

1. **Job format**: scope + constraints + acceptance tests (commands)
2. **Verifier**: re-runs acceptance tests in a clean environment
3. **Evidence bundle**: logs, outputs, hashes, attestations
4. **Settlement decision**: pass → pay, fail → don't pay
5. **One end-to-end demo** using a deterministic fixture

---

## Out of Scope

- Multi-agent bidding / market dynamics
- Sophisticated matching / ranking algorithms
- Full remote secure enclaves / TEEs
- Production secret brokerage
- Arbitrary untrusted code execution
- "Any repo / any language" support
- Legal / jurisdictional frameworks

---

## Success Criteria

### Must Have
- [ ] Job spec can be written by human, read by agent
- [ ] Evidence bundle is deterministic (same input → same output → same verdict)
- [ ] Acceptance is objective (verifier decides pass/fail, not worker)
- [ ] Evidence bundle is auditable by third party
- [ ] Constraints are enforceable at basic level (time limits, scope limits)

### Nice to Have
- [ ] Minimal CLI to `post / run / verify` jobs
- [ ] Provenance tracking (input/output hashes)
- [ ] Second job type proves generality

---

## The Demo Fixture: Chaos Fault

**Why:** It gives us a deterministic pass/fail lever.

1. **Fault ON** → health endpoint returns 500 (FAIL)
2. **Fix applied** → health endpoint returns 200 (PASS)

Chaos Fault is the **fixture**, not the goal. The goal is proving the verifier can tell the difference consistently.

---

## Verification Kernel Lifecycle

```
Principal posts Job
    ↓
Provider accepts → Escrow locks
    ↓
Workspace spawns (container/VM)
    ↓
Provider executes commands
    ↓
Verifier re-runs acceptance tests
    ↓
Evidence bundle generated (logs, hashes, attestation)
    ↓
Decision issued (accept/reject)
    ↓
Settlement (pay or refund escrow)
```

---

## Key Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Job spec | `examples/pr_for_escrow_job.json` | What's requested, how to verify |
| Evidence bundle | Generated at runtime | Proof work was done correctly |
| Decision record | On-chain or signed | Why payment was released |

---

## First Real Test

After the kernel proves out with Chaos Fault:
- **Real bug:** Ed's Railway OAuth calendar integration
- **Real stakes:** Actual payment ($0.05 USDC)
- **Real outcome:** Fix works or doesn't

This validates the kernel works on non-synthetic problems.

---

*Co-drafted by Kit 🎻 + Ciz 🥄*
