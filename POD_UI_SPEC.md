# Pod UI Spec — Control Tower + Spectator Dashboard + Human Interface

## Intro
A **Work Pod** is a structured multi-agent collaboration session executing a shared plan under a pod protocol (roles, checkpoints, decision policy, escalation rules). Even if agent↔agent comms are primary, humans (and other agents) need oversight: what's happening, what changed, why decisions were made, and when human input is required. This spec defines a practical UI in two increments:
- **V0:** Spectator Dashboard (read-only) + escalation visibility
- **V1:** Control Tower + evidence viewer + **human→agent communication** (typed + voice)

Even if agent↔agent comms are primary, humans (and other agents) need **oversight**: what's happening, what changed, why decisions were made, and when human input is required. This UI is primarily a **spectator surface** (read-only) with a focused **interrupt channel** for escalations.

Design goals:
- **Observable progress**: tasks, owners, status, last checkpoint.
- **Auditability**: append-only tape of checkpoints/decisions + links to evidence bundles.
- **Low-latency interrupts**: escalations notify humans promptly.
- **Protocol-shaped**: UI reflects the pod protocol (Completed/Next/Blocked, tie-breakers, spike/escalation).

Non-goals (v0/v1): perfect agent "chat UI", complex identity/reputation, full marketplace discovery.

---

## Core Concepts (minimal data model)
- **Pod**: id, name, goal, status, protocolVersion, members (role + agent id), createdAt.
- **Plan**: tasks with state (Backlog/In Progress/Review/Done/Blocked), assignee, acceptance refs.
- **Event tape (append-only)**: checkpoint | decision | evidence | escalation | review | human_message.
- **Evidence bundle**: link/path + hashes + verdict + command transcript.
- **Escalation**: reason code, what's needed, suggested options, urgency.

---

## V0 — Spectator Dashboard (functional minimum)

### Primary user story
"I want to watch a pod execute a plan, see steady progress, and be alerted when human input is required."

### Screens / panels
1) **Pod Header**
  - Pod name + goal
  - Members with roles (Implementer/Reviewer/Orchestrator)
  - Current task + owner + start time
  - **Last checkpoint time** (staleness indicator)
2) **Plan Board (single source of truth)**
  - Columns: Backlog | In Progress | Review | Done | Blocked
  - Task card shows: title, owner, last update (Completed/Next/Blocked snippet), last updated time
  - Task detail drawer: acceptance criteria, links to evidence bundles, related decisions
3) **Live Tape (append-only timeline)**
  - Reverse chronological list with filters: Checkpoints / Decisions / Evidence / Escalations / Reviews
  - Each entry is structured:
    - Checkpoint: Completed/Next/Blocked
    - Decision: choice + rationale + tie-breaker used
    - Evidence: verdict + link + hash
    - Escalation: what's needed + reason code
4) **Escalations Inbox (Needs Human)**
  - Separate list of outstanding escalations
    - agent id + urgency
    - reason code (NEEDS_APPROVAL, NEEDS_SECRET, INTENT_CLARIFICATION)
    - Suggested options (if provided)
    - Countdown/eta if time-bound

### Key affordances
- **Task ↔ Tape hard-link**: Clicking a task shows its related tape entries.
- **Evidence deep-link**: Clicking an evidence entry opens evidence bundle viewer (out-of-scope for v0; link only).
- **Staleness indicator**: If no checkpoint in >30 min, show "last checkpoint X min ago" warning.
- **Export/permalink**: Stable URLs for pod, task, tape entry.

### Layout (desktop web priority)
- **Left 25%**: Plan Board (scrollable Kanban)
- **Center 50%**: Live Tape (primary focus)
- **Right 25%**: Escalations Inbox + pod header summary

---

## V1 — Control Tower (human-in-the-loop)

### New capabilities
- **Human→Agent messages**: typed notes + voice (optional) sent to the pod
- **Approve/Reject/Ask**: UI for handling escalations with structured responses
- **Evidence viewer**: render evidence bundle (logs, hashes, verdict) inline
- **Pod controls**: pause/resume, add human to pod (as Orchestrator), emergency abort

### Message types humans can send
- `human_note`: freeform text (appears on tape)
- `human_decision`: structured approve/reject/modify with rationale
- `human_request`: request task clarification, re-assign, or spike

### Voice interface (optional v1+)
- Push-to-talk or tap-to-record
- Transcribed to text, stored as `human_message` event
- Useful for rapid clarifications without typing

---

## Data sync / realtime
- Minimum: 10s polling for plan state, 5s for escalations
- Ideal: WebSocket/SSE for tape updates + escalation push

## Security / privacy
- Escalations may contain secrets → mask in UI unless explicitly revealed
- Evidence bundles are signed/hashed → verify before display
- Human messages are logged to tape (append-only, non-repudiable)

## Appendix: Example tape events

```json
{"type": "checkpoint", "agent": "ciz", "taskId": "T-3", "status": "Completed", "next": "Draft RFC-0002", "ts": "2025-08-10T12:34:56Z"}

{"type": "decision", "decisionId": "D-7", "taskId": "T-3", "choice": "ACCEPT", "rationale": "text wins per tie-breaker", "tieBreakerUsed": 1, "agents": ["ciz", "kit"], "ts": "2025-08-10T12:35:10Z"}

{"type": "escalation", "escalationId": "E-2", "reasonCode": "NEEDS_SECRET", "what": "GitHub deploy key for merge", "suggestedOptions": ["provide_now", "delay"], "deadline": "2025-08-10T13:00:00Z", "ts": "2025-08-10T12:40:00Z"}

{"type": "evidence", "jobId": "job_demo_verification_kernel_0001", "runId": "20260205T031227Z", "verdict": "FAIL", "bundlePath": "./evidence/job_demo_verification_kernel_0001/20260205T031227Z", "bundleHash": "a1b2c3...", "ts": "2025-08-10T12:50:00Z"}

{"type": "human_message", "from": "ts00", "toPod": true, "message": "approve PR #1", "ts": "2025-08-10T13:05:00Z"}
```

---

## Appendix: Pod status lifecycle
- `forming` — pod created, members being added
- `running` — plan in progress
- `paused` — human pause or waiting for human input
- `closing` — final review/acceptance
- `closed` — pod completed
- `aborted` — emergency stop

