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

**Not a toy project.** Every decision has a regulatory rationale.
When in doubt, ask before changing anything structural.

---

## Stack

| Component | Version | Role |
|---|---|---|
| Karate DSL | 1.5.1 (via Maven) | Primary test runner and assertion engine |
| Apache Maven | 3.9.x | Build and test orchestration |
| Java | 17 LTS (Temurin) | Runtime (system runs 25.0.2 — compliant) |
| HL7 FHIR Validator CLI | 6.4.0 (pinned) | Second validation layer in CI |
| GitHub Actions | N/A | CI pipeline and evidence archiving |
| HAPI FHIR sandbox | hapi.fhir.org/baseR4 | System under test |

---

## Project Structure
fhir-validation-suite/
├── src/test/java/fhir/
│   └── ValidationRunner.java        # JUnit5 entry point — runs ALL_PATHS
├── src/test/resources/
│   ├── karate-config.js             # baseUrl and fhirVersion config
│   ├── capability/
│   │   └── capability-check.feature # TC-CAP-001 to 003
│   ├── patient/
│   │   └── patient.feature          # TC-PAT-001 to 011
│   ├── practitioner/
│   │   └── practitioner.feature     # TC-PRA-001 to 006
│   ├── allergy/
│   │   └── allergy.feature          # TC-ALG-001 to 008
│   ├── observation/
│   │   ├── observation.feature      # TC-OBS-001 to 009
│   │   └── assert-value-quantity.feature  # @ignore helper
│   ├── medication/
│   │   └── medication.feature       # TC-MED-001 to 010
│   ├── diagnostic/
│   │   └── diagnostic-report.feature # TC-DXR-001 to 007
│   ├── audit/
│   │   ├── audit-event.feature      # TC-AUD-001 to 007
│   │   └── assert-audit-*.feature   # @ignore helpers (8 files)
│   ├── bundle/
│   │   └── bundle.feature           # TC-BUN-001 to 007
│   ├── common/
│   │   ├── operation-outcome.feature # TC-OO-001 to 005
│   │   ├── general.feature          # TC-GEN-001
│   │   └── capture-response.feature  # @ignore helper
│   └── oq/
│       ├── oq-pass-verification.feature
│       ├── oq-fail-verification.feature
│       ├── oq-schema-pass.feature
│       ├── oq-schema-fail.feature
│       └── oq-http-status.feature
├── docs/
│   ├── validation-plan.md           # VP-FHIR-001 v1.2
│   ├── requirements-specification.md # RS-FHIR-001 v1.2 (61 requirements)
│   ├── architecture.md              # AD-FHIR-001 v1.1
│   ├── test-plan.md                 # TP-FHIR-001 v1.3 (77 TCs)
│   ├── traceability-matrix.md       # TM-FHIR-001 v1.2 (100% coverage)
│   ├── IQ.md                        # TQ-FHIR-IQ-001 v1.1
│   ├── OQ.md                        # TQ-FHIR-OQ-001 v1.1
│   └── PQ.md                        # TQ-FHIR-PQ-001 v1.2
├── .github/workflows/
│   └── fhir-validation.yml          # CI pipeline (not yet created)
├── .gitignore
├── pom.xml
└── CLAUDE.md                        # This file
---

## Current Test Suite State

**Last full run: 2026-04-07**

| Metric | Value |
|---|---|
| Scenarios executed | 74 |
| Passed | 74 |
| Failed | 0 |
| Build | SUCCESS |
| Run time | ~02:10 min |

**TC count breakdown (77 total):**
- 74 automated scenarios — implemented and passing
- 3 non-automated (TC-FRM-001, TC-FRM-002, TC-FRM-003) — verified
  manually as IQ/OQ checklist items, no feature file counterpart by
  design

---

## ValidationRunner Behaviour

`ValidationRunner.java` runs `ALL_PATHS` which covers all 11 feature
directories **except** `oq/`. The OQ feature files are run separately
via `-Dkarate.options=classpath:oq`.

`@ignore` tagged helper features are called by other scenarios and
are never executed directly — this is intentional, not a bug.

`karate.write()` always writes to `target/` under Maven — not
configurable. Captured responses land in `target/responses/`.

The CI validator scan targets `target/responses` — not a root-level
`responses/` folder (which does not exist and is cleaned up).

---

## Key Decisions — Do Not Reverse Without Asking

**FHIR R4 not R5:** R4 is federally mandated by ONC 21st Century
Cures Act and CMS Interoperability Rule. R5 has negligible production
adoption. Changing to R5 would undermine the portfolio signal.

**Karate not Postman/Newman:** Karate's native assertion DSL, schema
matching, and Java interop make it appropriate for regulatory-grade
suites. Newman is not.

**HL7 Validator pinned to 6.4.0:** Pinned, not latest. Floating
version would be a change control violation in a regulated context.

**TC-FRM-001/002/003 non-automated:** These are infrastructure and
process verifications — base URL config, CI artifact linkage, branch
protection. They belong in IQ/OQ qualification evidence, not in a
FHIR API test runner. Do not create feature files for them.

**TC-OO-001 through TC-OO-004 use `request {}`:** An empty JSON body
fails at the FHIR parse layer (HAPI-1843: Missing required element
'resourceType'), guaranteeing a 400 with a validation-specific
OperationOutcome. A body with `resourceType: 'Patient'` reaches the
database and returns 412 (duplicate conflict) — wrong failure mode.

**TC-ALG-004 hard assertion:** `match response.patient == '#present'`
is a hard assertion, not conditional. This was a deliberate hardening
decision — do not soften it.

**`classpath:oq` excluded from ALL_PATHS:** OQ scenarios qualify the
test framework itself, not the FHIR server. They run under a separate
invocation. Merging them into the main runner would corrupt the
evidence separation between OQ and PQ phases.

**REQ-GEN-002 split into REQ-GEN-002a and REQ-GEN-002b:** Enables
independent testability of `meta.lastUpdated` and `meta.versionId`.
Do not merge them back.

---

## Regulatory Standards in Scope

- IEC 62304 Class C (failure paths to patient harm exist)
- ISO 14971 (risk linkage throughout TM)
- 21 CFR Part 11 (electronic records and audit trails)
- 21 CFR Part 820 / ISO 13485 QMSR (document control per §820.40)
- GAMP 5 Category 5 (custom software — full CSV lifecycle)
- FDA General Principles of Software Validation (2002)
- FDA Computer Software Assurance guidance (2022)
- ONC 21st Century Cures Act / CMS Interoperability Rule (FHIR R4)

---

## Milestone Sequence (Current Position: Pre-Git)

- [x] Maven scaffold complete
- [x] All 74 automated TCs passing
- [x] Pre-build doc package complete (8 documents)
- [x] TC-OO-002/003/004 split into standalone scenarios
- [x] TC-GEN-001 implemented in common/general.feature
- [x] TP-FHIR-001 bumped to v1.3
- [x] TM-FHIR-001 bumped to v1.2, automated flags corrected
- [ ] Git init + first commit
- [ ] Push to GitHub (private repo: fhir-validation-suite)
- [ ] Create .github/workflows/fhir-validation.yml
- [ ] Fill IQ.md execution fields
- [ ] Fill OQ.md execution fields
- [ ] Add OQ negative control interpretation block
- [ ] Run full suite in CI — capture commit SHA and run URL
- [ ] Populate TM execution log (74 rows + 3 manual)
- [ ] Create GA-FHIR-001 (gap analysis document)
- [ ] PQ execution

---

## Document Control

All docs live in `docs/`. They are versioned Markdown files satisfying
21 CFR Part 820.40 document control requirements. Every document has
a header table with Document ID, Version, Status, Author, and Date.

When modifying any document:
- Bump the version (patch for corrections, minor for scope changes)
- Update the date
- Add an entry to the document's change history table if one exists
- Never change a TC count without verifying it against feature files

Current document versions:
| Document | ID | Version |
|---|---|---|
| Validation Plan | VP-FHIR-001 | 1.2 |
| Requirements Specification | RS-FHIR-001 | 1.2 |
| Architecture | AD-FHIR-001 | 1.1 |
| Test Plan | TP-FHIR-001 | 1.3 |
| Traceability Matrix | TM-FHIR-001 | 1.2 |
| Installation Qualification | TQ-FHIR-IQ-001 | 1.1 |
| Operational Qualification | TQ-FHIR-OQ-001 | 1.1 |
| Performance Qualification | TQ-FHIR-PQ-001 | 1.2 |

---

## What Not To Do

- Do not run `mvn test` and then modify feature files without
  re-running — the suite state must match the last run result
- Do not create a root-level `responses/` directory — captured
  responses go to `target/responses/` via `karate.write()`
- Do not float the HL7 Validator version — it is pinned to 6.4.0
- Do not add `classpath:oq` to ALL_PATHS in ValidationRunner
- Do not modify `.gitignore` without explaining why
- Do not change TC counts in any document without first counting
  feature file scenarios and confirming they match
- Do not create feature files for TC-FRM-001, TC-FRM-002, TC-FRM-003

---

After reading this file, confirm you have read it by stating the
current scenario count and the next incomplete milestone. Then wait
for instructions.
