# Validation State Machine
## FHIR R4 API Validation Suite

**Document reference:** VP-FHIR-001 Section 5.2

This diagram applies the TLA+ state machine approach to the validation lifecycle. Each state transition has explicit preconditions. Safety properties and liveness properties are annotated.

---

```mermaid
stateDiagram-v2
    direction TB

    [*] --> Uninitialized : Project created

    Uninitialized --> IQ_Complete : All IQ steps passed\nGit · JDK · Maven · Karate · HL7 Validator · GitHub Actions
    note right of Uninitialized
        Safety invariant:
        No test evidence may be
        generated in this state.
        Tools are not yet qualified.
    end note

    IQ_Complete --> OQ_Complete : All OQ steps passed\nOQ-GIT-001–005 · OQ-KAR-001–006\nOQ-VAL-001–003 · OQ-GHA-001–005
    note right of IQ_Complete
        Precondition:
        TQ-FHIR-IQ-001 signed off.
        No OQ step may begin
        before IQ is complete.
    end note

    OQ_Complete --> PQ_Complete : All PQ steps passed\nPQ-001 through PQ-005
    note right of OQ_Complete
        Precondition:
        TQ-FHIR-OQ-001 signed off.
        OQ-KAR-002 and OQ-VAL-002
        must both be FAIL-detected
        (not vacuous passes).
    end note

    PQ_Complete --> ReadyToExecute : All entry criteria met\nBranch protection active\n.gitignore confirmed\nPipeline running\nSandbox accessible
    note right of PQ_Complete
        Precondition:
        TQ-FHIR-PQ-001 signed off.
        Working tree clean.
        All 61 requirements have
        at least one test case.
    end note

    ReadyToExecute --> Executing : Test execution begins\nmvn test triggered via CI

    Executing --> Suspended : Suspension criteria triggered\nSandbox unavailable 24h+\nCI non-deterministic\nGit history broken
    Suspended --> Executing : Suspension resolved\nand documented

    Executing --> Complete : All exit criteria met\n77 TCs executed\n100% req coverage\nSHA recorded\nGap Analysis complete

    Complete --> [*]

    note left of Complete
        Liveness property:
        All Pending requirements
        must eventually reach
        Pass, Fail, or Skip.
        No requirement may remain
        Pending at validation close.
    end note

    note left of Executing
        Class C safety invariant:
        No Class C requirement
        may be marked Skip without
        documented rationale signed
        by the validation engineer.
    end note
```

---

## State Definitions

| State | Entry Condition | Exit Condition |
|---|---|---|
| Uninitialized | Project created | All IQ steps pass |
| IQ_Complete | TQ-FHIR-IQ-001 passed | All OQ steps pass |
| OQ_Complete | TQ-FHIR-OQ-001 passed | All PQ steps pass |
| PQ_Complete | TQ-FHIR-PQ-001 passed | All VP entry criteria met |
| ReadyToExecute | VP-FHIR-001 Section 7.1 satisfied | `mvn test` executed in CI |
| Executing | Test run triggered | All exit criteria satisfied or suspension triggered |
| Suspended | Suspension criteria triggered | Criteria resolved and documented |
| Complete | VP-FHIR-001 Section 7.2 satisfied | Validation package closed |

## Safety Properties (Must Hold in All States)

- No test execution evidence is valid before PQ_Complete
- No Class C requirement may remain uncovered at Complete
- Git history on `main` must never be rebased or force-pushed — breaks evidence chain
- OQ-KAR-002 must have confirmed that Karate correctly reports failures before Executing

## Liveness Property

The system must eventually reach Complete given sufficient time and absence of permanent suspension. All 61 requirements must reach a terminal result state (Pass, Fail, Skip) before the validation lifecycle closes.
