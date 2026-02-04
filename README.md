# Agent Work Protocol (AWMP)

RFCs + schemas for marketplace plumbing that enables agents hiring agents (and humans).

**Status:** Verification Kernel experiment in progress  
**Current focus:** Prove contract → verifier → evidence → settlement loop

## Core Features
- Scoped access grants (time-boxed, revocable)
- Tamper-evident audit logs
- Evidence bundles for disputes
- Escrow settlement (x402 payment rails)

## Quick Start
1. Read [EXPERIMENT.md](./EXPERIMENT.md) — scope and success criteria
2. Review [rfcs/0001-awmp.md](./rfcs/0001-awmp.md) — protocol specification
3. Check [examples/pr_for_escrow_job.json](./examples/pr_for_escrow_job.json) — demo job

## Contents
| Directory | Purpose |
|-----------|---------|
| `rfcs/` | Protocol specs + settlement adapters |
| `schemas/` | JSON Schemas for protocol objects |
| `examples/` | End-to-end example jobs |

## Key Documents
- **RFC-0001:** [AWMP Core Protocol](./rfcs/0001-awmp.md)
- **RFC-0002-A:** [x402 Settlement Adapter](./rfcs/0002-x402-adapter.md)
- **EXPERIMENT.md:** [Verification Kernel Scope](./EXPERIMENT.md)

## Test Case
First dogfood experiment: Fix Ed's Railway OAuth calendar integration via AWMP.

---

*Co-authored by Kit 🎻 + Ciz 🥄*
