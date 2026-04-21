# Gap Analysis

## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | GA-FHIR-001 |
| **Version** | 1.3 |
| **Status** | Final |
| **Author** | Amir Choshov |
| **Date** | 2026-04-13 |
| **Project** | FHIR R4 API Validation Suite |
| **Related Documents** | RS-FHIR-001 v1.4, TP-FHIR-001 v1.6, TM-FHIR-001 v1.6 |

---

## 1. Purpose

This Gap Analysis formally documents that requirements coverage
analysis was performed for the FHIR R4 API Validation Suite prior
to Performance Qualification (PQ) execution. It verifies that all
active requirements are mapped to at least one test case, all test
cases are mapped to at least one requirement, and no orphaned
requirements or tests exist.

Per 21 CFR Part 820.30(f) and IEC 62304 §5.7, design verification
must demonstrate that software requirements have been tested. This
document provides that verification.

---

## 2. Scope

| Item | Value |
|---|---|
| Requirements source | RS-FHIR-001 v1.4 |
| Active requirements | 68 |
| Retired requirements | 1 (REQ-GEN-002 — split into REQ-GEN-002a and REQ-GEN-002b) |
| Test plan source | TP-FHIR-001 v1.6 |
| Total test cases | 83 |
| Automated test cases | 80 |
| Non-automated test cases | 3 (TC-FRM-001, TC-FRM-002, TC-FRM-003) |
| Traceability source | TM-FHIR-001 v1.6 |
| Analysis date | 2026-04-11 |
| Analyst | Amir Choshov |

---

## 3. Methodology

Coverage was verified by bidirectional traceability review of
TM-FHIR-001 v1.6:

1. **Forward trace** — each active requirement mapped to at least
   one test case (requirement → test). Orphaned requirements
   (requirements with no test case) were identified and counted.

2. **Backward trace** — each test case mapped to at least one
   requirement (test → requirement). Orphaned tests (test cases
   with no requirement) were identified and counted.

3. **Automated coverage** — each automated test case confirmed
   present as a Scenario block in the corresponding feature file
   and executed through CI Run #3 (commit 4458f7dd) and local run
   (commit af2bf2c5).

4. **Non-automated coverage** — TC-FRM-001, TC-FRM-002, TC-FRM-003
   verified as manual IQ/OQ checklist items per their disposition
   in TP-FHIR-001 v1.6.

5. **Automated traceability verification** — scripts/verify-traceability.sh
   executed in CI on every push to main. Checks: (a) every automated TC
   in feature files is present in TM, (b) every non-FRM TC in TM has a
   feature file implementation, (c) total active requirement count matches
   68. Script exits non-zero on any gap, failing the CI pipeline before
   test execution begins.

---

## 4. Findings

### 4.1 Forward Trace Results

| Metric | Count |
|---|---|
| Active requirements analyzed | 68 |
| Requirements with ≥1 test case | 68 |
| Orphaned requirements (no test case) | 0 |

**Result: No orphaned requirements. 100% forward coverage confirmed (68/68 active requirements).**

### 4.2 Backward Trace Results

| Metric | Count |
|---|---|
| Total test cases analyzed | 83 |
| Test cases with ≥1 requirement | 83 |
| Orphaned test cases (no requirement) | 0 |

**Result: No orphaned test cases. 100% backward coverage confirmed.**

### 4.3 Automated Execution Coverage

| Metric | Count |
|---|---|
| Automated TCs in feature files | 80 |
| Automated TCs executed (CI Run #3 + hardening run) | 80 |
| Passed | 80 |
| Failed | 0 |
| Skipped | 0 |

**Result: 100% automated execution coverage. All 80 automated TCs
passed — 74 in CI Run #3 (commit 4458f7dd, 2026-04-08) and 6 new
TCs in hardening pass (commit af2bf2c5, 2026-04-11).**

Run 5 (2026-04-20): 80/80 PASS against local Docker HAPI FHIR R4
(hapiproject/hapi:v7.4.0), Synthea synthetic data seed 42, 55 patients
(Massachusetts). SHA c2d0e4c. Full execution record in TQ-FHIR-PQ-001
v1.5 §6 PQ-003 Run 5.

### 4.4 Non-Automated TC Disposition

| TC ID | Description | Verification Method | Status |
|---|---|---|---|
| TC-FRM-001 | Suite executes against configurable base URL | IQ verification step IQ-KAR-001 | Verified |
| TC-FRM-002 | Test report linked to Git commit SHA | OQ verification step OQ-GHA-005 | Verified |
| TC-FRM-003 | Git branch protection active on main | IQ verification step IQ-GIT-008 (DEV-IQ-001) | Verified — DEV-IQ-001 resolved 2026-04-09 per IQ.md v1.3; branch protection confirmed active on main |

### 4.5 Retired Requirements

| Req ID | Disposition | Replacement |
|---|---|---|
| REQ-GEN-002 | Retired — split for independent testability | REQ-GEN-002a (meta.lastUpdated), REQ-GEN-002b (meta.versionId) |

---

## 5. Gap Summary

| Gap Type | Count | Detail |
|---|---|---|
| Orphaned requirements | 0 | None |
| Orphaned test cases | 0 | None |
| Untested active requirements | 0 | None |
| Unexecuted automated TCs | 0 | None |
| Open deviations affecting coverage | 0 | DEV-IQ-001 resolved 2026-04-09 — branch protection active on main; TC-FRM-003 Verified |

---

## 6. Conclusion

Coverage analysis is complete. No gaps were identified in forward
or backward traceability. All 68 active requirements are tested by
at least one of the 83 test cases. All 80 automated test cases
passed execution across CI Run #3 and the hardening pass.
Non-automated TCs are formally verified via IQ/OQ qualification
evidence.

All open deviations have been resolved. DEV-IQ-001 (branch protection)
was resolved on 2026-04-09 and TC-FRM-003 is Verified per IQ.md v1.3.
Zero open deviations affect coverage. The suite meets all exit criteria
defined in TP-FHIR-001 v1.6.

**The suite is approved to proceed to Performance Qualification
(PQ) execution.**

---

## 7. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | Amir Choshov | 2026-04-08 |
| Reviewer | Amir Choshov | Amir Choshov | 2026-04-08 |

*Note: Independent reviewer not applicable for individual portfolio
project. Author serves as sole reviewer.*

---

## 8. Change History

| Version | Date | Author | Description |
|---|---|---|---|
| 1.0 | 2026-04-08 | Amir Choshov | Initial release — coverage analysis complete, no gaps found |
| 1.1 | 2026-04-11 | Amir Choshov | Updated to TP-FHIR-001 v1.5 (83 TCs, 80 automated) and TM-FHIR-001 v1.5. Counts updated throughout. No new gaps identified. |
| 1.2 | 2026-04-12 | Amir Choshov | Updated RS/TP/TM citations to current versions (RS v1.4, TP v1.6, TM v1.6); updated requirement count 61→68, TC count 77→83; updated TC-FRM-003 disposition to Verified; corrected §5 to reflect DEV-IQ-001 resolution (open deviations affecting coverage 1→0) |
| 1.3 | 2026-04-13 | Amir Choshov | Fixed stale TP/TM citations v1.5→v1.6 in scope table and §3 body; corrected §6 conclusion to reflect DEV-IQ-001 resolution (0 open deviations); consistent with §4.4 and §5 |

---

## 9. Change Control Register

| Field | Detail |
|---|---|
| **Change ID** | CCR-004 |
| **Date** | 2026-04-16 |
| **Author** | Amir Choshov |
| **Type** | Infrastructure Addition |
| **Description** | Add local Docker-based HAPI FHIR R4 server as the validated test execution target. Add Synthea synthetic patient generation with fixed seed for controlled, reproducible test data. Replaces dependency on public HAPI sandbox (hapi.fhir.org/baseR4). |
| **Affected Documents** | AD, IQ, OQ, PQ, VA |
| **Rationale** | Public sandbox is an uncontrolled environment — subject to outages, data mutation, and schema changes outside this project's change control. Local server with fixed Synthea seed satisfies reproducibility requirements for a maintained validated state. |
| **Status** | Closed |
| **Closure Date** | 2026-04-18 |
| **Closure Note** | IQ-010 through IQ-016 executed and passed. IQ-FHIR-IQ-001 updated to v1.5, overall status PASS. Docker local environment qualification complete. |

| Field | Detail |
|---|---|
| **Change ID** | CCR-005 |
| **Date** | 2026-04-21 |
| **Author** | Amir Choshov |
| **Type** | Dependency Update |
| **Description** | Update all GitHub Actions action versions to Node.js 24 compatible releases. actions/checkout v4→v5, actions/cache v4→v5, actions/setup-java v4→v5, actions/upload-artifact v4→v6, peaceiris/actions-gh-pages v3→v4 (already applied in SHA 8921e3b). Resolves Node.js 20 deprecation warnings on every CI run (DEV-OQ-001, DEV-PQ-001). Node.js 24 becomes the default runtime on June 2, 2026 — all actions must be updated before that date. |
| **Affected Documents** | OQ, PQ |
| **Rationale** | GitHub will remove Node.js 20 runner support in September 2026. Proactive update eliminates recurring deviation before it becomes a blocking issue. |
| **Status** | Partially Closed |
| **Closure Date** | 2026-04-21 |
| **Closure Note** | actions/checkout v4→v5, actions/cache v4→v5, actions/setup-java v4→v5, actions/upload-artifact v4→v6 all updated to Node.js 24 compatible versions. peaceiris/actions-gh-pages@v4 remains on Node.js 20 — no upstream Node.js 24 release available as of 2026-04-21. Monitoring for upstream update before June 2, 2026 deadline. DEV-OQ-001 and DEV-PQ-001 remain Open — pending upstream release. |

---

## 10. Known Issues

### KI-001 — CVE in bundled HL7 Validator (hapiproject/hapi:v7.4.0)

| Field | Detail |
|---|---|
| **Date Identified** | 2026-04-17 |
| **Component** | org.hl7.fhir.validation-6.3.11.jar bundled in hapiproject/hapi:v7.4.0 |
| **CVE CVSS Score** | 9.8 (Critical) |
| **Fix Version per CVE** | org.hl7.fhir.validation 6.9.0+ |
| **Owner** | Amir Choshov |

**Remediation evaluated:**
hapiproject/hapi:v7.6.0 bundles org.hl7.fhir.validation-6.4.0 — still below fix version.
Additionally, v7.6.0 introduces confirmed behavioral regressions: `allow_multiple_delete`
env var ignored; search result cache env var ignored (defaults to 60000ms vs required 0ms).
v7.6.0 rejected.

**Mitigating factors:**

- Server is local-only, port 8080 not exposed to internet
- No PHI — dataset is Synthea synthetic patients only
- No production use — portfolio/development environment

**Risk decision:** Accepted for portfolio use

**Remediation path:** Monitor HAPI releases for a version that bundles
org.hl7.fhir.validation 6.9.0+ without behavioral regressions.
Re-evaluate on next image upgrade cycle.
