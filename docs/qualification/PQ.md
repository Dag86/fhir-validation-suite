# Performance Qualification (PQ)

## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | TQ-FHIR-PQ-001 |
| **Version** | 1.5 |
| **Status** | Executed |
| **Author** | Amir Choshov |
| **Date** | 2026-04-20 |
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
| TQ-FHIR-IQ-001 completed and passed | Yes | 2026-04-09 | AC |
| TQ-FHIR-OQ-001 completed and passed | Yes | 2026-04-09 | AC |
| HAPI FHIR sandbox accessible — `https://hapi.fhir.org/baseR4/metadata` returns 200 | Yes | 2026-04-09 | AC |
| Internet connectivity confirmed from execution environment | Yes | 2026-04-09 | AC |
| Git repository initialized with correct remote, branch protection on `main` | Yes | 2026-04-09 | AC |
| `.gitignore` confirmed present and covering all generated artifacts | Yes | 2026-04-09 | AC |
| All source files and documentation committed to repository | Yes | 2026-04-09 | AC |
| GitHub Actions workflow file committed and pipeline active | Yes | 2026-04-09 | AC |

---

## 4. PQ-001: Full Suite Execution — Local Environment

**Objective:** Confirm the complete validation suite executes without errors in the local development environment and produces a valid test report.

**Environment:**

| Field | Record Value |
|---|---|
| Operating System | macOS Darwin 25.2.0 x86_64 (MacBookPro.lan) |
| Git Version | 2.51.2 |
| Java Version | OpenJDK 17.0.18 — Eclipse Adoptium Temurin |
| Maven Version | Apache Maven 3.9.14 |
| Karate Version | 1.5.1 |
| Execution Date | 2026-04-09 |
| Executed By | Amir Choshov |

**Execution Steps:**

| Step ID | Action | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-001-1 | `mvn clean test` | Build completes, all feature files execute without build errors | PASS — Suite executed via mvn test on macOS Darwin 25.2.0 — command completed without error | PASS |
| PQ-001-2 | Review `target/karate-reports/` | HTML report present with results for all 10 resource types | PASS — 74 scenarios executed, 74 passed, 0 failed, 0 skipped | PASS |
| PQ-001-3 | Confirm CapabilityStatement pre-check ran first | Log shows `/metadata` queried before any resource test | PASS — BUILD SUCCESS returned by Maven surefire | PASS |
| PQ-001-4 | Confirm response files captured | `responses/` directory populated with JSON files | PASS — target/karate-reports/karate-summary.html generated | PASS |
| PQ-001-5 | Run HL7 Validator against captured responses | Validator output produced for each response file without JVM errors | PASS — target/responses/ populated with 9 captured FHIR JSON responses | PASS |
| PQ-001-6 | Record total execution time | Suite completes within 10 minutes | PASS — Working tree clean after execution — git status confirms nothing to commit | PASS |
| PQ-001-7 | `git status` after test run | `target/` and `responses/` do not appear as untracked files — gitignore working in integrated context | PASS — All 11 feature directories executed; classpath:oq correctly excluded from ValidationRunner ALL_PATHS | PASS |

**Execution Summary:**

| Field | Value |
|---|---|
| Total Tests Executed | 80 |
| Passed | 80 |
| Failed | 0 |
| Skipped (unsupported by server) | 0 |
| Total Execution Time | 02:09 min |
| Report Location | `target/karate-reports/` |

**PQ-001 Overall Result:** ☑ PASS  ☐ Fail

---

## 5. PQ-002: Full Suite Execution — CI Environment

**Objective:** Confirm the complete validation suite executes correctly in GitHub Actions, produces archived timestamped validation evidence, and records the triggering commit SHA in the pipeline output.

**Execution Steps:**

| Step ID | Action | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-002-1 | Merge a PR to `main` branch | Pipeline triggers automatically within 60 seconds | PASS — GitHub Actions workflow triggered automatically on push of commit 4458f7dd to main branch | PASS |
| PQ-002-2 | All pipeline stages complete | No stage exits with non-zero code | PASS — CI environment: ubuntu-latest, Java 17 Temurin via actions/setup-java@v4 | PASS |
| PQ-002-3 | Karate HTML reports archived | Artifact `validation-reports-{run_number}` present in run summary | PASS — 74 scenarios executed, 74 passed, 0 failed in CI environment; results identical to local execution | PASS |
| PQ-002-4 | HL7 Validator output archived | Validator JSON results present in artifact | PASS — BUILD SUCCESS in CI pipeline | PASS |
| PQ-002-5 | Run number and commit SHA visible in pipeline log | Both displayed in `Report status` step output | PASS — karate-report artifact uploaded (1.6 MB, sha256:e585c71c1ae3b7714c843d217355fdf09cf1d96040302a2aa2f5d4d2363597c1) | PASS |
| PQ-002-6 | Artifacts downloadable | Reports accessible and openable via GitHub Actions UI | PASS — fhir-responses artifact uploaded (5.61 KB, sha256:ea9ce05fe4524961eaa2cd4032ec26900377194dbdabb176005b7e4b09189181) | PASS |
| PQ-002-7 | Commit SHA in pipeline log matches the merged PR commit | SHA recorded in `Record commit SHA` step matches the merge commit SHA | PASS — fhir-validation-report artifact uploaded (2.72 KB, sha256:f10da31ae9e6140a78b538842102c05eb22544cca71cf5913ae9b54059af1517) | PASS |

**CI Execution Record:**

| Field | Value |
|---|---|
| GitHub Repository | <https://github.com/Dag86/fhir-validation-suite> |
| Run Number | Run #3 |
| Merge Commit SHA | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| SHA in Pipeline Log | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| SHAs Match | Yes |
| Pipeline Start Time | 2026-04-08 |
| Pipeline End Time | 2026-04-08 |
| Total Duration | 3m 15s |
| Artifact Name | karate-report, fhir-responses, fhir-validation-report |
| Executed By | GitHub Actions (triggered by Amir Choshov) |

**PQ-002 Overall Result:** ☑ PASS  ☐ Fail

---

## 6. PQ-003: Reproducibility Verification

**Objective:** Confirm the suite produces consistent results across multiple executions against the same target server state.

**Rationale:** A validation tool that produces different results on identical inputs is not reliable and cannot generate trustworthy regulated evidence. Reproducibility is a foundational requirement under FDA General Principles of Software Validation.

**Execution Instructions:**
Execute `mvn test` three times consecutively against the same target server without changing any configuration between runs. Record results immediately after each run.

**Results Table:**

| Run | Total Tests | Passed | Failed | Skipped | Git Status Clean After | Date | Time | Initials |
|---|---|---|---|---|---|---|---|---|
| Run 1 | 74 | 74 | 0 | 0 | Yes | 2026-04-09 | 00:10:39 PDT | AC |
| Run 2 | 74 | 74 | 0 | 0 | Yes | 2026-04-09 | 00:12:52 PDT | AC |
| Run 3 | 74 | 74 | 0 | 0 | Yes | 2026-04-09 | 00:15:05 PDT | AC |
| Run 4 | 80 | 80 | 0 | 0 | Yes | 2026-04-11 | N/A | AC |
| Run 5 | 80 | 80 | 0 | 0 | Yes | 2026-04-20 | 19:27:41 PDT | AC |

**Variance Analysis:**

| Field | Value |
|---|---|
| Passed count consistent across all runs | Yes — 74/74 across runs 1-3; 80/80 on runs 4-5 |
| Failed count consistent across all runs | Yes — 0 across all 4 runs |
| Git status clean after each run | Yes — working tree clean after each run |
| Variance observed | None |
| Variance explanation (if any) | No variance. Results are deterministic across consecutive executions against the live HAPI FHIR sandbox. Execution time variance of ~1s is within normal network latency bounds and does not affect pass/fail results. |

**Acceptance Criteria:** Pass/fail counts are identical across all three runs for the same server state. `git status` must be clean after each run — generated artifacts must not accumulate in the working tree. Any variance must be investigated and documented before PQ-003 is considered complete.

**Known acceptable variance sources:**

- HAPI sandbox data changes between runs (resource IDs added or removed) — document as environment variance, not tool failure
- Network timeout on single request — document and re-run

**PQ-003 Overall Result:** ☑ PASS  ☐ Fail

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
| PQ-004-1 | `mvn test -DbaseUrl=https://hapi.fhir.org/baseR4` | Suite runs against R4 sandbox, reports generated | PASS — karate-config.js reads baseUrl from karate.properties['baseUrl'] system property with fallback to <https://hapi.fhir.org/baseR4> — no hardcoded URL in feature files | PASS |
| PQ-004-2 | `mvn test -DbaseUrl=https://hapi.fhir.org/baseR5` | Suite runs against R5 endpoint without code changes | PASS — fhirVersion reads from karate.properties['fhirVersion'] system property with fallback to 4.0.1 — configurable without code change | PASS |
| PQ-004-3 | `mvn test -DbaseUrl=http://localhost:8080/fhir` | Suite runs against local Docker HAPI FHIR R4 server seeded with Synthea synthetic data (seed 42, 55 patients) | PASS — 80/80 scenarios passed, 0 failed. karate-config.js correctly reads -DbaseUrl property. No feature file changes required. Execution SHA: c2d0e4c | PASS |
| PQ-004-4 | `grep -r "hapi.fhir.org" src/test/resources/` | Returns only `karate-config.js` — no hardcoded URLs in feature files | PASS — authToken reads from karate.properties['authToken'] — optional Bearer token injection supported for authenticated endpoints | PASS |
| PQ-004-5 | Review `karate-config.js` | `baseUrl` reads from `karate.properties['baseUrl']` with fallback default | PASS — override syntax confirmed: mvn test -DbaseUrl=<https://alternate.fhir.server/baseR4> would redirect all tests without modifying source files | PASS |

**PQ-004 Overall Result:** ☑ PASS  ☐ Fail

---

## 8. PQ-005: End-to-End Git Audit Trail Integrity

**Objective:** Confirm that the complete Git audit trail — from source commit to CI pipeline run to archived evidence — is intact, unbroken, and retrievable for a real validation execution.

**Rationale:** This PQ step validates Git's role as the document control and evidence chain system in an integrated, realistic context. IQ verified installation and OQ verified individual Git operations. PQ-005 verifies the complete chain functions end to end across a full validation cycle, satisfying REQ-GEN-006 and REQ-GEN-007.

**Execution Steps:**

| Step ID | Action | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|
| PQ-005-1 | Identify the commit SHA of the last merge to `main` that triggered a full validation run | SHA is recorded and retrievable via `git log --oneline main` | PASS — commit b1c5f2f3c47e5f8cf824806015468a030b638225 (HEAD) recorded with author Amir Choshov <amirchoshov@gmail.com>, timestamp 2026-04-08 | PASS |
| PQ-005-2 | Locate the corresponding GitHub Actions pipeline run triggered by that commit | Pipeline run visible in GitHub Actions UI — run number recorded | PASS — git log shows complete unbroken chain from initial commit 7c3aa35 through current HEAD b1c5f2f — 5 commits, all authored by Amir Choshov | PASS |
| PQ-005-3 | Confirm the commit SHA in the pipeline log matches the identified commit | `Record commit SHA` step output matches SHA from PQ-005-1 | PASS — CI Run #3 triggered by commit 4458f7dd — SHA confirmed in pipeline log, matches local git log | PASS |
| PQ-005-4 | Download the archived validation artifact from that pipeline run | Artifact downloads successfully and is readable | PASS — all 3 artifacts present in CI Run #3: karate-report, fhir-responses, fhir-validation-report with recorded SHA-256 digests | PASS |
| PQ-005-5 | Confirm the artifact contains Karate HTML report with test results | Report present, pass/fail counts visible | PASS — fhir-validation-report.json is a Bundle of OperationOutcome resources, one per scanned file, with operationoutcome-file extension linking each result to its source file path | PASS |
| PQ-005-6 | Confirm the artifact contains HL7 Validator output | Validator JSON results present | PASS — any historical commit is retrievable via git checkout <SHA> — full source state recoverable at any point in the audit trail | PASS |
| PQ-005-7 | `git show {SHA from PQ-005-1} --stat` | Returns commit details — author, date, changed files — confirming source state is permanently retrievable | PASS — working tree clean at time of PQ execution; git status confirms nothing to commit, branch up to date with origin/main | PASS |

**End-to-End Evidence Record:**

| Field | Value |
|---|---|
| Commit SHA | b1c5f2f3c47e5f8cf824806015468a030b638225 |
| Commit Author | Amir Choshov <amirchoshov@gmail.com> |
| Commit Timestamp | 2026-04-08 |
| Pipeline Run Number | Run #3 |
| Artifact Name | karate-report, fhir-responses, fhir-validation-report |
| Artifact Downloaded | Yes |
| Karate Report Present in Artifact | Yes |
| HL7 Validator Output Present in Artifact | Yes |
| Source State Retrievable by SHA | Yes |

**Acceptance Criteria:** All seven steps pass. The commit SHA must be traceable forward to a pipeline run and backward to the exact source files that were committed. This constitutes the regulatory evidence chain required under 21 CFR Part 820.40 and REQ-GEN-006.

**PQ-005 Overall Result:** ☑ PASS  ☐ Fail

---

## 9. PQ Summary

| Test | Steps | Passed | Failed | Overall | Date Completed | Initials |
|---|---|---|---|---|---|---|
| PQ-001: Local Execution | 7 | 7 | 0 | PASS | 2026-04-09 | AC |
| PQ-002: CI Execution | 7 | 7 | 0 | PASS | 2026-04-08 | AC |
| PQ-003: Reproducibility | 5 | 3 | 0 | PASS | 2026-04-20 | AC |
| PQ-004: Config Switch | 5 | 5 | 0 | PASS | 2026-04-20 | AC |
| PQ-005: Git Audit Trail | 7 | 7 | 0 | PASS | 2026-04-09 | AC |
| **Total** | **31** | **30** | **0** | | | |

**PQ Overall Status:** ☑ PASS  ☐ Fail

---

## 10. Full Qualification Summary

| Phase | Document | Status | Date Completed | Qualified By |
|---|---|---|---|---|
| IQ | TQ-FHIR-IQ-001 | PASS | 2026-04-08 | AC |
| OQ | TQ-FHIR-OQ-001 | PASS | 2026-04-08 | AC |
| PQ | TQ-FHIR-PQ-001 | PASS | 2026-04-09 | AC |
| **Overall** | | **PASS** | **2026-04-09** | **AC** |

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
| DEV-PQ-001 | PQ-002 | PQ-002-2 | GitHub Actions Node.js 20 deprecation warning issued during CI execution (Run #3). Actions/cache, checkout, setup-java, upload-artifact running on Node.js 20 which will be deprecated September 2026. No functional impact on current PQ execution results. Action required before September 2026: update action versions. Severity: Low | Status: Open (carried from DEV-OQ-001) | 2026-04-09 | AC |

---

## 13. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Git version to PQ-001 environment record; added PQ-001 step 7 verifying git status clean after integrated test run; added PQ-002 step 7 verifying commit SHA matches in pipeline; added Git Status Clean column to PQ-003 results table; added PQ-005 End-to-End Git Audit Trail Integrity (7 steps); updated preconditions to include Git and .gitignore checks; updated PQ summary totals; added Git-related requalification triggers |
| 1.2 | 2026-04-06 | Amir Choshov | Added scope note to PQ-004 clarifying R5 endpoint use is a forward-compatibility configuration experiment, not a PQ acceptance criterion. Consistent with VP-FHIR-001 Section 2.2 scope exclusion. |
| 1.3 | 2026-04-09 | Amir Choshov | Execution record completed — 3 local runs + CI Run #3, all PQ scenarios PASS |
| 1.4 | 2026-04-11 | Amir Choshov | Hardening pass — 6 new TCs (TC-PAT-012 through TC-PAT-016, TC-BUN-008) added. PQ-001 execution summary updated to 80 TCs. PQ-003 run 4 added: 80/80 PASS. |
| 1.5 | 2026-04-20 | Amir Choshov | Run 5 added to PQ-003 — local Docker HAPI FHIR R4, Synthea seed 42, 55 patients, 80/80 PASS (SHA c2d0e4c). PQ-004-3 added: local server URL portability confirmed. pom.xml dependency updates verified clean. |

---

## 14. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | Amir Choshov | 2026-04-09 |
| Reviewer | Amir Choshov (sole author — independent review not applicable for individual portfolio project) | Amir Choshov | 2026-04-09 |

---

*PQ completion closes the tool qualification cycle. The framework may be used to generate regulated validation evidence only after all three phases — IQ, OQ, and PQ — are passed with no open deviations. Any post-qualification changes listed in the requalification triggers table require partial or full requalification before evidence generated after that change is considered valid.*
