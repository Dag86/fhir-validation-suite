# Diagrams

## FHIR R4 API Validation Suite

Visual reference for the framework architecture, validation lifecycle, and regulatory traceability chain.

All diagrams use [Mermaid](https://mermaid.js.org/) — they render natively in GitHub without any plugins or exports.

---

| File | Diagram | Description |
|---|---|---|
| [01-system-architecture.md](01-system-architecture.md) | System Architecture | Full component stack — Git, Karate, FHIR server, HL7 Validator, CI pipeline |
| [02-validation-state-machine.md](02-validation-state-machine.md) | Validation State Machine | IQ → OQ → PQ → Executing → Complete lifecycle with preconditions |
| [03-test-lifecycle.md](03-test-lifecycle.md) | Test Case Lifecycle | Per-test state transitions including Class C safety invariant |
| [04-document-dependency.md](04-document-dependency.md) | Document Dependency Chain | Authoring order and dependency relationships between all validation documents |
| [05-traceability-flow.md](05-traceability-flow.md) | Regulatory Traceability Flow | End-to-end chain from regulatory standard to archived evidence |
| [06-risk-classification.md](06-risk-classification.md) | Risk Classification Hierarchy | FHIR resources organized by IEC 62304 class with clinical harm chains |

---

*All diagrams are version-controlled alongside source code and documentation. Changes appear as line diffs in pull requests, satisfying 21 CFR Part 820.40 document control requirements.*
