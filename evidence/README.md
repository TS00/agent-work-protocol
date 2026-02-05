# Evidence bundles

Evidence bundles are verifier outputs: logs + artifacts + hashes that support an accept/reject decision.

Layout (minimum):

```
evidence/<jobId>/<runId>/
  job.json
  environment.json
  verdict.txt
  hashes.txt
  logs/
  artifacts/
```

See: `VERIFIER_RUNBOOK.md`.
