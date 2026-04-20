# System Architecture

## FHIR R4 API Validation Suite

**Document reference:** AD-FHIR-001 Section 2

---

```mermaid
flowchart TD
    subgraph REPO["Git Repository — GitHub"]
        direction TB
        SRC["Source Code\n.feature files · karate-config.js · pom.xml\nValidationRunner.java · schemas/"]
        DOCS["Validation Documents\nVP · RS · AD · IQ · OQ · PQ · TP · TM"]
        OQ_FILES["OQ Test Fixtures\noq/valid-patient.json\noq/invalid-patient.json"]
    end

    subgraph CI["GitHub Actions CI Pipeline"]
        direction LR
        TRIGGER["Trigger\npush · PR · schedule · manual"]
        SETUP["Setup\nJava 17 · Maven cache\nHL7 Validator download"]
        BUILD["mvn clean compile"]
        EXEC["mvn test\nKarate execution"]
        HLVAL["HL7 Validator CLI\nStructureDefinition check"]
        ARTIFACT["Archive Artifacts\nrun number + commit SHA\nretention 90 days"]
    end

    subgraph LAYER1["Layer 1 — Test Execution  Karate DSL"]
        CAP["CapabilityStatement\nPre-Check\nGET /metadata"]
        TESTS["Resource Feature Files\nPatient · Observation · AllergyIntolerance\nMedicationRequest · DiagnosticReport\nAuditEvent · Bundle · Practitioner\nOperationOutcome · CapabilityStatement"]
    end

    subgraph TARGET["Target Server — Configurable"]
        HAPI["HAPI FHIR Public Sandbox\nhapi.fhir.org/baseR4\n— or any FHIR R4 server —"]
    end

    subgraph LAYER2["Layer 2 — Schema Conformance  HL7 Validator"]
        RESP["responses/\nCaptured JSON per resource"]
        VALOUT["Validator Output\nStructureDefinition result\nper captured response"]
    end

    subgraph LAYER3["Layer 3 — Regulatory Evidence"]
        REPORT["Karate HTML Reports\nTimestamped pass/fail per TC"]
        TM["Traceability Matrix\nREQ → TC → Result → Commit SHA"]
        GA["Gap Analysis\nFindings against FHIR R4 spec"]
    end

    REPO -->|"commit SHA triggers"| TRIGGER
    TRIGGER --> SETUP --> BUILD --> EXEC
    EXEC --> HLVAL
    EXEC --> ARTIFACT
    HLVAL --> ARTIFACT

    CAP -->|"gates resource tests\nbased on server capability"| TESTS
    TESTS -->|"HTTP requests"| TARGET
    TARGET -->|"JSON responses"| RESP
    TARGET -->|"JSON responses"| TESTS
    RESP --> HLVAL
    HLVAL --> VALOUT

    VALOUT --> REPORT
    TESTS --> REPORT
    REPORT --> TM
    TM --> GA

    EXEC -.->|"executes"| LAYER1
    HLVAL -.->|"invokes"| LAYER2
    ARTIFACT -.->|"archives"| LAYER3

    style REPO fill:#f5f5f5,stroke:#666,color:#000
    style CI fill:#e8f5e9,stroke:#388e3c,color:#000
    style LAYER1 fill:#e3f2fd,stroke:#1565c0,color:#000
    style TARGET fill:#f3e5f5,stroke:#6a1b9a,color:#000
    style LAYER2 fill:#fff8e1,stroke:#f57f17,color:#000
    style LAYER3 fill:#fce4ec,stroke:#c62828,color:#000
```

---

## Component Roles

| Component | Role | Regulatory Significance |
|---|---|---|
| Git Repository | Source control, document versioning, change audit trail | 21 CFR Part 820.40 — document control |
| GitHub Actions | Automated test execution and evidence archiving | 21 CFR Part 820 — repeatable, documented verification |
| Karate DSL | Layer 1 clinical assertions against FHIR specification | Primary test execution evidence |
| CapabilityStatement Pre-Check | Server capability discovery — gates all subsequent tests | Prevents false failures on unsupported resources |
| FHIR R4 Server | Target under validation — configurable via single parameter | Any server can be targeted without code changes |
| HL7 Validator CLI | Layer 2 authoritative StructureDefinition conformance | Specification-authoritative evidence distinct from Karate |
| Archived Artifacts | Timestamped reports linked to Git commit SHA | REQ-GEN-006 — traceability chain |
| Traceability Matrix | Bidirectional REQ ↔ TC ↔ result mapping | IEC 62304 Class C — bidirectional traceability required |
