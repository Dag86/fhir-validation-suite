# Document Dependency Chain

## FHIR R4 API Validation Suite

**Document reference:** VP-FHIR-001 Section 8

The dependency chain defines the required authoring order. A document may not be written before the documents it depends on are complete. This sequencing is not bureaucratic — each downstream document derives its content from upstream documents, so they must exist first.

---

```mermaid
flowchart TD
    VP["Validation Plan\nVP-FHIR-001\n─────────────\nGoverning document\nScope · standards · approach\nEntry/exit criteria"]

    RS["Requirements Specification\nRS-FHIR-001\n─────────────\n68 testable requirements\nIEC 62304 class per req\nISO 14971 risk per req"]

    AD["Architecture Document\nAD-FHIR-001\n─────────────\nTool stack · data flow\nDirectory structure\n.gitignore · CI workflow"]

    IQ["Installation Qualification\nTQ-FHIR-IQ-001\n─────────────\nTool installation verified\nGit · JDK · Maven\nKarate · HL7 Validator · GHA"]

    OQ["Operational Qualification\nTQ-FHIR-OQ-001\n─────────────\nTool operation verified\nPass/fail detection confirmed\nBranch protection confirmed"]

    PQ["Performance Qualification\nTQ-FHIR-PQ-001\n─────────────\nIntegrated execution verified\nGit audit trail end-to-end\nReproducibility confirmed"]

    TP["Test Plan\nTP-FHIR-001\n─────────────\n83 test cases\nPreconditions · expected results\nPass/fail criteria"]

    TM["Traceability Matrix\nTM-FHIR-001\n─────────────\nREQ → TC bidirectional\n68 reqs · 83 TCs\n100% coverage · 0 orphans"]

    BUILD["Build Phase\nKarate feature files\npom.xml · karate-config.js\nGitHub Actions workflow"]

    TE["Test Execution\nTE-FHIR-XXX\n─────────────\nTimestamped reports\nGit commit SHA\nHL7 Validator output"]

    GA["Gap Analysis\nGA-FHIR-001\n─────────────\nFindings against spec\nDeviation classification\nDispositions"]

    VP --> RS
    RS --> AD
    RS --> TP
    AD --> IQ
    IQ --> OQ
    OQ --> PQ
    PQ --> BUILD
    TP --> TM
    RS --> TM
    BUILD --> TE
    TM --> TE
    TE --> GA

    style VP fill:#e8f5e9,stroke:#2e7d32,color:#000
    style RS fill:#e3f2fd,stroke:#1565c0,color:#000
    style AD fill:#e3f2fd,stroke:#1565c0,color:#000
    style IQ fill:#fff8e1,stroke:#f57f17,color:#000
    style OQ fill:#fff8e1,stroke:#f57f17,color:#000
    style PQ fill:#fff8e1,stroke:#f57f17,color:#000
    style TP fill:#fce4ec,stroke:#c62828,color:#000
    style TM fill:#fce4ec,stroke:#c62828,color:#000
    style BUILD fill:#f3e5f5,stroke:#6a1b9a,color:#000
    style TE fill:#f3e5f5,stroke:#6a1b9a,color:#000
    style GA fill:#f5f5f5,stroke:#616161,color:#000
```

---

## Why This Order Matters

| Dependency | Reason |
|---|---|
| VP before RS | RS scope is defined by VP scope — a requirement outside VP scope is invalid |
| RS before TP | Test cases must trace to requirements — you cannot write TCs before requirements exist |
| RS before AD | Architecture decisions must account for all resource types in scope |
| AD before IQ | IQ verifies what AD specifies — tool versions, paths, directory structure |
| IQ before OQ | OQ tests tool operation — tools must be installed before operation is tested |
| OQ before PQ | PQ tests integrated performance — individual tools must be qualified first |
| PQ before Build | No test evidence is valid until the toolchain is qualified |
| TP + RS before TM | TM links requirements to test cases — both must exist first |
| TM before TE | Test execution results populate the TM — the matrix must exist first |
| TE before GA | Gap analysis documents findings from execution — execution must happen first |
