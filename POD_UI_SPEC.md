# Pod UI Spec — Spectator Dashboard + Human Interface

## Intro
A **Work Pod** is a structured multi-agent collaboration session executing a shared plan under a pod protocol (roles, checkpoints, decision policy, escalation rules). Even if agent↔agent comms are primary, humans (and other agents) need oversight: what’s happening, what changed, why decisions were made, and when human input is required.

This spec defines a practical UI in two increments:
- **V0:** Spectator Dashboard (read-only) + escalation visibility
- **V1:** Control Tower + evidence viewer + **human→agent communication** (typed + voice)

Design goals:
- **Observable progress:** plan state, owners, last checkpoint.
- **Auditability:** append-only tape of checkpoints/decisions/evidence.
- **Fast interrupts:** escalations notify humans promptly.
- **Protocol-shaped:** UI reflects Completed/Next/Blocked, tie-breakers, spike/escalation.

---

## Core Concepts (minimal data model)
- **Pod**: id, name, goal, status, protocolVersion, members (role + agent id), createdAt.
- **Plan**: tasks with state (Backlog/In Progress/Review/Done/Blocked), assignee, acceptance refs.
- **Event tape (append-only)**: checkpoint | decision | evidence | escalation | review | human_message.
- **Evidence bundle**: link/path + hashes + verdict + command transcript.
- **Escalation**: reason code, what’s needed, suggested options, urgency.

---

## V0 — Spectator Dashboard (functional minimum)

### Primary user story
“I want to watch a pod execute a plan, see steady progress, and be alerted when human input is required.”

### Panels
1) **Pod Header**
- Pod name + goal + status
- Members with roles (Implementer/Reviewer/Orchestrator)
- Current task + owner + start time
- **Last checkpoint time** (staleness indicator)
- Needs-human count

2) **Plan Board**
- Columns: Backlog | In Progress | Review | Done | Blocked
- Task card: title, owner, last update snippet (Completed/Next/Blocked), last updated
- Task detail drawer (read-only): acceptance checklist + evidence links + related decisions

3) **Live Tape (append-only)**
- Reverse chronological list with filters: Checkpoints / Decisions / Evidence / Escalations / Reviews / Human
- Each entry includes:
  - timestamp
  - actor (agent id)
  - optional taskId
  - structured fields (Completed/Next/Blocked; choice+rationale; verdict+hash; needed+reason)

4) **Needs Human Inbox**
- Outstanding escalations with: reason code, requested input, suggested options, urgency, age

### Notifications
- New escalation
- “Stuck” (no checkpoint for N minutes)
- Task/milestone approved

---

## V1 — Control Tower + Evidence Viewer + Human→Agent Interface

V1 adds light interaction while keeping most UI read-only.

### 1) Evidence Viewer
- Render: `commands.jsonl`, logs, `hashes.txt`, verdict
- Show PASS/FAIL, runId, short hash, “View bundle”

### 2) Escalation resolution (human input)
- Provide input (text / secret *reference*)
- Approve/deny
- Close escalation with rationale (logged)

### 3) Human→Agent communication (typed + voice)
Humans must be able to **select an agent** and communicate directly.

**Target selection**
- From Pod Members: choose Implementer/Reviewer/Orchestrator (or a specific agent id).
- Optional: bind message to a task.

**Typed message**
- Text composer with required category: `clarification` | `priority` | `risk` | `context`.
- Optional: “private to agent” vs “visible to pod” (default: visible to pod).

**Voice message**
- Push-to-talk recording.
- Store audio as an attachment and generate a transcript.
- Transcript + audio link are logged.

**Logging + guardrails**
- Every human→agent message emits a `human_message` tape event with:
  - targetAgentId
  - optional taskId
  - category
  - text and/or transcript
  - attachment refs
- UI encourages escalations as the primary entrypoint; freeform messages are still recorded.

---

## Recommended Event Types
- `checkpoint`: {taskId?, actor, completed[], next[], blocked[]}
- `decision`: {taskId?, topic, choice, rationale, tiebreakersUsed[]}
- `evidence`: {taskId?, runId, verdict, hashesRef}
- `escalation`: {taskId?, reasonCode, needed, options[], urgency}
- `review`: {taskId, outcome: approve|reject, notes}
- `human_message`: {taskId?, targetAgentId, category, text?, transcript?, attachments[]}
