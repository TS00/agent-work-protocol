# Pod UI Spec — Control Tower + Spectator Dashboard

## Intro
A **Work Pod** is a structured multi-agent collaboration session that executes a shared work plan under a pod protocol (roles, checkpoints, decision rules, escalation rules). Even if agent↔agent comms are primary, humans (and other agents) need **oversight**: what’s happening, what changed, why decisions were made, and when human input is required.

This UI is primarily a **spectator surface** (read-only) with a focused **interrupt channel** for escalations.

Design goals:
- **Observable progress**: tasks, owners, status, last checkpoint.
- **Auditability**: append-only tape of checkpoints/decisions + links to evidence bundles.
- **Low-latency interrupts**: escalations notify humans promptly.
- **Protocol-shaped**: UI reflects the pod protocol (Completed/Next/Blocked, tie-breakers, spike/escalation).

Non-goals (v0/v1): perfect agent “chat UI”, complex identity/reputation, full marketplace discovery.

---

## Core Concepts (data model, minimal)
- **Pod**: id, name, goal, protocolVersion, members (role + agent id), createdAt.
- **Plan**: list of tasks with state (Backlog/In Progress/Review/Done/Blocked), assignee, acceptance refs.
- **Event tape (append-only)**: checkpoint | decision | evidence | escalation | reviewResult.
- **Evidence bundle**: link/path + hashes + verdict + command transcript.
- **Escalation**: reason code, what’s needed, suggested options, deadline/urgency.

---

## V0 — Spectator Dashboard (functional minimum)

### Primary user story
“I want to watch a pod execute a plan, see steady progress, and be alerted when human input is required.”

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
  - Escalation: what’s needed + reason code

4) **Escalations Inbox (Needs Human)**
- Separate list of outstanding escalations
- Each escalation includes:
  - reason code (e.g., NEEDS_SECRET, NEEDS_APPROVAL, INTENT_CLARIFICATION)
  - requested input, suggested options, urgency

### Notifications (v0)
- Push/desktop notifications for:
  - new escalation
  - “stuck” (no checkpoint for N minutes)
  - milestone/task approved

### V0 implementation note
V0 can read from:
- `PLAN.md` (or structured plan JSON)
- `pod_events.jsonl` (append-only events)
- `evidence/**` folders for artifacts

---

## V1 — Control Tower + Evidence Viewer

Add light interaction while keeping most UI read-only.

### Additions
1) **Evidence Viewer**
- Render `commands.jsonl`, stdout/stderr logs, `hashes.txt`, verdict
- Diff/PR link preview when present

2) **Escalation resolution (human input)**
- Provide input (text / secret reference)
- Approve/deny an action
- Close escalation with rationale (logged as an event)

3) **Role-aware views**
- Reviewer view emphasizes: verification steps, repro instructions, evidence
- Orchestrator view emphasizes: staleness, blocked tasks, reassignment suggestions

4) **Reputation hooks (display-only)**
- Show agent stats in header (past verified jobs, reviewer approvals, dispute rate) from an external directory (not built here)

---

## Event Types (recommended)
- `checkpoint`: {taskId, actor, completed[], next[], blocked[]}
- `decision`: {topic, choice, rationale, tiebreakersUsed[]}
- `evidence`: {jobId, runId, verdict, hashesRef}
- `escalation`: {reasonCode, needed, options[], urgency}
- `review`: {taskId, outcome: approve|reject, notes}
