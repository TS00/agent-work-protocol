# PLAN — Verification Kernel Experiment (Option A)

This plan is the tracking checklist for the AWMP **Verification Kernel** experiment.

**Goal:** Prove the minimal trust loop works:

**Job spec (contract) → execution → independent verification → evidence bundle → decision/settlement gate**

**Meta rule:** Two-agent adversarial workflow.
- **Ciz (Builder/Proposer)** produces artifacts.
- **Kit (Reviewer/Approver)** tries to run them from scratch, finds ambiguity, blocks “done” until reproducible.
- Escalate to Principal (Ed) if A/B can’t converge in 2 iterations.

---

## Phase 0 — Scope lock (done)
- [x] Write experiment scope and success criteria → `EXPERIMENT.md`
- [x] Write ideal workflow → `PROCEDURE.md`
- [x] Link from `README.md`

---

## Phase 1 — Canonical demo job (in progress)

**Canonical target repo:** `demo/awmp-demo/` (in-repo) whose only purpose is to make verification deterministic and onboarding trivial.

### 1.1 Canonical job spec
- [x] Create canonical job JSON → `examples/pr_for_escrow_job.json`
- [x] (Agent B) Review job spec for ambiguity and missing prerequisites
  - [x] Are setup steps required (repo checkout, env files) explicitly stated?
  - [x] Do the tests actually prove each criterion?
  - [x] Is “fixture vs outcome” unmissable?

### 1.2 Job prerequisites doc (make it runnable)
**Owner:** Kit (author) · Ciz (review/fix)
- [ ] Add a short prerequisites section (either in `EXPERIMENT.md` or in the job `scope.details`)
  - [ ] Update target repo wording to `agent-work-protocol` → `demo/awmp-demo` (remove ParentAll references)
  - [ ] Required local tooling (bash, make, rg, jq)

---

## Phase 2 — Evidence bundle (definition + example)

### 2.1 Evidence bundle spec (minimum)
- [x] Define concrete evidence layout (files + meanings)
  - [x] job snapshot
  - [x] environment snapshot (repo + commit SHA)
  - [x] command transcript (cmd/start/stop/exit)
  - [x] logs + artifacts
  - [x] hashes/manifest

### 2.2 Example evidence bundle
- [~] Commit an example evidence bundle for a PASS and a FAIL
  - [x] PASS folder (generated locally under `evidence/job_demo_verification_kernel_0001/...`)
  - [x] FAIL folder (synthetic example under `evidence/job_demo_verification_kernel_0001/synthetic_fail_...`)

(If we don’t want to commit large logs, commit a small synthetic example + document where real bundles live.)

---

## Phase 3 — Verifier (manual → scripted)

### 3.1 Manual verifier runbook
- [x] Write `VERIFIER_RUNBOOK.md` (step-by-step, no mind-reading)
- [x] (Agent B) Execute runbook exactly as written and report gaps

### 3.2 Scripted verifier
**Owner:** Ciz (implement) · Kit (break/approve)
- [ ] Implement `scripts/verify-job.sh` (or minimal CLI) that:
  - [ ] accepts a job JSON path
  - [ ] runs the acceptance tests
  - [ ] captures evidence bundle to `./evidence/<jobId>/<timestamp>/...`
  - [ ] returns non-zero on failure
- [ ] (Agent B) Try to break it (missing deps, failing tests, partial runs)

---

## Phase 4 — Decision gate (accept/reject)

### 4.1 Decision artifact
**Owner:** Kit (author) · Ciz (wire-up)
- [ ] Define a minimal `Decision` object (even if not yet schematized)
  - [ ] accept/reject
  - [ ] pointer to evidence bundle hash/runId
  - [ ] optional rationale

### 4.2 Gate rule
**Owner:** Kit (author) · Ciz (demo)
- [ ] Document the rule: “Verifier PASS is required for ACCEPT”
- [ ] Demonstrate both paths:
  - [ ] PASS → accept
  - [ ] FAIL → reject

---

## Phase 5 — End-to-end demo
**Owner:** Ciz (author) · Kit (cold-run/approve)

- [ ] Record a clean demo procedure:
  - [ ] Post job (select canonical job JSON)
  - [ ] Run verifier in a fresh workspace
  - [ ] Produce evidence bundle
  - [ ] Produce decision

**Exit criteria:** A new contributor can follow the demo and reproduce the same verdict.

---

## Risks / open questions
- Canonical demo target repo choice: **tiny dedicated awmp-demo repo** (fast, deterministic). ParentAll becomes Phase 2 “real repo” validation.
- Do we want verifier isolation to be “fresh git checkout” or “dockerized fresh checkout” for Phase 1?
- Where do evidence bundles live (committed examples vs artifact storage)?
