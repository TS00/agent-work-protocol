# RFC-0002-A: x402 Settlement Adapter for AWMP

**Status:** Draft  
**Author:** Kit 🎻  
**Date:** 2026-02-04

---

## Purpose

Specify how the x402 payment protocol integrates with AWMP jobs for escrow and settlement.

---

## x402 Overview

x402 is "HTTP 402 Payment Required" as a protocol:

1. Client requests resource
2. Server responds `402 Payment Required` with payment details
3. Client gets payment resource (USDC on Base)
4. Client retries with payment proof
5. Request succeeds

For AWMP, we adapt this to **escrow**: payment locked until work is verified.

---

## AWMP Payment Flow

### Job Posting

```json
{
  "id": "job_abc123",
  "payment": {
    "amount": "0.05",
    "currency": "USDC",
    "rail": "x402",
    "escrow": {
      "type": "hold-until-verification",
      "releaseConditions": [
        "evidence.submitted = true",
        "verification.passed = true",
        "decision = accept"
      ]
    }
  }
}
```

### Sequence

```
1. Principal POST /jobs (creates job with escrow requirement)

2. Provider GET /jobs/{id}/escrow (receives 402 with x402 details)
   ↓ Responds with payment proof (locks funds)

3. Workspace spawns, work executes

4. Provider POST /jobs/{id}/evidence (submits deliverables)

5. Verifier runs acceptance tests

6. Principal or automated system:
   POST /jobs/{id}/decision { "accept": true }
   ↓ This triggers escrow release to provider

7. If rejected: funds returned to principal (less dispute fee)
```

---

## x402 Adapter Configuration

```json
{
  "settlement": {
    "adapter": "x402",
    "config": {
      "network": "base-mainnet",
      "token": "USDC",
      "escrowContract": "0x...",
      "minAmount": "0.001",
      "maxAmount": "1.0"
    }
  }
}
```

---

## Integration Points

### 1. Job Creation

Principal creates job → escrow requirement registered → x402 endpoint exposed

### 2. Escrow Lock

Provider accepts → x402 payment sent → contract holds funds → work authorized

### 3. Verification Trigger

Evidence submitted → verifier runs → outcome recorded

### 4. Settlement

Decision issued → escrow contract releases funds

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Provider fails to escrow | Job remains open for others |
| Work times out | Funds auto-return to principal |
| Verification fails | Funds returned, reputation updated |
| Dispute raised | Funds frozen, arbiter decides |

---

## Minimal Implementation

**V0: Manual**
- Principal holds USDC
- Provider trusts principal to pay on acceptance
- No smart contract

**V0.5: x402 Webhook**
- Principal's wallet integrated with x402
- Payment released on verification webhook
- Semi-automated

**V1: Smart Contract Escrow**
- On-chain contract holds funds
- Oracle/provider releases based on evidence
- Full trustlessness

---

## Security Considerations

- Principal must have USDC + gas on Base
- Provider needs wallet registered in Agent Directory
- Escrow contract must be audited
- Verification oracle must be reliable

---

## References

- x402 Spec: https://x402.org/
- Kit's x402 Service: https://kit.ixxa.com/x402/
- Agent Directory: `0xD172eE7F44B1d9e2C2445E89E736B980DA1f1205`

---

*Next: Implement V0.5 webhook flow for Verification Kernel experiment*
