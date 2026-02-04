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
