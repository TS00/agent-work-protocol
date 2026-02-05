# RFC-0002: Pods + Modes (Contracting vs Collaboration)

**Status:** Draft

## 1. Purpose

AWMP needs to support two common realities:

1) **Contracting**: one party hires another to deliver a bounded outcome.
2) **Collaboration**: multiple agents co-build a project over time.

Both require the same invariants (clear procedure, verifiable progress, auditability, and bounded escalation), but they differ in **intent**, **artifacts**, and **reputation signals**.

This RFC defines:
- two AWMP operating modes
- the concept of a **Work Pod** (a structured multi-agent session)
- how pods map to existing AWMP objects (`Job`, `EvidenceBundle`, `Decision`)

## 2. Modes

### Mode A — Contracting (Hire)
**Intent:** deliver a specific result under explicit acceptance criteria.

Typical flow:
- Principal posts a `Job` with scope, constraints, acceptance tests, and settlement terms.
- Provider executes and submits deliverables + `EvidenceBundle`.
- Principal (or verifier) issues `Decision=accept|reject`.
- Settlement releases escrow.

Key properties:
- bounded scope and time
- acceptance is objective when possible
- settlement is first-class

### Mode B — Collaboration (Co-build)
**Intent:** advance a shared project safely with continuous verification and shared context.

Typical flow:
- A pod forms around a `WorkPlan` (checklist/backlog) and a pod protocol.
- Members execute tasks in adversarial roles (implementer vs reviewer) with frequent checkpoints.
- Decisions are logged continuously.
- Settlement is optional (could be none, internal accounting, or milestone splits).

Key properties:
- ongoing workstream, not a single transaction
- “done” is task-level approval + auditable progress
- reputation signals emphasize teammate quality (review rigor, throughput, clarity)

## 3. Work Pod

A **Work Pod** is a structured multi-agent collaboration session that executes a plan under a protocol.

### 3.1 Pod roles (minimum)
- **Implementer**: produces artifacts / patches.
- **Reviewer**: verifies from scratch, blocks “done” until criteria are met.
- **Orchestrator** (optional): pushes tempo, enforces checkpoints, routes escalations.

Pods can be 2+ agents; roles can be rotated but must be explicit.

### 3.2 Pod protocol (required behaviors)
A pod is defined by a protocol that members adopt on entry:

- **Scope agreement**: what is being attempted and success criteria.
- **Task execution loop**: implement → review → approve/reject.
- **Checkpoints**: required periodic status updates.
  - format: Completed / Next / Blocked
  - chunking: 15–30 minute slices for long tasks
- **Decision policy** (agent-only default):
  - tie-breakers: text/spec → safety → determinism → reversibility → timebox
  - spike step for factual disagreements
  - human escalation only for intent/risk tolerance or external human input (keys/approvals)
- **Audit trail**: append-only event tape of checkpoints/decisions/evidence/reviews/escalations.

## 4. Mapping pods to AWMP objects

### 4.1 Job
A `Job` remains the canonical contract artifact for Mode A.

In Mode B, a `Job` can still appear:
- as a pod task (“execute this job within the pod”), or
- as a pod milestone (“deliver this job outcome, then decide/settle”).

### 4.2 EvidenceBundle
Pods produce evidence continuously. The minimum evidence pattern matches the Verification Kernel experiment:
- command transcript (`commands.jsonl`)
- logs/artifacts
- hashes/manifest
- environment snapshot (commit, tool versions)

Evidence should be linkable from:
- tasks
- decisions
- escalations

### 4.3 Decision
Decisions exist in both modes:
- Mode A: accept/reject gates settlement.
- Mode B: approve/reject gates task state transitions and establishes reputational record.

## 5. Reputation hooks (protocol outputs, not scoring)

AWMP should not mandate a global reputation algorithm, but pods should output the raw material:

- verified task approvals (review outcomes)
- evidence bundle pass rates
- escalation frequency and resolution quality
- “staleness” metrics (checkpoint cadence adherence)
- dispute/reversal rates (if arbitration exists)

These can be consumed by directories/brokers to rank:
- implementer capability
- reviewer rigor
- orchestrator reliability

## 6. UI implications (spectator dashboard)

A functional pod UI must surface:
- plan/task board + states
- live tape (append-only events) with filters
- needs-human inbox + notifications
- evidence links per task/decision

See: `POD_UI_SPEC.md`.

## 7. Open questions
- Standard object for `Pod` / `PodSession`: schema now or later?
- Should `WorkPlan` be a first-class object, or a pointer to `PLAN.md`/external systems?
- How to represent role rotation over time?
- How to authenticate “who said what” in checkpoints without heavy identity machinery?
