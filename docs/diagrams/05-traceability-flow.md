# Regulatory Traceability Flow
## FHIR R4 API Validation Suite

**Document reference:** TM-FHIR-001 Section 1, REQ-GEN-006, REQ-GEN-007

This diagram shows the complete traceability chain — from the regulatory standard that drives a requirement, through to the archived evidence that proves it was tested. Every link in this chain is auditable and version-controlled.

---

```mermaid
flowchart TD
    subgraph STANDARDS["Regulatory Standards"]
        HL7["HL7 FHIR R4\nSpecification"]
        CFR11["21 CFR Part 11\nElectronic Records"]
        IEC["IEC 62304\nSoftware Lifecycle"]
        ISO["ISO 14971\nRisk Management"]
        CFR820["21 CFR Part 820.40\nDocument Control"]
    end

    subgraph RS["RS-FHIR-001 — Requirements"]
        REQ["Requirement\ne.g. REQ-ALG-006\n────────────────\nShall statement\nIEC 62304 Class C\nISO 14971 harm chain\nSource citation"]
    end

    subgraph TP["TP-FHIR-001 — Test Plan"]
        TC["Test Case\ne.g. TC-ALG-006\n────────────────\nTest description\nTest type: Negative\nPrecondition\nExpected result"]
    end

    subgraph TM["TM-FHIR-001 — Traceability Matrix"]
        FWD["Forward Trace\nREQ → TC(s)\nCoverage confirmed"]
        BWD["Backward Trace\nTC → REQ(s)\nNo orphan tests"]
    end

    subgraph BUILD["Framework — Source Code"]
        FEATURE[".feature file\nallergy.feature\n────────────────\nKarate scenario\nActual assertion logic\nExpected HTTP status\nOperationOutcome check"]
    end

    subgraph EXEC["Test Execution — GitHub Actions"]
        SHA["Git Commit SHA\ne.g. a3f9b21c\n────────────────\nLinks evidence to\nexact source state"]
        RUN["Pipeline Run #\ne.g. Run 42"]
        KARATE_R["Karate Result\nPass / Fail / Skip"]
        HL7_R["HL7 Validator Result\nConformant / Errors"]
    end

    subgraph EVIDENCE["Archived Evidence"]
        ARTIFACT["GitHub Actions Artifact\nvalidation-reports-42\n────────────────\nKarate HTML report\nHL7 Validator output\nTimestamp\nCommit SHA"]
    end

    subgraph TM_R["TM-FHIR-001 — Recorded Results"]
        RESULT["Result Row\nREQ-ALG-006 → TC-ALG-006\n────────────────\nResult: Pass\nExec Date: 2026-04-01\nCommit SHA: a3f9b21c"]
    end

    HL7 -->|"Section 3.1.0.6"| REQ
    CFR11 -->|"11.10(e)"| REQ
    IEC -->|"Class C classification"| REQ
    ISO -->|"Harm chain"| REQ

    REQ -->|"derived into"| TC
    TC -->|"mapped in"| FWD
    REQ -->|"mapped in"| FWD
    TC -->|"confirmed in"| BWD

    TC -->|"implemented as"| FEATURE

    FEATURE -->|"executed in"| KARATE_R
    SHA -->|"links run to source"| RUN
    KARATE_R --> ARTIFACT
    HL7_R --> ARTIFACT
    SHA --> ARTIFACT
    RUN --> ARTIFACT

    ARTIFACT -->|"result recorded in"| RESULT

    CFR820 -->|"820.40 requires\nSHA linkage"| SHA

    style STANDARDS fill:#e8f5e9,stroke:#2e7d32,color:#000
    style RS fill:#e3f2fd,stroke:#1565c0,color:#000
    style TP fill:#fce4ec,stroke:#c62828,color:#000
    style TM fill:#fce4ec,stroke:#c62828,color:#000
    style BUILD fill:#f3e5f5,stroke:#6a1b9a,color:#000
    style EXEC fill:#fff8e1,stroke:#f57f17,color:#000
    style EVIDENCE fill:#e8f5e9,stroke:#2e7d32,color:#000
    style TM_R fill:#e3f2fd,stroke:#1565c0,color:#000
```

---

## Why Every Link Matters

| Link | What Breaks If Missing |
|---|---|
| Standard → Requirement | Requirement has no regulatory basis — auditor will ask "why does this requirement exist?" |
| Requirement → Test Case | Requirement is untested — coverage gap finding |
| Test Case → Requirement | Orphan test — test exists without regulatory rationale |
| Test Case → Feature File | Requirement defined but never implemented |
| Feature File → Execution | Implementation never run — no evidence |
| Execution → Commit SHA | Evidence cannot be reproduced — which code version was tested? |
| SHA → Artifact | Evidence not archived — not retrievable for audit |
| Artifact → TM Result Row | Execution happened but result never recorded — matrix incomplete |

## The Audit Question This Chain Answers

An FDA auditor's core question: *"Show me that requirement X was tested, that the test passed, and that you can reproduce that result."*

This chain answers all three parts:
1. **Requirement X was tested** — TM forward trace shows TC-X maps to REQ-X
2. **The test passed** — TM result row shows Pass on a specific date
3. **You can reproduce it** — Git commit SHA identifies the exact code state; `git checkout {SHA}` and `mvn test` reproduces the run
