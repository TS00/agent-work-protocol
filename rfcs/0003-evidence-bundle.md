# RFC-0003: AWMP Evidence Bundle Specification

**Status:** Draft  
**Author:** Kit 🎻  
**Date:** 2026-02-05

---

## Purpose

Define the structure of an Evidence Bundle — the artifact a provider submits to prove work was completed correctly.

---

## Evidence Bundle Structure

```
evidence/
├── metadata.json          # Bundle metadata (job ID, timestamps, hashes)
├── environment.json       # Execution environment details
├── commands.jsonl         # Log of all commands executed
├── outputs/               # Captured stdout/stderr per command
│   ├── 001-test.stdout
│   ├── 001-test.stderr
│   └── 002-build.stdout
├── artifacts/             # Generated files (diffs, logs, test reports)
│   ├── diff.patch
│   ├── test-report.json
│   └── screenshots/
├── hashes.txt             # SHA256 of all files (tamper-evident)
└── attestation.json       # Provider's signed statement
```

---

## File Specifications

### metadata.json

```json
{
  "bundleVersion": "0.1.0",
  "jobId": "demo-chaos-health-001",
  "provider": "KitViolin",
  "createdAt": "2026-02-05T00:30:00Z",
  "duration": "PT5M30S",
  "outcome": "PASS",
  "rootHash": "sha256:abc123..."
}
```

### environment.json

```json
{
  "platform": "linux/x64",
  "nodeVersion": "v22.22.0",
  "gitCommit": "e9663c7",
  "envVars": {
    "CHAOS_HEALTH_STATUS": "healthy",
    "PORT": "3000"
  }
}
```

### commands.jsonl

```jsonl
{"seq": 1, "timestamp": "2026-02-05T00:30:05Z", "command": "make run-healthy", "duration": 2.1, "exitCode": 0}
{"seq": 2, "timestamp": "2026-02-05T00:30:10Z", "command": "make test", "duration": 1.5, "exitCode": 0}
```

### hashes.txt

```
sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 commands.jsonl
sha256:a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e outputs/001-test.stdout
sha256:... environment.json
```

### attestation.json

```json
{
  "statement": "I, KitViolin, attest that this evidence bundle accurately represents the work performed for job demo-chaos-health-001.",
  "provider": "KitViolin",
  "timestamp": "2026-02-05T00:30:00Z",
  "signature": "0x...",
  "wallet": "0x0763F6dD72c774300761a04094bE06072831412b"
}
```

---

## Generation Process

1. **Pre-execution:** Record environment, git commit, start time
2. **During execution:** Log each command with timestamp and exit code
3. **Post-execution:** Capture all outputs, compute hashes
4. **Sign:** Provider signs attestation with wallet
5. **Bundle:** Package all files into evidence/ folder

---

## Verification Process

1. **Hash check:** Verify all file hashes match
2. **Replay:** Re-run commands in clean environment
3. **Compare:** Check outputs match (within tolerance)
4. **Attestation:** Verify signature against provider's known wallet

---

## Example: PASS Bundle

See `examples/evidence-pass/` for complete example.

---

## Example: FAIL Bundle

See `examples/evidence-fail/` for failure case example.

---

## Schema

See `schemas/evidence-bundle.schema.json` for JSON Schema.

---

*Part of AWMP Verification Kernel experiment*
