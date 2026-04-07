# Test Case Lifecycle
## FHIR R4 API Validation Suite

**Document reference:** TP-FHIR-001 Section 7

---

```mermaid
stateDiagram-v2
    direction LR

    [*] --> Pending : TC defined in TP-FHIR-001

    Pending --> Executing : CI pipeline triggers\nmvn test

    Executing --> Pass : All Karate assertions true\nAND HL7 Validator reports\nno errors on captured response

    Executing --> Fail : Any Karate assertion false\nOR HL7 Validator reports\none or more errors

    Executing --> Skip : Resource absent from\nserver CapabilityStatement\n— not a finding

    Executing --> Blocked : Environment issue\nprevents execution\n— documented separately

    Pass --> [*] : Result recorded in TM\nwith Exec Date + Commit SHA

    Fail --> [*] : Finding documented\nin GA-FHIR-001\nGap Analysis

    Skip --> [*] : Documented as\nunsupported scope\nnot counted as fail

    Blocked --> Pending : Environment resolved\ntest re-queued

    note right of Skip
        Class C Safety Invariant:
        A Class C test case may only
        reach Skip state if the server
        CapabilityStatement explicitly
        does not declare the resource.
        Must be documented with
        rationale in Gap Analysis.
        A Skip without documentation
        is an audit finding.
    end note

    note right of Fail
        Severity tiers:
        Critical — Class C req unmet
        Major — Class B req unmet
        Minor — no clinical risk
        Observation — non-spec note
    end note
```

---

## Result Definitions

| Result | Criteria | Counted in Coverage? | Required Action |
|---|---|---|---|
| **Pass** | All Karate assertions true AND HL7 Validator clean | Yes | Record in TM with SHA |
| **Fail** | Any assertion false OR Validator error | Yes | Document in Gap Analysis |
| **Skip** | Resource not in CapabilityStatement | Yes — with rationale | Document rationale |
| **Blocked** | Environment issue — not a test failure | No | Resolve and re-execute |

## Two-Layer Pass Requirement

A test case reaches **Pass** only when both layers agree:

```
Layer 1: Karate assertion    → PASS
Layer 2: HL7 Validator       → No errors
                               ─────────
                               TC Result: PASS
```

If Karate passes but HL7 Validator flags errors — or vice versa — the test case result is **Fail**. The discrepancy is itself a finding worth documenting: it means Karate's clinical assertions and the authoritative specification diverge on that resource.

## Traceability Requirement

Every terminal result (Pass, Fail, Skip) must be recorded in TM-FHIR-001 with:
- Execution date
- Git commit SHA of the run (per REQ-GEN-006)
- GitHub Actions run number

A result without a commit SHA is not valid regulated evidence.
