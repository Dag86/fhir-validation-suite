# Validation Plan
## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | VP-FHIR-001 |
| **Version** | 1.4 |
| **Status** | Approved |
| **Author** | Amir Choshov |
| **Date** | 2026-04-11 |
| **Project** | FHIR R4 API Validation Suite |

---

## 1. Purpose

This Validation Plan defines the overall strategy, scope, approach, and responsibilities for validating the FHIR R4 API Validation Suite. It establishes the regulatory context, entry and exit criteria, and the documentation structure that governs all validation activities.

This document serves as the governing reference for all downstream validation artifacts including the Requirements Specification, Architecture Document, IQ/OQ/PQ Tool Qualification, Test Plan, and Traceability Matrix.

---

## 2. Background

### 2.1 Problem Statement

Healthcare interoperability depends on reliable, standards-compliant FHIR API implementations. Organizations subject to ONC 21st Century Cures Act and CMS Interoperability Rule mandates are legally required to expose FHIR R4 APIs for patient data access. Before these systems can be used in clinical environments, their FHIR implementations must be validated against the HL7 R4 specification and applicable regulatory standards.

Manual FHIR validation — reviewing API responses against the specification by hand — is slow, not reproducible, and does not scale to the full breadth of resources and edge cases required for regulated validation evidence.

### 2.2 Solution

The FHIR R4 API Validation Suite is an automated validation framework that encodes HL7 FHIR R4 specification requirements as executable test assertions. The framework is:

- **Server-agnostic** — configurable base URL enables execution against any FHIR R4 compliant server
- **Specification-authoritative** — validation runs against official HL7 StructureDefinitions via the FHIR Validator CLI
- **Regulatory-framed** — requirements are classified by IEC 62304 safety class and mapped to ISO 14971 clinical risks
- **Audit-ready** — test execution produces timestamped reports suitable for inclusion in regulated validation packages
- **Version-controlled** — all source code and documentation are maintained under Git, providing a complete, immutable change history

### 2.3 Intended Use

This validation suite is intended for use by QA and validation engineers to:

- Assess FHIR R4 specification conformance of healthcare software systems
- Generate validation evidence for FDA-regulated software submissions
- Support EHR procurement assessments and vendor evaluations
- Execute regression validation following software updates to FHIR-dependent systems

---

## 3. Regulatory Framework

### 3.1 Applicable Standards and Regulations

| Standard / Regulation | Version | Application to This Project |
|---|---|---|
| HL7 FHIR | R4 (4.0.1) | Primary specification governing all resource structure requirements |
| IEC 62304 | 2006 + AMD1:2015 | Medical device software lifecycle — safety classification framework |
| ISO 14971 | 2019 | Risk management — clinical risk identification and control |
| 21 CFR Part 11 | Current | Electronic records and audit trail requirements |
| 21 CFR Part 820 | Current | Quality System Regulation — design verification and validation |
| 21 CFR Part 820.40 | Current | Document controls — version history, change traceability, retrievability |
| ONC 21st Century Cures Act Final Rule | 2020 | Federal mandate for FHIR R4 interoperability |
| FDA General Principles of Software Validation | 2002 | Software validation methodology guidance |
| FDA Guidance on Computer Software Assurance | 2022 | Risk-based approach to software validation |

### 3.2 FHIR Version Justification

FHIR R4 (4.0.1) was selected over FHIR R5 based on the following rationale:

- ONC 21st Century Cures Act Final Rule and CMS Interoperability Rule explicitly mandate FHIR R4 for US healthcare interoperability compliance
- Major EHR vendors including Epic and Cerner are completing R4 implementations and have not committed to R5 production timelines
- The HAPI FHIR R4 public sandbox provides a stable, widely-used reference implementation for framework development and demonstration
- The job market for FHIR validation engineering is predominantly R4 at time of writing

The framework architecture is designed to support R5 migration via configurable FHIR version parameter when regulatory requirements and market adoption warrant.

### 3.3 IEC 62304 Software Classification

The FHIR R4 API Validation Suite is classified as a **validation tool** rather than a medical device. However, the software systems it validates are classified as follows for test coverage purposes:

| FHIR Resource Category | IEC 62304 Class | Justification |
|---|---|---|
| Clinical data resources (Patient, Observation, AllergyIntolerance, MedicationRequest, DiagnosticReport) | Class C | Failure could cause serious injury or death through wrong-patient events, missed allergies, or incorrect clinical data |
| Infrastructure and compliance resources (AuditEvent, OperationOutcome, Bundle, Practitioner, CapabilityStatement) | Class B | Failure could cause non-serious injury through compliance gaps or integration failures |

### 3.4 FDA Computer Software Assurance (CSA) Alignment

This validation suite is designed in alignment with the FDA's 2022 Guidance on Computer Software Assurance for Production and Quality System Software, which advocates a risk-based approach that focuses validation effort on higher-risk software functions. This is reflected in:

- Class C resources receiving more comprehensive test coverage than Class B resources
- Critical clinical pathways (allergy checking, medication ordering) receiving explicit negative path and boundary testing
- Infrastructure resources receiving functional validation without full clinical risk framing

---

## 4. Scope

### 4.1 In Scope

- Validation of FHIR R4 REST API behavior against HL7 R4 specification requirements
- The following FHIR resources: `Patient`, `Practitioner`, `Observation`, `AllergyIntolerance`, `DiagnosticReport`, `MedicationRequest`, `AuditEvent`, `OperationOutcome`, `Bundle`, `CapabilityStatement`
- Positive path testing — valid requests return correct, well-formed responses
- Negative path testing — invalid requests return FHIR-compliant error responses
- Boundary condition testing — edge cases at the limits of valid input
- Schema conformance validation using HL7 FHIR Validator CLI
- Audit trail metadata validation relevant to 21 CFR Part 11
- CI/CD pipeline execution via GitHub Actions
- Tool qualification (IQ/OQ/PQ) for the validation toolchain including Git
- Response time validation (server latency assertions per FHIR R4 performance expectations)
- HTTP response header validation (`Content-Type`, `ETag` per FHIR R4 Section 3.1.0.2)
- Conditional read behavior (`If-None-Match` / HTTP 304 Not Modified per REQ-PAT-012)
- Patient search parameter coverage (`gender`, `birthdate`, `identifier`, `_id` per REQ-PAT-013 through REQ-PAT-016)
- Pagination link structure validation (Bundle `self` link per REQ-BUN-006)
- Multi-server conformance testing (HAPI FHIR as primary target; SMART Health IT as secondary verification server)

### 4.2 Out of Scope

| Item | Justification |
|---|---|
| FHIR R5 resources | Not yet federally mandated; R4 is the current regulatory standard |
| SMART on FHIR OAuth 2.0 authentication | Planned for Phase 2 |
| US Core profile constraints | Planned for Phase 2 |
| FHIR Subscription resources | Outside clinical data validation scope |
| Performance and load testing | Separate testing concern |
| UI layer validation | Separate validation activity governed by IEC 62366 |
| HL7 v2 or SOAP-based interfaces | Legacy protocol, separate toolchain required |
| Write operations (POST/PUT/DELETE) on production systems | Sandbox only; production write operations require separate risk assessment |

### 4.3 Validation Boundaries

This validation suite produces evidence that a FHIR server's API responses conform to the HL7 R4 specification. It does not:

- Validate the clinical accuracy of data stored in the system
- Validate business logic or clinical decision rules
- Replace human factors validation required under IEC 62366
- Constitute a complete 510(k) or PMA submission package without additional validation activities

---

## 5. Validation Approach

### 5.1 Overall Strategy

This validation follows a **risk-based approach** aligned with FDA CSA guidance. Test coverage depth is proportional to the clinical risk of each FHIR resource. Class C resources receive full positive, negative, and boundary coverage. Class B resources receive positive path and critical negative path coverage.

### 5.2 Validation Phases

```
Phase 1 — Planning and Documentation
├── Validation Plan (this document)
├── Requirements Specification
├── Architecture Document
├── IQ/OQ/PQ Tool Qualification
└── Test Plan

Phase 2 — Framework Build
├── Git repository initialization and branch protection
├── Maven project scaffold
├── Karate test suite development
├── HL7 FHIR Validator CLI integration
└── GitHub Actions CI pipeline

Phase 3 — Test Execution
├── CapabilityStatement pre-check
├── Resource validation execution
├── Negative path and boundary test execution
└── HL7 Validator CLI conformance checks

Phase 4 — Evidence and Reporting
├── Test execution reports archived with commit SHAs
├── Traceability Matrix completion
├── Gap analysis
└── Deviation reporting
```

### 5.3 Test Execution Environment

| Component | Specification |
|---|---|
| **Version Control** | Git 2.51.2 |
| **Test Framework** | Karate DSL 1.5.1 |
| **Build Tool** | Apache Maven 3.9.14 |
| **Java Version** | Java 17.0.18 (Eclipse Adoptium Temurin) |
| **FHIR Validator** | HL7 FHIR Validator CLI 6.4.0 (pinned) |
| **CI Platform** | GitHub Actions |
| **Target System** | HAPI FHIR Public Sandbox — https://hapi.fhir.org/baseR4 (primary); SMART Health IT sandbox (secondary) |
| **Operating System** | Ubuntu 22.04 LTS (CI) / macOS (local — Darwin 25.2.0) |

The suite has been validated against two FHIR R4 servers:
- Primary: HAPI FHIR public sandbox (hapi.fhir.org/baseR4) — Result: 80/80 PASS
- Secondary: SMART Health IT sandbox (launch.smarthealthit.org/v/r4/fhir) — Result: 73/80 — 7 conformance findings identified

### 5.4 Test Data Strategy

- All test data references publicly available resources on the HAPI FHIR sandbox
- No real patient data or PHI is used at any point in this validation suite
- Resource IDs used in tests are retrieved dynamically via search queries where possible to avoid hardcoded ID dependencies
- Negative path tests use synthetic malformed payloads constructed inline within test scripts

### 5.5 Defect Management

Deviations from expected behavior discovered during test execution shall be classified as follows:

| Severity | Definition | Action |
|---|---|---|
| **Critical** | FHIR spec violation in a Class C resource | Document in Gap Analysis, flag as blocking |
| **Major** | FHIR spec violation in a Class B resource | Document in Gap Analysis |
| **Minor** | Spec deviation with no clinical risk impact | Document in Gap Analysis |
| **Observation** | Non-spec issue worth noting | Document in test execution report |

For portfolio purposes, all deviations found against the HAPI sandbox are documented in a Gap Analysis report as findings — demonstrating real validation methodology even where the sandbox is largely compliant.

---

## 6. Toolchain Overview

Full qualification details are documented in the IQ/OQ/PQ Tool Qualification documents. The following tools require qualification before their output can be used as regulated validation evidence:

| Tool | Version | Purpose | Qualification Phase |
|---|---|---|---|
| Git | 2.51.2 | Source control, document versioning, CI trigger, change audit trail | IQ |
| Java 17 JDK | 17.0.18 (Eclipse Adoptium Temurin) | Runtime environment for all JVM tools | IQ |
| Apache Maven | 3.9.14 | Build management and test runner | IQ |
| Karate DSL | 1.5.1 | API test execution and assertion | IQ + OQ |
| HL7 FHIR Validator CLI | 6.4.0 (pinned) | Authoritative spec conformance validation | IQ + OQ |
| GitHub Actions | N/A | CI pipeline execution and evidence archiving | OQ + PQ |

**Note on HL7 Validator version:** The HL7 FHIR Validator is pinned to version 6.4.0. Pinning is required — a floating version would constitute an uncontrolled change to the validation toolchain between runs, which is a change control violation in regulated contexts.

---

## 7. Entry and Exit Criteria

### 7.1 Entry Criteria — Validation May Begin When:

- [x] Validation Plan approved
- [x] Requirements Specification complete and reviewed
- [x] Architecture Document complete
- [x] IQ/OQ/PQ Tool Qualification complete for all tools including Git
- [x] Test Plan complete and reviewed
- [x] Git repository initialized on GitHub with branch protection enabled on `main`
- [x] `.gitignore` confirmed present and covering all generated artifacts
- [x] HAPI FHIR sandbox accessible and responding
- [x] GitHub Actions pipeline configured and running
- [x] Traceability Matrix populated with all requirements

### 7.2 Exit Criteria — Validation Is Complete When:

- [x] All 68 requirements in RS-FHIR-001 v1.4 have at least one corresponding test case
- [x] Traceability Matrix shows 100% requirement coverage
- [x] All Class C test cases have been executed and results recorded
- [x] All Class B test cases have been executed and results recorded
- [x] All deviations have been classified and documented in the Gap Analysis
- [x] Test execution reports are archived in GitHub Actions with timestamps and commit SHAs
- [x] No open Critical deviations without documented disposition
- [x] Git commit log provides unbroken history from project initialization to final test execution

### 7.3 Suspension Criteria

Validation execution shall be suspended if:

- HAPI FHIR sandbox is unavailable for more than 24 hours
- FHIR Validator CLI produces inconsistent results across identical inputs
- GitHub Actions pipeline produces non-deterministic test results
- Git repository history on `main` shows signs of rebase or force-push that breaks evidence continuity

---

## 8. Deliverables

| Document | ID | Description |
|---|---|---|
| Validation Plan | VP-FHIR-001 | This document |
| Requirements Specification | RS-FHIR-001 | Testable requirements derived from FHIR R4 spec |
| Architecture Document | AD-FHIR-001 | Framework design and tool stack |
| IQ/OQ/PQ Tool Qualification | TQ-FHIR-IQ/OQ/PQ-001 | Toolchain qualification package |
| Test Plan | TP-FHIR-001 | Test execution approach and coverage strategy |
| Traceability Matrix | TM-FHIR-001 | Requirements to test case mapping |
| Test Execution Reports | TE-FHIR-XXX | Timestamped CI pipeline outputs with commit SHA |
| Gap Analysis | GA-FHIR-001 | Deviations and findings from test execution |

---

## 9. Roles and Responsibilities

| Role | Responsibility |
|---|---|
| **Validation Engineer** | Author all documentation, build framework, execute tests, produce gap analysis |
| **Reviewer** | Review requirements and test coverage for completeness |

*Note: For portfolio purposes, both roles are fulfilled by the author. In a regulated production environment these roles would be performed by separate individuals to ensure independence.*

---

## 10. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| HAPI sandbox instability | Medium | High | Use dynamic resource retrieval; document sandbox-specific deviations separately |
| FHIR Validator CLI version changes | Low | Medium | Pin validator version in CI pipeline |
| Sandbox resource IDs change between runs | High | Medium | Use search-based resource retrieval rather than hardcoded IDs |
| Incomplete CapabilityStatement on sandbox | Low | High | Pre-check and skip unsupported resources rather than fail |
| R4 to R5 migration makes suite obsolete | Low | Low | Version-configurable architecture allows R5 extension |
| Accidental credential commit to Git | Low | High | `.gitignore` enforced at project initialization; GitHub Actions secrets used for all tokens |
| Force-push to `main` breaks evidence chain | Low | High | Branch protection rules on `main` prevent force-push and require PR review |

---

## 11. Document Control

### 11.1 Document Version History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Git to toolchain and environment; formalized Git as document control system; added 820.40 citation; updated entry/exit criteria and risk assessment |
| 1.2 | 2026-03-30 | Amir Choshov | Updated exit criteria requirement count from 54 to 61 to reflect RS-FHIR-001 v1.2 (added REQ-OBS-007, REQ-ALG-006, REQ-MED-007, REQ-DXR-005, REQ-GEN-002a, REQ-GEN-002b; retired REQ-GEN-002) |
| 1.3 | 2026-04-11 | Amir Choshov | Status updated to Approved. Tool versions updated to exact pinned values (Karate 1.5.1, Maven 3.9.14, Java 17.0.18 Temurin, HL7 Validator 6.4.0, Git 2.51.2). HL7 Validator pinning rationale added. Scope updated with 6 new test types from hardening pass (response time, headers, conditional read, search params, pagination, multi-server). Entry/exit criteria marked complete. Exit criteria requirement count updated to 67 (RS-FHIR-001 v1.3). Multi-server execution results added to §5.3. |
| 1.4 | 2026-04-13 | Amir Choshov | Updated exit criteria: requirement count 67→68, RS citation v1.3→v1.4 to match current RS-FHIR-001 v1.4 |

### 11.2 Git as the Document Control System

All validation documents for this project are maintained as Markdown files under version control in the project Git repository hosted on GitHub. This satisfies the document control requirements of **21 CFR Part 820 Section 820.40** as follows:

| 820.40 Requirement | Git Implementation |
|---|---|
| Documents must be approved before issuance | Pull request review and merge to `main` constitutes the approval gate |
| Changes must be reviewed and approved | All changes to `main` pass through pull requests with mandatory review |
| Obsolete document versions must be identifiable | Git history retains all prior versions; current version is always `HEAD` of `main` |
| Documents must be legible and identifiable | Markdown renders in GitHub; every document carries a unique Document ID in its header |
| Documents must be retrievable | GitHub repository is permanently accessible; pipeline artifacts retained 90 days minimum |

The Git commit SHA recorded in each GitHub Actions pipeline run links test execution evidence to the exact document and code state at the time of execution, providing an unbroken chain of traceability from requirement to test case to execution result.

---

## 12. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | | |
| Reviewer | | | |

---

*This Validation Plan governs all validation activities for the FHIR R4 API Validation Suite. Any changes to scope, approach, or toolchain must be reflected in a revision to this document before implementation.*