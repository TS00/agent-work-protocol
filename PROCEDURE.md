# Procedure: Defining an Experiment (Ideal Workflow)

This document defines the *ideal workflow* for turning an ambiguous idea into a crisp, written experiment scope in this repo.

## Roles

- **Builder (default: Ciz)**: drafts scope and produces artifacts.
- **Reviewer (default: Kit)**: challenges ambiguity, refines scope, and approves the final scope.
- **Principal (Human / Ed)**: tie-breaker on disputed decisions; owns final intent.

(Agents can be humans or software agents; the point is having two independent passes.)

---

## Inputs

- A rough goal (“we want to prove X”) and any motivating examples.
- Constraints (timebox, security posture, what must not happen).

---

## Operating cadence (A/B collaboration)

To avoid silent drift, each agent message in the scope-definition workflow should end with:

- **Completed:** what I just finished (1–3 bullets)
- **Next:** what I’m doing next (1–3 bullets)
- **Blocked:** what I need from the other agent (if anything)

**Rule:** If blocked on external input, **do not idle**—move to the next highest-priority unblocked task and note the block.

**Rule:** Agents do not need an explicit “proceed” from the Principal. Continue autonomously unless blocked by external human input or a risk/intent decision requiring escalation.

### Chunking + checkpoints (required for long-running tasks)

If a task will take more than ~10–15 minutes, agents must split it into chunks.

- **Chunk size:** 15–30 minutes.
- **Checkpoint:** after each chunk, post an update using Completed/Next/Blocked.
- **Long-running commands:** if a build/test/run is still executing at the 30-minute mark, post a “still running” checkpoint with:
  - what command is running
  - when the next checkpoint will be

This is lightweight status, not a long report. The goal is keeping A and B synchronized.

---

## Outputs (definition of done)

A scope is "done" when the repo contains:

1) `EXPERIMENT.md`
   - purpose
   - in-scope / out-of-scope
   - success criteria (must-have / nice-to-have)
   - minimal evidence bundle requirements

2) At least one canonical job example (e.g. `examples/*.json`)
   - machine-checkable acceptance tests (commands + expected outcomes)
   - clear mapping between criteria and tests

3) Repo entrypoints updated
   - `README.md` links to the experiment doc and the canonical example

---

## Workflow

### Step 0 — Timebox + decision policy
- Timebox the scope-definition pass (e.g. 30–60 minutes).
- Prefer agent-only resolution. Human escalation is the *last* path.

**Default decision rule (agent-only):** Agent B decides whether the draft is *clear enough to ship*, using the tie-breakers below.

**Tie-breakers (in order):**
1) **Text wins**: if it’s not written in the scope, it’s not assumed.
2) **Safety wins**: choose the option with less access, less blast radius, fewer secrets.
3) **Determinism wins**: prefer the option with more reproducible verification.
4) **Reversibility wins**: prefer the smaller, easier-to-roll-back change.
5) **Timebox wins**: prefer what can be completed inside the timebox.

**Escalation:** only if A and B disagree on *intent* or *risk tolerance* and cannot converge after **2 iterations + 1 spike** (see below).

### Step 1 — Builder proposes scope (Draft 1)
Builder produces a draft containing:

- **Experiment name** (short, memorable)
- **Purpose** (1–2 sentences)
- **What we are proving** (the core loop)
- **In-scope** (3–7 bullets)
- **Out-of-scope** (3–10 bullets, explicit)
- **Success criteria** (must-have + nice-to-have)
- **Demo fixture** (if any), labeled clearly as either:
  - *fixture* (deterministic lever), or
  - *goal* (what we’re actually building)

### Step 2 — Reviewer reviews + refines (Review 1)
Reviewer checks for:

- Ambiguity (“what does success mean?”)
- Hidden scope creep (security claims, production access, secrets)
- Non-testable acceptance criteria
- Confusion between *fixture* and *outcome*

Agent B responds with:

- required edits
- optional edits
- explicit questions that must be answered

### Step 3 — Builder revises (Draft 2)
Builder incorporates changes and:

- writes/updates `EXPERIMENT.md`
- updates/creates the canonical job JSON
- cross-links in `README.md`

### Step 4 — Reviewer approval
Reviewer either:

- **Approves** (scope is crisp; success criteria are testable), or
- **Requests another revision** (one more iteration), or
- **Calls for a spike** (agent-only) if facts are missing.

### Step 5 — Spike (agent-only, resolves factual disagreement)
If the disagreement is primarily about *what will work* (not intent), run a short spike (15–30 min):

- Builder implements the smallest proof (e.g., a tiny example, a script stub, or a sample evidence bundle).
- Reviewer attempts to run it from scratch.
- Update the scope based on what actually happened.

### Step 6 — Escalation (last resort)
Escalate to the Principal only if:

- the disagreement is about **intent** (what we’re trying to prove), or
- the disagreement is about **risk tolerance** (what is acceptable), or
- agents cannot converge after **2 iterations + 1 spike**, or
- **external human input is required** (e.g., credentials/keys/secrets are not available to agents; required env vars are unknown; approvals or access grants must be issued by a human; any action requires an owner/operator to run it).

When escalating, produce a short decision note:
- point of disagreement
- options with tradeoffs
- recommendation from Builder and Reviewer

Principal chooses one.

---

## Guidance: what “good” looks like

- **Outcome-first**: define what artifact(s) exist when the experiment is done.
- **Testability**: every success criterion should map to a command, check, or artifact.
- **Modest claims**: don’t imply “secure sandbox” unless we actually implement it.
- **Fixture clarity**: fixtures are allowed, but must be labeled *fixture, not goal*.

---

## Where this procedure is used

Any time we add an experiment, demo, or phase plan to AWMP / Agent Work Protocol.
