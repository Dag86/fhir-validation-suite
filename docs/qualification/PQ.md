# Performance Qualification (PQ)
## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | TQ-FHIR-PQ-001 |
| **Version** | 1.2 |
| **Status** | Draft |
| **Author** | Amir Choshov |
| **Date** | 2026-04-06 |
| **Project** | FHIR R4 API Validation Suite |
| **Related Documents** | TQ-FHIR-IQ-001, TQ-FHIR-OQ-001 |
| **Prerequisite** | TQ-FHIR-IQ-001 and TQ-FHIR-OQ-001 must be completed and passed |

---

## 1. Purpose

This Performance Qualification document verifies that the complete FHIR R4 API Validation Suite toolchain performs correctly in the specific environment used for validation, for the specific use case it was designed for.

PQ is the third and final phase of tool qualification. Unlike IQ (which verifies installation) and OQ (which verifies tools in isolation against known inputs), PQ tests the integrated system end to end in realistic operating conditions.

PQ answers the question: does the entire framework — Git, Karate, Maven, HL7 Validator, and GitHub Actions working together — produce reliable, reproducible, audit-ready validation evidence with a complete and intact traceability chain in this environment?

---

## 2. PQ Scope

| What PQ Tests | What PQ Does Not Test |
|---|---|
| Full suite execution in local environment | Clinical accuracy of FHIR server data |
| Full suite execution in CI environment | FHIR server compliance (that is the validation suite's job) |
| Reproducibility across multiple runs | Performance under load |
| Server-agnostic configuration switching | Authentication flows (Phase 2) |
| Evidence archiving and retrievability | US Core profile coverage (Phase 2) |
| End-to-end Git audit trail integrity | Git internals or object storage |
| Commit SHA traceability through CI to archived evidence | Third-party Git hosting reliability |

---

## 3. PQ Preconditions

Before executing any PQ step, confirm the following:

| Precondition | Confirmed | Date | Initials |
|---|---|---|---|
| TQ-FHIR-IQ-001 completed and passed | | | |
| TQ-FHIR-OQ-001 completed and passed | | | |
| HAPI FHIR sandbox accessible — `https://hapi.fhir.org/baseR4/metadata` returns 200 | | | |
| Internet connectivity confirmed from execution environment | | | |
| Git repository initialized with correct remote, branch protection on `main` | | | |
| `.gitignore` confirmed present and covering all generated artifacts | | | |
| All source files and documentation committed to repository | | | |
| GitHub Actions workflow file committed and pipeline active | | | |

---

## 4. PQ-001: Full Suite Execution — Local Environment

**Objective:** Confirm the complete validation suite executes without errors in the local development environment and produces a valid test report.

**Environment:**

| Field | Record Value |
|---|---|
| Operating System | |
| Git Version | |
| Java Version | |
| Maven Version | |
| Karate Version | |
| Execution Date | |
| Executed By | |

**Execution Steps:**

| Step ID | Action | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-001-1 | `mvn clean test` | Build completes, all feature files execute without build errors | | |
| PQ-001-2 | Review `target/karate-reports/` | HTML report present with results for all 10 resource types | | |
| PQ-001-3 | Confirm CapabilityStatement pre-check ran first | Log shows `/metadata` queried before any resource test | | |
| PQ-001-4 | Confirm response files captured | `responses/` directory populated with JSON files | | |
| PQ-001-5 | Run HL7 Validator against captured responses | Validator output produced for each response file without JVM errors | | |
| PQ-001-6 | Record total execution time | Suite completes within 10 minutes | | |
| PQ-001-7 | `git status` after test run | `target/` and `responses/` do not appear as untracked files — gitignore working in integrated context | | |

**Execution Summary:**

| Field | Value |
|---|---|
| Total Tests Executed | |
| Passed | |
| Failed | |
| Skipped (unsupported by server) | |
| Total Execution Time | |
| Report Location | `target/karate-reports/` |

**PQ-001 Overall Result:** ☐ Pass  ☐ Fail

---

## 5. PQ-002: Full Suite Execution — CI Environment

**Objective:** Confirm the complete validation suite executes correctly in GitHub Actions, produces archived timestamped validation evidence, and records the triggering commit SHA in the pipeline output.

**Execution Steps:**

| Step ID | Action | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-002-1 | Merge a PR to `main` branch | Pipeline triggers automatically within 60 seconds | | |
| PQ-002-2 | All pipeline stages complete | No stage exits with non-zero code | | |
| PQ-002-3 | Karate HTML reports archived | Artifact `validation-reports-{run_number}` present in run summary | | |
| PQ-002-4 | HL7 Validator output archived | Validator JSON results present in artifact | | |
| PQ-002-5 | Run number and commit SHA visible in pipeline log | Both displayed in `Report status` step output | | |
| PQ-002-6 | Artifacts downloadable | Reports accessible and openable via GitHub Actions UI | | |
| PQ-002-7 | Commit SHA in pipeline log matches the merged PR commit | SHA recorded in `Record commit SHA` step matches the merge commit SHA | | |

**CI Execution Record:**

| Field | Value |
|---|---|
| GitHub Repository | |
| Run Number | |
| Merge Commit SHA | |
| SHA in Pipeline Log | |
| SHAs Match | Yes / No |
| Pipeline Start Time | |
| Pipeline End Time | |
| Total Duration | |
| Artifact Name | |
| Executed By | |

**PQ-002 Overall Result:** ☐ Pass  ☐ Fail

---

## 6. PQ-003: Reproducibility Verification

**Objective:** Confirm the suite produces consistent results across multiple executions against the same target server state.

**Rationale:** A validation tool that produces different results on identical inputs is not reliable and cannot generate trustworthy regulated evidence. Reproducibility is a foundational requirement under FDA General Principles of Software Validation.

**Execution Instructions:**
Execute `mvn test` three times consecutively against the same target server without changing any configuration between runs. Record results immediately after each run.

**Results Table:**

| Run | Total Tests | Passed | Failed | Skipped | Git Status Clean After | Date | Time | Initials |
|---|---|---|---|---|---|---|---|---|
| Run 1 | | | | | Yes / No | | | |
| Run 2 | | | | | Yes / No | | | |
| Run 3 | | | | | Yes / No | | | |

**Variance Analysis:**

| Field | Value |
|---|---|
| Passed count consistent across all runs | Yes / No |
| Failed count consistent across all runs | Yes / No |
| Git status clean after each run | Yes / No |
| Variance observed | |
| Variance explanation (if any) | |

**Acceptance Criteria:** Pass/fail counts are identical across all three runs for the same server state. `git status` must be clean after each run — generated artifacts must not accumulate in the working tree. Any variance must be investigated and documented before PQ-003 is considered complete.

**Known acceptable variance sources:**
- HAPI sandbox data changes between runs (resource IDs added or removed) — document as environment variance, not tool failure
- Network timeout on single request — document and re-run

**PQ-003 Overall Result:** ☐ Pass  ☐ Fail

---

## 7. PQ-004: Server-Agnostic Configuration Verification

**Objective:** Confirm the base URL configuration switch works correctly — the suite executes against a different target server without any code changes.

> **Scope note:** PQ-004 step PQ-004-2 uses the R5 endpoint
> (`hapi.fhir.org/baseR5`) solely to verify configuration switching
> behavior — not to validate R5 conformance. R5 resources are out of
> scope per VP-FHIR-001 Section 2.2. This step is classified as a
> forward-compatibility configuration experiment, not a PQ acceptance
> criterion. Results from the R5 endpoint are not included in
> suite-level pass/fail determination.

**Rationale:** The primary real-world value of this framework is its reusability against any FHIR R4 server. This PQ step verifies that capability works as designed.

**Execution Steps:**

| Step ID | Command | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-004-1 | `mvn test -DbaseUrl=https://hapi.fhir.org/baseR4` | Suite runs against R4 sandbox, reports generated | | |
| PQ-004-2 | `mvn test -DbaseUrl=https://hapi.fhir.org/baseR5` | Suite runs against R5 endpoint without code changes | | |
| PQ-004-3 | `grep -r "hapi.fhir.org" src/test/resources/` | Returns only `karate-config.js` — no hardcoded URLs in feature files | | |
| PQ-004-4 | Review `karate-config.js` | `baseUrl` reads from `karate.properties['baseUrl']` with fallback default | | |

**PQ-004 Overall Result:** ☐ Pass  ☐ Fail

---

## 8. PQ-005: End-to-End Git Audit Trail Integrity

**Objective:** Confirm that the complete Git audit trail — from source commit to CI pipeline run to archived evidence — is intact, unbroken, and retrievable for a real validation execution.

**Rationale:** This PQ step validates Git's role as the document control and evidence chain system in an integrated, realistic context. IQ verified installation and OQ verified individual Git operations. PQ-005 verifies the complete chain functions end to end across a full validation cycle, satisfying REQ-GEN-006 and REQ-GEN-007.

**Execution Steps:**

| Step ID | Action | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-005-1 | Identify the commit SHA of the last merge to `main` that triggered a full validation run | SHA is recorded and retrievable via `git log --oneline main` | | |
| PQ-005-2 | Locate the corresponding GitHub Actions pipeline run triggered by that commit | Pipeline run visible in GitHub Actions UI — run number recorded | | |
| PQ-005-3 | Confirm the commit SHA in the pipeline log matches the identified commit | `Record commit SHA` step output matches SHA from PQ-005-1 | | |
| PQ-005-4 | Download the archived validation artifact from that pipeline run | Artifact downloads successfully and is readable | | |
| PQ-005-5 | Confirm the artifact contains Karate HTML report with test results | Report present, pass/fail counts visible | | |
| PQ-005-6 | Confirm the artifact contains HL7 Validator output | Validator JSON results present | | |
| PQ-005-7 | `git show {SHA from PQ-005-1} --stat` | Returns commit details — author, date, changed files — confirming source state is permanently retrievable | | |

**End-to-End Evidence Record:**

| Field | Value |
|---|---|
| Commit SHA | |
| Commit Author | |
| Commit Timestamp | |
| Pipeline Run Number | |
| Artifact Name | |
| Artifact Downloaded | Yes / No |
| Karate Report Present in Artifact | Yes / No |
| HL7 Validator Output Present in Artifact | Yes / No |
| Source State Retrievable by SHA | Yes / No |

**Acceptance Criteria:** All seven steps pass. The commit SHA must be traceable forward to a pipeline run and backward to the exact source files that were committed. This constitutes the regulatory evidence chain required under 21 CFR Part 820.40 and REQ-GEN-006.

**PQ-005 Overall Result:** ☐ Pass  ☐ Fail

---

## 9. PQ Summary

| Test | Steps | Passed | Failed | Overall | Date Completed | Initials |
|---|---|---|---|---|---|---|
| PQ-001: Local Execution | 7 | | | | | |
| PQ-002: CI Execution | 7 | | | | | |
| PQ-003: Reproducibility | 4 | | | | | |
| PQ-004: Config Switch | 4 | | | | | |
| PQ-005: Git Audit Trail | 7 | | | | | |
| **Total** | **29** | | | | | |

**PQ Overall Status:** ☐ Pass  ☐ Fail

---

## 10. Full Qualification Summary

| Phase | Document | Status | Date Completed | Qualified By |
|---|---|---|---|---|
| IQ | TQ-FHIR-IQ-001 | | | |
| OQ | TQ-FHIR-OQ-001 | | | |
| PQ | TQ-FHIR-PQ-001 | | | |
| **Overall** | | | | |

**The toolchain is qualified for use in regulated validation activities when all three phases are passed with no open deviations.**

---

## 11. Requalification Triggers

This qualification must be repeated or partially repeated if any of the following occur:

| Trigger | Requalification Scope |
|---|---|
| Git version upgrade | IQ-GIT + PQ-005 |
| Branch protection rules changed | IQ-GIT-007 + OQ-GIT-004 |
| `.gitignore` modified | IQ-GIT-003 through IQ-GIT-006 + OQ-GIT-005 + PQ-001 step 7 |
| GitHub repository transferred or renamed | IQ-GIT-002 + PQ-002 + PQ-005 |
| Karate version upgrade | OQ-KAR full repeat + PQ-001, PQ-002, PQ-003 |
| HL7 Validator version upgrade | OQ-VAL full repeat + PQ-001, PQ-002 |
| Java version change | IQ-JDK + PQ-001, PQ-002 |
| Maven version change | IQ-MVN + PQ-001 |
| GitHub Actions runner OS change | PQ-002 full repeat |
| New FHIR resource added to suite | PQ-001, PQ-002, PQ-003 |
| Change to `karate-config.js` | PQ-004 |
| Change to `ValidationRunner.java` | PQ-001, PQ-002, PQ-003 |
| Change to CI workflow YAML | IQ-GHA + PQ-002 + PQ-005 |

---

## 12. Deviation Log

| ID | Phase | Step | Deviation Description | Resolution | Resolved Date | Initials |
|---|---|---|---|---|---|---|
| | | | | | | |

---

## 13. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Git version to PQ-001 environment record; added PQ-001 step 7 verifying git status clean after integrated test run; added PQ-002 step 7 verifying commit SHA matches in pipeline; added Git Status Clean column to PQ-003 results table; added PQ-005 End-to-End Git Audit Trail Integrity (7 steps); updated preconditions to include Git and .gitignore checks; updated PQ summary totals; added Git-related requalification triggers |
| 1.2 | 2026-04-06 | Amir Choshov | Added scope note to PQ-004 clarifying R5 endpoint use is a forward-compatibility configuration experiment, not a PQ acceptance criterion. Consistent with VP-FHIR-001 Section 2.2 scope exclusion.
---

## 14. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | | |
| Reviewer | | | |

---

*PQ completion closes the tool qualification cycle. The framework may be used to generate regulated validation evidence only after all three phases — IQ, OQ, and PQ — are passed with no open deviations. Any post-qualification changes listed in the requalification triggers table require partial or full requalification before evidence generated after that change is considered valid.*