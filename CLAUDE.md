# CLAUDE.md — Project Context for Claude Code

This file is read automatically at session start. It gives you the
full context needed to work on this project without requiring the
owner to re-explain state. Read it completely before taking any action.

---

## What This Project Is

A regulatory-grade FHIR R4 API validation suite targeting the HAPI
FHIR public sandbox (https://hapi.fhir.org/baseR4). Built to
demonstrate FDA-regulated software validation methodology for a
portfolio targeting healthcare and medical device QA roles.

Not a toy project. Every decision has a regulatory rationale.
When in doubt, ask before changing anything structural.

---

## Stack

| Component | Version | Role |
|---|---|---|
| Karate DSL | 1.5.1 (via Maven) | Primary test runner and assertion engine |
| Apache Maven | 3.9.14 | Build and test orchestration |
| Java | 17.0.18 Temurin | Runtime — JAVA_HOME set in ~/.zshrc |
| HL7 FHIR Validator CLI | 6.4.0 (pinned) | Second validation layer in CI |
| GitHub Actions | N/A | CI pipeline and evidence archiving |
| HAPI FHIR sandbox | hapi.fhir.org/baseR4 | System under test |

---

## Project Structure

src/test/java/fhir/
  ValidationRunner.java          — JUnit5 entry point, runs ALL_PATHS

src/test/resources/
  karate-config.js               — baseUrl and fhirVersion config
  capability/capability-check.feature    — TC-CAP-001 to 003
  patient/patient.feature                — TC-PAT-001 to 016
  practitioner/practitioner.feature      — TC-PRA-001 to 006
  allergy/allergy.feature                — TC-ALG-001 to 008
  observation/observation.feature        — TC-OBS-001 to 009
  observation/assert-value-quantity.feature  — @ignore helper
  medication/medication.feature          — TC-MED-001 to 010
  diagnostic/diagnostic-report.feature   — TC-DXR-001 to 007
  audit/audit-event.feature              — TC-AUD-001 to 007
  audit/assert-audit-*.feature           — @ignore helpers (8 files)
  bundle/bundle.feature                  — TC-BUN-001 to 008
  common/operation-outcome.feature       — TC-OO-001 to 005
  common/general.feature                 — TC-GEN-001
  common/capture-response.feature        — @ignore helper
  oq/oq-*.feature                        — 5 OQ qualification scenarios

docs/
  validation-plan.md             — VP-FHIR-001 v1.3
  requirements-specification.md  — RS-FHIR-001 v1.3 (67 requirements)
  architecture.md                — AD-FHIR-001 v1.2
  test-plan.md                   — TP-FHIR-001 v1.5 (83 TCs)
  traceability-matrix.md         — TM-FHIR-001 v1.5 (executed, 100% coverage)
  gap-analysis.md                — GA-FHIR-001 v1.1 (final)
  validation-summary-report.md   — VA-FHIR-001 v1.2 (final)
  qualification/IQ.md            — TQ-FHIR-IQ-001 v1.2 (executed)
  qualification/OQ.md            — TQ-FHIR-OQ-001 v1.2 (executed)
  qualification/PQ.md            — TQ-FHIR-PQ-001 v1.4 (executed)

.github/workflows/
  fhir-validation.yml            — CI pipeline (active)

.gitignore
pom.xml
CLAUDE.md                        — this file

---

## Current Test Suite State

**VALIDATION COMPLETE — 2026-04-11**

| Metric | Value |
|---|---|
| Scenarios executed | 80 |
| Passed | 80 |
| Failed | 0 |
| Build | SUCCESS |
| Run time | ~02:09 min |
| Last local run | 2026-04-11 |
| CI runs completed | 3 |
| Closing commit SHA | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |

TC count breakdown (83 total in TP-FHIR-001 v1.5):
- 80 automated scenarios — implemented and passing
- 3 non-automated (TC-FRM-001, TC-FRM-002, TC-FRM-003) — verified
  as IQ/OQ checklist items, no feature file by design

---

## Commit History

| SHA | Description |
|---|---|
| 7c3aa35 | Initial validated suite — build complete |
| 6e99a28 | CI workflow added |
| ab0f836 | IQ.md executed + validator glob fix |
| 4458f7d | OQ.md executed |
| 61871dd | TM execution log populated |
| b1c5f2f | GA-FHIR-001 created |
| 4115c24 | PQ.md executed |
| 2a56d65 | VA-FHIR-001 — validation lifecycle closed |
| 259e61a | ci: add index.html redirect for GitHub Pages Karate report |
| b671fc5 | ci: grant GITHUB_TOKEN write permission for gh-pages publish |
| b0cf7ab | ci: publish Karate report to GitHub Pages after every CI run |
| dc3d1d7 | docs: replace ASCII architecture diagram with Mermaid flowchart |
| 1411863 | test: add resourceType precondition assertions to all B->C Backgrounds |
| af2bf2c | docs: consolidation — TP v1.5, TM v1.5, GA v1.1, VA v1.2, PQ v1.4, README, CLAUDE.md |

---

## Validation Lifecycle Status

ALL MILESTONES COMPLETE.

| Phase | Document | Version | Status |
|---|---|---|---|
| Validation Plan | VP-FHIR-001 | 1.3 | Approved |
| Requirements Specification | RS-FHIR-001 | 1.3 | Approved |
| Architecture | AD-FHIR-001 | 1.2 | Approved |
| Test Plan | TP-FHIR-001 | 1.5 | Approved |
| Traceability Matrix | TM-FHIR-001 | 1.5 | Executed |
| Installation Qualification | TQ-FHIR-IQ-001 | 1.2 | PASS |
| Operational Qualification | TQ-FHIR-OQ-001 | 1.2 | PASS |
| Performance Qualification | TQ-FHIR-PQ-001 | 1.4 | PASS |
| Gap Analysis | GA-FHIR-001 | 1.1 | Final |
| Validation Summary Report | VA-FHIR-001 | 1.2 | Final — VALIDATED |

---

## Open Deviations

| ID | Description | Severity | Action Required |
|---|---|---|---|
| DEV-IQ-001 | Branch protection on main not configured | Low | RESOLVED 2026-04-09 — branch protection active on main |
| DEV-OQ-001 | GitHub Actions Node.js 20 deprecation warning | Low | Update action versions before Sep 2026 |
| DEV-PQ-001 | Same as DEV-OQ-001 — recurred in PQ run | Low | Same as DEV-OQ-001 |

---

## ValidationRunner Behaviour

ALL_PATHS covers all 11 resource directories except oq/.
OQ scenarios run separately via -Dkarate.options=classpath:oq.

@ignore tagged helper features are called by other scenarios and
are never executed directly — this is intentional, not a bug.

karate.write() always writes to target/ under Maven.
Captured responses land in target/responses/.
CI validator scan uses find target/responses -name "*.json"
to enumerate all files explicitly.

---

## Key Decisions — Do Not Reverse Without Asking

FHIR R4 not R5:
  R4 is federally mandated by ONC 21st Century Cures Act and CMS
  Interoperability Rule. R5 has negligible production adoption.

Karate not Postman/Newman:
  Karate native assertion DSL and Java interop make it appropriate
  for regulatory-grade suites.

HL7 Validator pinned to 6.4.0:
  Floating version is a change control violation in regulated context.

TC-FRM-001/002/003 non-automated:
  Infrastructure and process verifications belong in IQ/OQ evidence,
  not in a FHIR API test runner. Do not create feature files for them.

TC-OO-001 through TC-OO-004 use request {}:
  Empty JSON body fails at FHIR parse layer (HAPI-1843: Missing
  required element 'resourceType'), guaranteeing a 400 with a
  validation-specific OperationOutcome. A body with resourceType:
  'Patient' reaches the database and returns 412 — wrong failure mode.

TC-ALG-004 hard assertion:
  match response.patient == '#present' is a hard assertion by design.
  Do not soften it.

classpath:oq excluded from ALL_PATHS:
  OQ qualifies the test framework, not the FHIR server. Merging into
  the main runner would corrupt IQ/OQ/PQ evidence separation.

REQ-GEN-002 split into REQ-GEN-002a and REQ-GEN-002b:
  Enables independent testability of meta.lastUpdated and
  meta.versionId. Do not merge them back.

---

## Regulatory Standards in Scope

- IEC 62304 Class C (failure paths to patient harm exist)
- ISO 14971 (risk linkage throughout TM)
- 21 CFR Part 11 (electronic records and audit trails)
- 21 CFR Part 820 / ISO 13485 QMSR (document control per 820.40)
- GAMP 5 Category 5 (custom software, full CSV lifecycle)
- FDA General Principles of Software Validation (2002)
- FDA Computer Software Assurance guidance (2022)
- ONC 21st Century Cures Act / CMS Interoperability Rule (FHIR R4)

---

## What Not To Do

- Do not run mvn test and modify feature files without re-running
- Do not create a root-level responses/ directory
- Do not float the HL7 Validator version — pinned to 6.4.0
- Do not add classpath:oq to ALL_PATHS in ValidationRunner
- Do not modify .gitignore without explaining why
- Do not change TC counts in any document without counting feature
  file scenarios first and confirming they match
- Do not create feature files for TC-FRM-001, TC-FRM-002, TC-FRM-003
- Do not amend commits that are already on main without force pushing
  and documenting the reason

---

## Session Start Confirmation

After reading this file, confirm by stating:
1. Current passing scenario count
2. Validation lifecycle status (complete or in progress)
3. Number of open deviations

Then wait for instructions.

---

## Task Execution Protocol

Before implementing any change:
1. State what you understand the task to be
2. List any files you intend to touch
3. Define how you will verify the change is correct

Do not begin implementation until this is confirmed.
For test changes: state the TC ID, expected behavior, and which
document versions (TM, TP) would need updating as a result.

