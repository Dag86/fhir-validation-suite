# Traceability Matrix

## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | TM-FHIR-001 |
| **Version** | 1.6 |
| **Status** | Executed |
| **Author** | Amir Choshov |
| **Date** | 2026-04-12 |
| **Project** | FHIR R4 API Validation Suite |
| **Requirements Source** | RS-FHIR-001 v1.4 — 68 active requirements |
| **Test Case Source** | TP-FHIR-001 v1.6 — 83 test cases |

---

## 1. Purpose

This Traceability Matrix establishes bidirectional traceability between every requirement in RS-FHIR-001 and every test case in TP-FHIR-001. It is used to:

- Confirm 100% requirement coverage before validation is considered complete
- Identify any requirements without test cases (coverage gaps)
- Identify any test cases without requirements (orphan tests)
- Record test execution results against each requirement
- Provide an auditable record linking regulatory standards to validation evidence

This document is a living artifact — test execution results are recorded here as testing is performed. The matrix is complete when all requirements have at least one test case with a recorded result.

---

## 2. How to Use This Matrix

**During test planning:** Verify every requirement has at least one test case. Any row with an empty Test Case ID column is a gap that must be resolved before testing begins.

**During test execution:** Record Pass, Fail, or Skip in the Result column after each test case executes. Record the execution date and the Git commit SHA of the run per REQ-GEN-006.

**After test execution:** Review the Coverage Summary in Section 6. Any requirement without a Pass result must have a documented disposition in the Gap Analysis (GA-FHIR-001).

**Result values:**

- **Pass** — all mapped test cases passed for this requirement
- **Fail** — one or more mapped test cases failed
- **Skip** — test cases skipped because server does not support the resource
- **Partial** — some test cases passed, some failed — detail in Gap Analysis
- **Pending** — not yet executed

---

## 3. Forward Trace — Requirements to Test Cases

### 3.1 Pre-Validation Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-PRE-001 | CapabilityStatement queried before all tests | B | False failures from unsupported capabilities | TC-CAP-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PRE-002 | CapabilityStatement returns 200 and valid resourceType | B | Server non-compliance with base FHIR spec | TC-CAP-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PRE-003 | FHIR R4 version declared (4.0.x) | B | Version mismatch causing incorrect data interpretation | TC-CAP-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.2 Patient Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-PAT-001 | GET /Patient/{id} returns 200 and Patient resourceType | C | System failure preventing patient data retrieval | TC-PAT-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-002 | name.family present | C | Wrong patient selection due to missing identity | TC-PAT-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-003 | identifier has system and value | C | Duplicate patient records, wrong-patient events | TC-PAT-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-004 | birthDate format is YYYY-MM-DD | C | Age-dependent dosing errors from malformed date | TC-PAT-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-005 | gender is valid value set member | C | Gender-specific clinical decision errors | TC-PAT-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-006 | meta.lastUpdated present | C | Inability to reconstruct data change history | TC-PAT-006 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-007 | Non-existent ID returns 404 + OperationOutcome | C | Silent failure masking missing patient records | TC-PAT-007 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-008 | Search returns searchset Bundle | C | Incorrect results leading to wrong patient selection | TC-PAT-008 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PAT-012 | Conditional read returns 304 when ETag matches | C | Identity integrity — stale cache serving outdated patient record could lead to wrong treatment decision | TC-PAT-012 | PASS | 2026-04-11 | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |
| REQ-PAT-013 | Search by gender returns searchset Bundle | C | Identity — inability to filter by demographic could return wrong patient record | TC-PAT-013 | PASS | 2026-04-11 | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |
| REQ-PAT-014 | Search by birthdate returns searchset Bundle | C | Identity — incorrect birthdate search could return wrong patient record | TC-PAT-014 | PASS | 2026-04-11 | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |
| REQ-PAT-015 | Search by identifier returns searchset Bundle | C | Identity — identifier search is the primary mechanism for unique patient lookup in clinical systems | TC-PAT-015 | PASS | 2026-04-11 | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |
| REQ-PAT-016 | Search by _id returns searchset Bundle | C | Identity — _id search must return exactly the requested patient, not a similar one | TC-PAT-016 | PASS | 2026-04-11 | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |

---

### 3.3 Observation Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-OBS-001 | GET /Observation/{id} returns 200 and Observation resourceType | C | System failure preventing lab result retrieval | TC-OBS-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OBS-002 | status is valid ObservationStatus value | C | Clinician acting on preliminary result as final | TC-OBS-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OBS-003 | code.coding has system and code | C | Unidentifiable observation type | TC-OBS-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OBS-004 | valueQuantity has value and unit | C | Unit-of-measure errors in dosing calculations | TC-OBS-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OBS-005 | subject references Patient | C | Observation attributed to wrong patient | TC-OBS-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OBS-006 | meta.lastUpdated present | C | Inability to determine when result was recorded | TC-OBS-006 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OBS-007 | Non-existent ID returns 404 + OperationOutcome | C | Silent failure masking missing lab results | TC-OBS-007 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.4 AllergyIntolerance Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-ALG-001 | GET /AllergyIntolerance/{id} returns 200 and resourceType | C | System failure preventing allergy data retrieval | TC-ALG-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-ALG-002 | clinicalStatus is valid value set member | C | Inactive allergy treated as active or vice versa | TC-ALG-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-ALG-003 | verificationStatus present | C | Unverified allergy driving clinical decision | TC-ALG-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-ALG-004 | patient reference present | C | Allergy attributed to wrong patient | TC-ALG-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-ALG-005 | reaction manifestation has coding | C | Reaction severity unknown to clinician | TC-ALG-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-ALG-006 | Non-existent ID returns 404 + OperationOutcome | C | Silent failure masking missing allergy records | TC-ALG-006 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.5 MedicationRequest Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-MED-001 | GET /MedicationRequest/{id} returns 200 and resourceType | C | System failure preventing medication order retrieval | TC-MED-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-MED-002 | status is valid MedicationRequestStatus value | C | Cancelled order administered due to incorrect status | TC-MED-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-MED-003 | intent is valid value set member | C | Proposal treated as active order | TC-MED-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-MED-004 | medication[x] present | C | Unidentified medication administered | TC-MED-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-MED-005 | subject references Patient | C | Medication administered to wrong patient | TC-MED-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-MED-006 | meta.lastUpdated present | C | Unable to determine when order was placed | TC-MED-006 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-MED-007 | Non-existent ID returns 404 + OperationOutcome | C | Silent failure masking missing medication orders | TC-MED-007 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.6 DiagnosticReport Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-DXR-001 | GET /DiagnosticReport/{id} returns 200 and resourceType | C | System failure preventing diagnostic report retrieval | TC-DXR-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-DXR-002 | status is valid DiagnosticReportStatus value set | C | Preliminary report acted upon as final | TC-DXR-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-DXR-003 | code element present | C | Unidentifiable report type | TC-DXR-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-DXR-004 | subject reference present | C | Report attributed to wrong patient | TC-DXR-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-DXR-005 | Non-existent ID returns 404 + OperationOutcome | C | Silent failure masking missing diagnostic reports | TC-DXR-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.7 AuditEvent Requirements

| Req ID | Description | IEC 62304 | 21 CFR Part 11 | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-AUD-001 | GET /AuditEvent/{id} returns 200 and resourceType | B | 11.10(e) — audit trail availability | TC-AUD-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-AUD-002 | type element present | B | 11.10(e) — event categorization | TC-AUD-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-AUD-003 | recorded timestamp in ISO 8601 | B | 11.10(e) — time-stamped audit trails | TC-AUD-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-AUD-004 | agent array present | B | 11.10(e) — operator identification | TC-AUD-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-AUD-005 | outcome field present | B | 11.10(e) — action result recorded | TC-AUD-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.8 OperationOutcome Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-OO-001 | Error responses return OperationOutcome resourceType | B | Non-FHIR errors breaking client error handling | TC-OO-001, TC-PAT-007, TC-PAT-011, TC-OBS-007, TC-ALG-006, TC-MED-007, TC-MED-009, TC-DXR-005, TC-PRA-004, TC-GEN-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OO-002 | issue array present and non-empty | B | Uninformative error responses | TC-OO-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OO-003 | issue.severity is valid value | B | Severity of error not determinable | TC-OO-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-OO-004 | issue.code is present | B | Error code not determinable | TC-OO-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.9 Bundle Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-BUN-001 | Search returns searchset Bundle | B | Search results in non-standard format | TC-BUN-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-BUN-002 | searchset Bundle has total field | B | Incomplete result set presented as complete | TC-BUN-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-BUN-003 | Each entry has resource and fullUrl | B | Unreferenceable resources in search results | TC-BUN-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-BUN-004 | Valid transaction returns transaction-response Bundle | B | Transaction outcomes not confirmable | TC-BUN-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-BUN-005 | Transaction atomicity — invalid entry fails entire transaction | C | Partial data writes creating incomplete clinical records | TC-BUN-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-BUN-006 | Searchset Bundle contains self link relation | B | Client unable to verify page context or self-reference | TC-BUN-008 | PASS | 2026-04-11 | af2bf2c5d540652079d27d632bb8c06f296d9aa8 |

---

### 3.10 Practitioner Requirements

| Req ID | Description | IEC 62304 | ISO 14971 Risk | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-PRA-001 | GET /Practitioner/{id} returns 200 and resourceType | B | System failure preventing provider identity retrieval | TC-PRA-001, TC-PRA-004 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PRA-002 | name element present | B | Order attributed to unidentified provider | TC-PRA-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-PRA-003 | identifier has system and value if present | B | Duplicate or ambiguous provider records | TC-PRA-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |

---

### 3.11 General Requirements

| Req ID | Description | IEC 62304 | Regulatory Source | Test Case(s) | Result | Exec Date | Commit SHA |
|---|---|---|---|---|---|---|---|
| REQ-GEN-001 | All resources validated by HL7 Validator CLI | B | HL7 FHIR R4 Validation Framework | TC-PAT-009, TC-OBS-008, TC-ALG-007, TC-MED-008, TC-DXR-006, TC-AUD-006, TC-OO-005, TC-BUN-006, TC-PRA-005 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| ~~REQ-GEN-002~~ | ~~Retired v1.2~~ | — | — | ~~Replaced by REQ-GEN-002a and REQ-GEN-002b~~ | Retired | | |
| REQ-GEN-002a | meta.lastUpdated present on all resources | B | 21 CFR Part 11 — 11.10(e) | TC-PAT-006, TC-OBS-006, TC-MED-006, TC-ALG-008 — see Section 4.1 for partial coverage rationale | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-002b | meta.versionId present on all resources | B | 21 CFR Part 11 — 11.10(e) | TC-PAT-010, TC-OBS-009, TC-ALG-008, TC-MED-010, TC-DXR-007, TC-AUD-007, TC-BUN-007, TC-PRA-006 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-003 | Malformed JSON returns 400 + OperationOutcome | B | HL7 FHIR R4 Section 3.1.0.6 | TC-PAT-011, TC-MED-009 — see Section 4.2 for representative coverage rationale | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-004 | Unsupported resource type returns 404 + OperationOutcome | B | HL7 FHIR R4 Section 3.1.0.6 | TC-GEN-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-005 | Configurable base URL — no code changes required | B | Framework design | TC-FRM-001 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-006 | Test reports linked to Git commit SHA | B | 21 CFR Part 820.40 | TC-FRM-002 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-007 | Git branch protection on main | B | 21 CFR Part 820.40 / 21 CFR Part 11 | TC-FRM-003 | PASS | 2026-04-08 | 4458f7dd63e0fd904b1122db075bb26dbdecb740 |
| REQ-GEN-008 | Response time < 10,000ms | B | System latency causing delayed access to clinical data | TC-CAP-001, TC-PAT-013, TC-PAT-014, TC-PAT-015, TC-PAT-016, TC-ALG-001, TC-OBS-001, TC-MED-001, TC-DXR-001, TC-BUN-001, TC-BUN-008, TC-OO-001, TC-GEN-001, TC-AUD-001, TC-PRA-001 | PASS | 2026-04-11 | 7118f602ec98fce9da12ffdf5e4b0c0f42cf1f2d |

---

## 4. Documented Coverage Rationale

### 4.1 REQ-GEN-002a — meta.lastUpdated Partial Coverage

**Requirement:** All resources SHALL contain a `meta.lastUpdated` field.

**Coverage status:** Partial — explicit assertions exist for Patient (TC-PAT-006), Observation (TC-OBS-006), MedicationRequest (TC-MED-006), and AllergyIntolerance (TC-ALG-008). DiagnosticReport, AuditEvent, Bundle, and Practitioner do not have dedicated `meta.lastUpdated` assertions.

**Rationale for acceptance:** `meta.lastUpdated` is a server-assigned field populated by the HAPI FHIR server on every resource write, regardless of resource type. It is not resource-specific logic — it is infrastructure-level behavior applied uniformly across all resource types by the same server component. The four resources with explicit assertions span both Class C and Class B classifications. If `meta.lastUpdated` is present and correctly formatted on Patient, Observation, MedicationRequest, and AllergyIntolerance, the same server behavior is expected across all resource types. This rationale mirrors the established approach for REQ-GEN-003 (malformed JSON handling). Adding identical assertions to the remaining four resources would increase test count without increasing defect detection probability.

**Disposition:** Accepted partial coverage with documented rationale. If this suite is used against a non-HAPI server, the evaluating engineer should verify whether server-level meta population is uniform before accepting this rationale.

---

### 4.2 REQ-GEN-003 — Malformed JSON Representative Coverage

**Requirement:** Requests with malformed JSON bodies SHALL return HTTP status 400 and an `OperationOutcome`.

**Coverage status:** Representative — TC-PAT-011 and TC-MED-009 cover Patient and MedicationRequest respectively.

**Rationale for acceptance:** The server's JSON parsing layer operates upstream of FHIR resource routing. Malformed JSON is rejected before the server determines which resource type is being requested. A failure to reject malformed JSON is therefore a systemic failure at the HTTP/JSON parsing layer, not a resource-specific failure. Coverage against Patient and MedicationRequest — spanning Class C resources — is considered representative. If the server correctly returns HTTP 400 with an OperationOutcome for these resources, the same behavior is expected for all resource types served by the same parsing layer.

**Disposition:** Accepted representative coverage with documented rationale. This is a Class B general requirement; risk of patient harm from this specific gap is low.

---

## 5. Backward Trace — Test Cases to Requirements

This section confirms every test case traces to at least one requirement. Orphan test cases are not permissible in a regulated validation suite.

| TC ID | Mapped Requirement(s) | Orphan? | Automated? |
|---|---|---|---|
| TC-CAP-001 | REQ-PRE-001 | No | Yes |
| TC-CAP-002 | REQ-PRE-002 | No | Yes |
| TC-CAP-003 | REQ-PRE-003 | No | Yes |
| TC-PAT-001 | REQ-PAT-001 | No | Yes |
| TC-PAT-002 | REQ-PAT-002 | No | Yes |
| TC-PAT-003 | REQ-PAT-003 | No | Yes |
| TC-PAT-004 | REQ-PAT-004 | No | Yes |
| TC-PAT-005 | REQ-PAT-005 | No | Yes |
| TC-PAT-006 | REQ-PAT-006, REQ-GEN-002a | No | Yes |
| TC-PAT-007 | REQ-PAT-007, REQ-OO-001 | No | Yes |
| TC-PAT-008 | REQ-PAT-008 | No | Yes |
| TC-PAT-009 | REQ-GEN-001 | No | Yes |
| TC-PAT-010 | REQ-GEN-002b | No | Yes |
| TC-PAT-011 | REQ-GEN-003, REQ-OO-001 | No | Yes |
| TC-PAT-012 | REQ-PAT-012 | No | Yes |
| TC-PAT-013 | REQ-PAT-013 | No | Yes |
| TC-PAT-014 | REQ-PAT-014 | No | Yes |
| TC-PAT-015 | REQ-PAT-015 | No | Yes |
| TC-PAT-016 | REQ-PAT-016 | No | Yes |
| TC-OBS-001 | REQ-OBS-001 | No | Yes |
| TC-OBS-002 | REQ-OBS-002 | No | Yes |
| TC-OBS-003 | REQ-OBS-003 | No | Yes |
| TC-OBS-004 | REQ-OBS-004 | No | Yes |
| TC-OBS-005 | REQ-OBS-005 | No | Yes |
| TC-OBS-006 | REQ-OBS-006, REQ-GEN-002a | No | Yes |
| TC-OBS-007 | REQ-OBS-007, REQ-OO-001 | No | Yes |
| TC-OBS-008 | REQ-GEN-001 | No | Yes |
| TC-OBS-009 | REQ-GEN-002b | No | Yes |
| TC-ALG-001 | REQ-ALG-001 | No | Yes |
| TC-ALG-002 | REQ-ALG-002 | No | Yes |
| TC-ALG-003 | REQ-ALG-003 | No | Yes |
| TC-ALG-004 | REQ-ALG-004 | No | Yes |
| TC-ALG-005 | REQ-ALG-005 | No | Yes |
| TC-ALG-006 | REQ-ALG-006, REQ-OO-001 | No | Yes |
| TC-ALG-007 | REQ-GEN-001 | No | Yes |
| TC-ALG-008 | REQ-GEN-002a, REQ-GEN-002b | No | Yes |
| TC-MED-001 | REQ-MED-001 | No | Yes |
| TC-MED-002 | REQ-MED-002 | No | Yes |
| TC-MED-003 | REQ-MED-003 | No | Yes |
| TC-MED-004 | REQ-MED-004 | No | Yes |
| TC-MED-005 | REQ-MED-005 | No | Yes |
| TC-MED-006 | REQ-MED-006, REQ-GEN-002a | No | Yes |
| TC-MED-007 | REQ-MED-007, REQ-OO-001 | No | Yes |
| TC-MED-008 | REQ-GEN-001 | No | Yes |
| TC-MED-009 | REQ-GEN-003, REQ-OO-001 | No | Yes |
| TC-MED-010 | REQ-GEN-002b | No | Yes |
| TC-DXR-001 | REQ-DXR-001 | No | Yes |
| TC-DXR-002 | REQ-DXR-002 | No | Yes |
| TC-DXR-003 | REQ-DXR-003 | No | Yes |
| TC-DXR-004 | REQ-DXR-004 | No | Yes |
| TC-DXR-005 | REQ-DXR-005, REQ-OO-001 | No | Yes |
| TC-DXR-006 | REQ-GEN-001 | No | Yes |
| TC-DXR-007 | REQ-GEN-002b | No | Yes |
| TC-AUD-001 | REQ-AUD-001 | No | Yes |
| TC-AUD-002 | REQ-AUD-002 | No | Yes |
| TC-AUD-003 | REQ-AUD-003 | No | Yes |
| TC-AUD-004 | REQ-AUD-004 | No | Yes |
| TC-AUD-005 | REQ-AUD-005 | No | Yes |
| TC-AUD-006 | REQ-GEN-001 | No | Yes |
| TC-AUD-007 | REQ-GEN-002b | No | Yes |
| TC-OO-001 | REQ-OO-001 | No | Yes |
| TC-OO-002 | REQ-OO-002 | No | Yes |
| TC-OO-003 | REQ-OO-003 | No | Yes |
| TC-OO-004 | REQ-OO-004 | No | Yes |
| TC-OO-005 | REQ-GEN-001 | No | Yes |
| TC-BUN-001 | REQ-BUN-001 | No | Yes |
| TC-BUN-002 | REQ-BUN-002 | No | Yes |
| TC-BUN-003 | REQ-BUN-003 | No | Yes |
| TC-BUN-004 | REQ-BUN-004 | No | Yes |
| TC-BUN-005 | REQ-BUN-005 | No | Yes |
| TC-BUN-006 | REQ-GEN-001 | No | Yes |
| TC-BUN-007 | REQ-GEN-002b | No | Yes |
| TC-BUN-008 | REQ-BUN-006 | No | Yes |
| TC-PRA-001 | REQ-PRA-001 | No | Yes |
| TC-PRA-002 | REQ-PRA-002 | No | Yes |
| TC-PRA-003 | REQ-PRA-003 | No | Yes |
| TC-PRA-004 | REQ-PRA-001, REQ-OO-001 | No | Yes |
| TC-PRA-005 | REQ-GEN-001 | No | Yes |
| TC-PRA-006 | REQ-GEN-002b | No | Yes |
| TC-FRM-001 | REQ-GEN-005 | No | No |
| TC-FRM-002 | REQ-GEN-006 | No | No |
| TC-FRM-003 | REQ-GEN-007 | No | No |
| TC-GEN-001 | REQ-GEN-004, REQ-OO-001 | No | Yes |

**Orphan test cases: 0**
**Total test cases traced: 83**

---

## 6. Coverage Summary

### 6.1 Requirement Coverage

| Category | Total Requirements | Covered | Gaps | Coverage % |
|---|---|---|---|---|
| Pre-Validation | 3 | 3 | 0 | 100% |
| Patient | 13 | 13 | 0 | 100% |
| Observation | 7 | 7 | 0 | 100% |
| AllergyIntolerance | 6 | 6 | 0 | 100% |
| MedicationRequest | 7 | 7 | 0 | 100% |
| DiagnosticReport | 5 | 5 | 0 | 100% |
| AuditEvent | 5 | 5 | 0 | 100% |
| OperationOutcome | 4 | 4 | 0 | 100% |
| Bundle | 6 | 6 | 0 | 100% |
| Practitioner | 3 | 3 | 0 | 100% |
| General | 9 | 9 | 0 | 100% |
| **Total** | **68** | **68** | **0** | **100%** |

*REQ-GEN-002 retired — not counted. REQ-GEN-002a and REQ-GEN-002b counted as 2 active requirements in the General category.*

*REQ-GEN-002a coverage is partial with documented rationale in Section 4.1. REQ-GEN-003 coverage is representative with documented rationale in Section 4.2. Both are counted as covered.*

### 6.2 IEC 62304 Class Coverage

| Class | Total Active Requirements | Covered | Gaps |
|---|---|---|---|
| Class C | 39 | 39 | 0 |
| Class B | 29 | 29 | 0 |
| **Total** | **68** | **68** | **0** |

All Class C and Class B requirements are covered. Partial and representative coverage dispositions are documented in Section 4.

### 6.3 Test Execution Status

| Status | Count |
|---|---|
| Pass | 68 |
| Fail | 0 |
| Skip | 0 |
| Partial | 0 |
| Pending | 0 |
| Retired | 1 |
| Total Requirements | 69 |

*Update this table after each test execution run.*

---

## 7. Execution Log

Record each test execution run here. Each run must be linked to a Git commit SHA per REQ-GEN-006.

| Run # | Date | Executed By | Commit SHA | Pipeline Run # | Total Pass | Total Fail | Total Skip | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | 2026-04-08 | Amir Choshov | 4458f7dd63e0fd904b1122db075bb26dbdecb740 | Run #3 | 74 | 0 | 0 | Full suite execution via GitHub Actions CI. 74 automated TCs PASS. 3 manual TCs (TC-FRM-001, TC-FRM-002, TC-FRM-003) verified as IQ/OQ checklist items. HL7 Validator scan: 9 files scanned, findings on observation and diagnostic-report attributed to HAPI sandbox data quality per VA-FHIR-001. |
| 2 | 2026-04-11 | Amir Choshov | af2bf2c5d540652079d27d632bb8c06f296d9aa8 | Local | 80 | 0 | 0 | Hardening pass — 6 new TCs added (TC-PAT-012 through TC-PAT-016, TC-BUN-008). 80 automated TCs PASS against HAPI FHIR sandbox. TP-FHIR-001 updated to v1.5 (83 total TCs). |

---

## 8. Open Items

| Item ID | Type | Description | Owner | Status | Resolution |
|---|---|---|---|---|---|
| TM-GAP-001 | Coverage Gap | REQ-GEN-004 had no dedicated test case | Amir Choshov | **Closed** | TC-GEN-001 added in TP-FHIR-001 v1.2 |
| TM-NOTE-001 | Coverage Note | REQ-GEN-002a partial coverage — meta.lastUpdated not asserted on DXR, AUD, BUN, PRA | Amir Choshov | Accepted | Rationale documented in Section 4.1 |
| TM-NOTE-002 | Coverage Note | REQ-GEN-003 representative coverage — malformed JSON tested for PAT and MED only | Amir Choshov | Accepted | Rationale documented in Section 4.2 |

---

## 9. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft — RS-FHIR-001 v1.1 (56 req), TP-FHIR-001 v1.1 (70 TCs), 1 identified gap (REQ-GEN-004) |
| 1.1 | 2026-03-30 | Amir Choshov | Updated to RS-FHIR-001 v1.2 (61 req) and TP-FHIR-001 v1.2 (77 TCs); retired REQ-GEN-002 row; added REQ-GEN-002a and REQ-GEN-002b rows with correct TC mappings; added REQ-OBS-007, REQ-ALG-006, REQ-MED-007, REQ-DXR-005 rows with dedicated 404 TC mappings; corrected REQ-OBS-001, REQ-ALG-001, REQ-MED-001, REQ-DXR-001 to remove incorrectly mapped 404 TCs; added TC-GEN-001 to REQ-OO-001 TC list; updated all backward trace entries for fixed and new TCs; added Section 4 documented coverage rationale for REQ-GEN-002a and REQ-GEN-003; closed TM-GAP-001; added TM-NOTE-001 and TM-NOTE-002; updated coverage summary to 61/61 (100%); updated Class C: 30→34, Class B: 26→27 |
| 1.2 | 2026-04-07 | Amir Choshov | Added Automated? column to Section 5 backward trace table; TC-OO-002, TC-OO-003, TC-OO-004, TC-GEN-001 marked Automated=Yes (standalone Karate scenarios now implemented); TC-FRM-001, TC-FRM-002, TC-FRM-003 marked Automated=No (manual IQ/OQ checklist items by design); all 74 Karate-automated TCs marked Yes |
| 1.3 | 2026-04-08 | Amir Choshov | Execution log populated — CI Run #3, 61/61 requirements PASS, 74/74 automated TCs PASS |
| 1.4 | 2026-04-09 | Amir Choshov | REQ-PRE-003 description updated — version assertion now accepts any valid R4 patch version per portability fix. |
| 1.5 | 2026-04-11 | Amir Choshov | 6 new TCs added from hardening pass (TC-PAT-012 through TC-PAT-016, TC-BUN-008). REQ-PAT-012 through REQ-PAT-016 and REQ-BUN-006 forward trace rows added. Backward trace updated with 6 new rows. Execution log run #2 added. TP source updated to v1.5 (83 TCs). Counts updated: 83 total, 80 automated. |
| 1.6 | 2026-04-12 | Amir Choshov | Updated RS citation to v1.4 (68 reqs); fixed column alignment in REQ-PAT-012–016 rows (ISO 14971 Risk field restored); added REQ-GEN-008 forward trace row; updated §6.1 and §6.2 coverage summary totals to 68; updated §6.3 execution status to 68 pass; updated TC source to TP v1.6 (83 TCs); updated footer closure statement |

---

## 10. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | Amir Choshov | 2026-04-08 |
| Reviewer | Amir Choshov (sole author — independent review not applicable for individual portfolio project) | Amir Choshov | 2026-04-08 |

---

*This Traceability Matrix reflects 100% coverage of all 68 active requirements in RS-FHIR-001 v1.4 with 83 test cases from TP-FHIR-001 v1.6. Two documented coverage rationale notes (Section 4.1, 4.2) are on record. Zero orphan test cases. All Class C requirements are fully covered. Validation exit criteria in TP-FHIR-001 Section 11.2 can be satisfied when all 83 test cases are executed and results recorded with Git commit SHAs.*
