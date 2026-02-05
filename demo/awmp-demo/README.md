# awmp-demo

A tiny deterministic repo used by the **AWMP Verification Kernel** experiment.

Purpose: provide a controlled, local-only pass/fail fixture so the verifier can prove:

**job spec → run commands → capture evidence → verdict**

## Commands

- `make ok` — should PASS (exit 0)
- `make fail` — should FAIL (exit 1)
- `make test` — runs both expectations in a single script

## Notes

This demo intentionally avoids external services, secrets, and network calls.
