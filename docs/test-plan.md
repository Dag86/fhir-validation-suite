# Test Plan

## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | TP-FHIR-001 |
| **Version** | 1.6 |
| **Status** | Approved |
| **Author** | Amir Choshov |
| **Date** | 2026-04-12 |
| **Project** | FHIR R4 API Validation Suite |
| **Governed By** | VP-FHIR-001 Validation Plan |
| **Requirements Source** | RS-FHIR-001 Requirements Specification |

---

## 1. Purpose

This Test Plan defines how testing will be executed against the FHIR R4 API Validation Suite requirements. It describes the test approach, coverage strategy, test case organization, execution sequence, pass/fail criteria, and defect handling process.

All test cases defined or referenced in this document must trace to a requirement in RS-FHIR-001. Any requirement without a corresponding test case is a coverage gap and must be documented in the Traceability Matrix (TM-FHIR-001).

---

## 2. Test Objectives

- Verify that FHIR R4 server responses conform to HL7 R4 specification requirements
- Validate that error responses conform to the FHIR OperationOutcome structure
- Assert that audit trail metadata satisfies 21 CFR Part 11 requirements
- Confirm that cross-resource references resolve correctly
- Produce timestamped, traceable test execution evidence linked to a specific Git commit SHA, suitable for inclusion in a regulated validation package

---

## 3. Test Approach

### 3.1 Risk-Based Coverage Strategy

Test coverage depth is proportional to IEC 62304 safety classification per RS-FHIR-001 Section 3.1.

| IEC 62304 Class | Resources | Coverage Required |
|---|---|---|
| Class C | Patient, Observation, AllergyIntolerance, MedicationRequest, DiagnosticReport, Bundle (transaction atomicity) | Positive path + full negative path + boundary conditions |
| Class B | Practitioner, AuditEvent, OperationOutcome, Bundle (searchset), CapabilityStatement | Positive path + critical negative path |

### 3.2 Test Types

| Test Type | Description | Applied To |
|---|---|---|
| **Positive Path** | Valid request returns correct, well-formed response | All resources |
| **Negative Path** | Invalid request returns FHIR-compliant error response | All resources |
| **Boundary Condition** | Edge cases at limits of valid input | Class C resources |
| **Schema Conformance** | Response validated against HL7 StructureDefinition via FHIR Validator CLI | All resources |
| **Audit Metadata** | `meta.lastUpdated` and `meta.versionId` assertions | All Class C resources |
| **Cross-Reference** | Resource references resolve to correct resource type | Observation, MedicationRequest, AllergyIntolerance, DiagnosticReport |

### 3.3 Test Execution Layers

Every resource goes through two execution layers:

**Layer 1 — Karate Assertions**
Clinical rules, required field checks, value set conformance, format validation, error structure assertions. Executed inline during `mvn test`.

**Layer 2 — HL7 Validator**
Full StructureDefinition conformance. Executed post-test against captured response files. Authoritative specification evidence.

Both layers must pass for a requirement to be considered satisfied.

### 3.4 Evidence Traceability

Every test execution must produce evidence linked to a specific Git commit SHA. This satisfies REQ-GEN-006 and 21 CFR Part 820.40. The traceability chain for every execution is:

```text
Git Commit SHA
      │
      ▼
GitHub Actions Pipeline Run Number
      │
      ▼
Archived Validation Artifact
      │
      ├── Karate HTML Report (Layer 1 results)
      └── HL7 Validator Output (Layer 2 results)
```

Test results that cannot be linked to a specific commit SHA are not valid regulated evidence and must not be used in a validation package.

---

## 4. Test Execution Sequence

The following sequence must be followed on every test run. Tests that depend on CapabilityStatement results must not run before the pre-check completes.

```text
Step 0: Pre-execution Git State Check
  └── Confirm working tree is clean — no uncommitted changes
  └── Record current commit SHA — this SHA will appear in CI pipeline log

Step 1: CapabilityStatement Pre-Check
  └── Query /metadata
  └── Parse supported resources
  └── Gate subsequent tests on supported capabilities

Step 2: Infrastructure Tests
  └── OperationOutcome structure validation
      (required by all negative path tests)

Step 3: Core Identity Resources
  └── Patient
  └── Practitioner

Step 4: Clinical Resources (Class C — highest risk first)
  └── AllergyIntolerance  ← highest clinical risk
  └── Observation
  └── MedicationRequest
  └── DiagnosticReport

Step 5: Compliance Resources
  └── AuditEvent

Step 6: Interoperability Resources
  └── Bundle (searchset)
  └── Bundle (transaction)

Step 7: Post-Execution
  └── HL7 Validator against all captured response files
  └── Report generation
  └── Evidence archiving with commit SHA
  └── git status check — confirm no generated artifacts leaked into working tree
```

**Rationale for Step 0:**
A test run executed against uncommitted changes produces evidence that cannot be fully reproduced — the code state cannot be retrieved by SHA. Step 0 ensures the commit SHA recorded in CI corresponds exactly to the source state that was tested.

---

## 5. Test Cases By Resource

### 5.1 CapabilityStatement

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-CAP-001 | REQ-PRE-001 | GET /metadata returns 200 | Positive | HTTP 200, resourceType = CapabilityStatement |
| TC-CAP-002 | REQ-PRE-002 | CapabilityStatement has valid structure | Schema | resourceType, fhirVersion, rest[] present |
| TC-CAP-003 | REQ-PRE-003 | FHIR version declared as valid R4 patch version | Positive | fhirVersion matches regex 4\.0\.[0-9]+ |

---

### 5.2 Patient

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-PAT-001 | REQ-PAT-001 | GET /Patient/{valid-id} returns 200 | Positive | HTTP 200, resourceType = Patient |
| TC-PAT-002 | REQ-PAT-002 | Patient name.family present | Positive | name[0].family is non-empty string |
| TC-PAT-003 | REQ-PAT-003 | Patient identifier has system and value | Positive | identifier[0].system and identifier[0].value present |
| TC-PAT-004 | REQ-PAT-004 | birthDate format is YYYY-MM-DD | Positive | birthDate matches regex `^\d{4}-\d{2}-\d{2}$` |
| TC-PAT-005 | REQ-PAT-005 | gender is valid value set member | Positive | gender is one of: male, female, other, unknown |
| TC-PAT-006 | REQ-PAT-006 | meta.lastUpdated present | Audit | meta.lastUpdated is non-null ISO 8601 timestamp |
| TC-PAT-007 | REQ-PAT-007 | Non-existent ID returns 404 + OperationOutcome | Negative | HTTP 404, resourceType = OperationOutcome |
| TC-PAT-008 | REQ-PAT-008 | Patient search returns searchset Bundle | Positive | resourceType = Bundle, type = searchset |
| TC-PAT-009 | REQ-GEN-001 | HL7 Validator confirms Patient conformance | Schema | Validator reports no errors |
| TC-PAT-010 | REQ-GEN-002b | meta.versionId present | Audit | meta.versionId is non-null string |
| TC-PAT-011 | REQ-GEN-003 | Malformed JSON returns 400 + OperationOutcome | Negative | HTTP 400, resourceType = OperationOutcome |
| TC-PAT-012 | REQ-PAT-012 | Conditional read returns 304 Not Modified when ETag matches | Positive | Status 304 returned when If-None-Match matches current ETag |
| TC-PAT-013 | REQ-PAT-013 | Search by gender returns searchset Bundle | Positive | gender=female returns Bundle type=searchset |
| TC-PAT-014 | REQ-PAT-014 | Search by birthdate returns searchset Bundle | Positive | birthdate=ge1980-01-01 returns Bundle type=searchset |
| TC-PAT-015 | REQ-PAT-015 | Search by identifier returns searchset Bundle | Positive | identifier={value} returns Bundle type=searchset |
| TC-PAT-016 | REQ-PAT-016 | Search by _id returns searchset Bundle | Positive | _id={patientId} returns Bundle with matching entry |

---

### 5.3 Observation

**Precondition for TC-OBS-004:** Before executing TC-OBS-004, run a search to locate an Observation with `valueQuantity` populated: `GET /Observation?value-quantity=gt0&_count=1`. If zero results are returned, mark TC-OBS-004 as Skip with rationale: "No Observation with valueQuantity found on target server — conditional assertion cannot be evaluated." This prevents a vacuous pass where the condition is never triggered.

**Precondition for TC-AUD block:** See Section 5.7.

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-OBS-001 | REQ-OBS-001 | GET /Observation/{valid-id} returns 200 | Positive | HTTP 200, resourceType = Observation |
| TC-OBS-002 | REQ-OBS-002 | status is valid ObservationStatus value | Positive | status in [registered, preliminary, final, amended, corrected, cancelled, entered-in-error, unknown] |
| TC-OBS-003 | REQ-OBS-003 | code.coding has system and code | Positive | code.coding[0].system and code.coding[0].code present |
| TC-OBS-004 | REQ-OBS-004 | valueQuantity has value and unit | Boundary | **Precondition:** search for Observation with valueQuantity populated (see above). If valueQuantity present: value is numeric, unit is non-empty string |
| TC-OBS-005 | REQ-OBS-005 | subject references Patient | Cross-ref | subject.reference starts with "Patient/" |
| TC-OBS-006 | REQ-OBS-006 | meta.lastUpdated present | Audit | meta.lastUpdated is non-null ISO 8601 timestamp |
| TC-OBS-007 | REQ-OBS-007 | Non-existent ID returns 404 + OperationOutcome | Negative | HTTP 404, resourceType = OperationOutcome |
| TC-OBS-008 | REQ-GEN-001 | HL7 Validator confirms Observation conformance | Schema | Validator reports no errors |
| TC-OBS-009 | REQ-GEN-002b | meta.versionId present | Audit | meta.versionId is non-null string |

---

### 5.4 AllergyIntolerance

**Precondition for TC-ALG-005:** Before executing TC-ALG-005, run a search to locate an AllergyIntolerance with `reaction` populated: `GET /AllergyIntolerance?_has:reaction=exists&_count=1`. If zero results, mark TC-ALG-005 as Skip with rationale: "No AllergyIntolerance with reaction found on target server — conditional assertion cannot be evaluated." This prevents a vacuous pass.

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-ALG-001 | REQ-ALG-001 | GET /AllergyIntolerance/{valid-id} returns 200 | Positive | HTTP 200, resourceType = AllergyIntolerance |
| TC-ALG-002 | REQ-ALG-002 | clinicalStatus is valid value set member | Positive | clinicalStatus.coding[0].code in [active, inactive, resolved] |
| TC-ALG-003 | REQ-ALG-003 | verificationStatus present | Positive | verificationStatus is non-null |
| TC-ALG-004 | REQ-ALG-004 | patient reference present | Cross-ref | patient.reference starts with "Patient/" |
| TC-ALG-005 | REQ-ALG-005 | reaction manifestation has coding | Boundary | **Precondition:** search for AllergyIntolerance with reaction populated (see above). If reaction present: reaction[0].manifestation[0].coding[0] is non-null |
| TC-ALG-006 | REQ-ALG-006 | Non-existent ID returns 404 + OperationOutcome | Negative | HTTP 404, resourceType = OperationOutcome |
| TC-ALG-007 | REQ-GEN-001 | HL7 Validator confirms AllergyIntolerance conformance | Schema | Validator reports no errors |
| TC-ALG-008 | REQ-GEN-002a, REQ-GEN-002b | meta.lastUpdated and meta.versionId both present | Audit | meta.lastUpdated is non-null ISO 8601 timestamp AND meta.versionId is non-null string |

---

### 5.5 MedicationRequest

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-MED-001 | REQ-MED-001 | GET /MedicationRequest/{valid-id} returns 200 | Positive | HTTP 200, resourceType = MedicationRequest |
| TC-MED-002 | REQ-MED-002 | status is valid MedicationRequestStatus value | Positive | status in [active, on-hold, cancelled, completed, entered-in-error, stopped, draft, unknown] |
| TC-MED-003 | REQ-MED-003 | intent is valid value set member | Positive | intent in [proposal, plan, order, original-order, reflex-order, filler-order, instance-order, option] |
| TC-MED-004 | REQ-MED-004 | medication[x] present | Positive | medicationCodeableConcept or medicationReference present |
| TC-MED-005 | REQ-MED-005 | subject references Patient | Cross-ref | subject.reference starts with "Patient/" |
| TC-MED-006 | REQ-MED-006 | meta.lastUpdated present | Audit | meta.lastUpdated is non-null ISO 8601 timestamp |
| TC-MED-007 | REQ-MED-007 | Non-existent ID returns 404 + OperationOutcome | Negative | HTTP 404, resourceType = OperationOutcome |
| TC-MED-008 | REQ-GEN-001 | HL7 Validator confirms MedicationRequest conformance | Schema | Validator reports no errors |
| TC-MED-009 | REQ-GEN-003 | Malformed JSON body returns 400 + OperationOutcome | Negative | HTTP 400, resourceType = OperationOutcome |
| TC-MED-010 | REQ-GEN-002b | meta.versionId present | Audit | meta.versionId is non-null string |

---

### 5.6 DiagnosticReport

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-DXR-001 | REQ-DXR-001 | GET /DiagnosticReport/{valid-id} returns 200 | Positive | HTTP 200, resourceType = DiagnosticReport |
| TC-DXR-002 | REQ-DXR-002 | status is valid DiagnosticReportStatus value | Positive | status in [registered, partial, preliminary, final, amended, corrected, appended, cancelled, entered-in-error, unknown] — note: `partial` and `appended` are specific to DiagnosticReport and not present in ObservationStatus |
| TC-DXR-003 | REQ-DXR-003 | code element present | Positive | code is non-null |
| TC-DXR-004 | REQ-DXR-004 | subject reference present | Cross-ref | subject.reference is non-null |
| TC-DXR-005 | REQ-DXR-005 | Non-existent ID returns 404 + OperationOutcome | Negative | HTTP 404, resourceType = OperationOutcome |
| TC-DXR-006 | REQ-GEN-001 | HL7 Validator confirms DiagnosticReport conformance | Schema | Validator reports no errors |
| TC-DXR-007 | REQ-GEN-002b | meta.versionId present | Audit | meta.versionId is non-null string |

---

### 5.7 AuditEvent

**Precondition for all AuditEvent tests:** The HAPI sandbox generates AuditEvents internally but valid IDs must be discovered before TC-AUD-001 can execute. Before running any AuditEvent test, execute the following search to obtain a valid ID: `GET /AuditEvent?date=gt{today}&_count=1`. Extract the `id` from the first result entry and use it as `{valid-id}` in TC-AUD-001. If the search returns zero results, mark all TC-AUD tests as Skip with rationale: "No AuditEvent records found on target server within the search window — AuditEvent tests cannot execute." Do not use a hardcoded ID — a hardcoded ID that does not exist on the server would produce a 404 failure that misrepresents the server's actual AuditEvent conformance.

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-AUD-001 | REQ-AUD-001 | GET /AuditEvent/{valid-id} returns 200 | Positive | HTTP 200, resourceType = AuditEvent — **precondition:** ID obtained via search above |
| TC-AUD-002 | REQ-AUD-002 | type element present | Positive | type is non-null |
| TC-AUD-003 | REQ-AUD-003 | recorded timestamp present and ISO 8601 | Audit | recorded matches ISO 8601 datetime format |
| TC-AUD-004 | REQ-AUD-004 | agent array present with at least one entry | Positive | agent is array, length >= 1 |
| TC-AUD-005 | REQ-AUD-005 | outcome field present | Positive | outcome is non-null |
| TC-AUD-006 | REQ-GEN-001 | HL7 Validator confirms AuditEvent conformance | Schema | Validator reports no errors |
| TC-AUD-007 | REQ-GEN-002b | meta.versionId present | Audit | meta.versionId is non-null string |

---

### 5.8 OperationOutcome

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-OO-001 | REQ-OO-001 | Any error response returns OperationOutcome | Negative | resourceType = OperationOutcome on 4xx/5xx |
| TC-OO-002 | REQ-OO-002 | issue array present and non-empty | Positive | issue is array, length >= 1 — Implemented as standalone Scenario in common/operation-outcome.feature |
| TC-OO-003 | REQ-OO-003 | issue.severity is valid value set member | Positive | severity in [fatal, error, warning, information] — Implemented as standalone Scenario in common/operation-outcome.feature |
| TC-OO-004 | REQ-OO-004 | issue.code is present | Positive | issue[0].code is non-null — Implemented as standalone Scenario in common/operation-outcome.feature |
| TC-OO-005 | REQ-GEN-001 | HL7 Validator confirms OperationOutcome conformance | Schema | Validator reports no errors |

---

### 5.9 Bundle

**TC-BUN-005 Atomicity Verification Design:** TC-BUN-005 tests transaction atomicity — not just the HTTP error response but the actual non-persistence of resources. The test body must include at least one valid resource with a client-assigned ID alongside one intentionally invalid resource. After receiving the 4xx response, the test must execute follow-up GET requests for each resource in the rejected transaction and assert HTTP 404 for each. This is the only way to prove the atomicity guarantee — that no partial write occurred. Without the follow-up GETs, the test only proves the error code, not the Class C requirement itself.

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-BUN-001 | REQ-BUN-001 | Patient search returns searchset Bundle | Positive | resourceType = Bundle, type = searchset |
| TC-BUN-002 | REQ-BUN-002 | searchset Bundle has total field | Positive | total is non-null integer |
| TC-BUN-003 | REQ-BUN-003 | Each Bundle entry has resource and fullUrl | Positive | entry[*].resource and entry[*].fullUrl present |
| TC-BUN-004 | REQ-BUN-004 | Valid transaction returns transaction-response Bundle | Positive | resourceType = Bundle, type = transaction-response |
| TC-BUN-005 | REQ-BUN-005 | Transaction with invalid entry fails atomically | Negative | Step 1: POST transaction with valid Patient (client-assigned id=atomicity-test-pat) + invalid resource → HTTP 4xx, resourceType = OperationOutcome. Step 2: GET /Patient/atomicity-test-pat → HTTP 404, confirming no partial write occurred |
| TC-BUN-006 | REQ-GEN-001 | HL7 Validator confirms Bundle conformance | Schema | Validator reports no errors |
| TC-BUN-007 | REQ-GEN-002b | meta.versionId present on Bundle response | Audit | meta.versionId is non-null string |
| TC-BUN-008 | REQ-BUN-006 | searchset Bundle contains self link relation | Positive | response.link contains entry with relation=self |

---

### 5.10 Practitioner

**Precondition for TC-PRA-003:** Before executing TC-PRA-003, run a search to locate a Practitioner with `identifier` populated: `GET /Practitioner?identifier=&_count=1`. If zero results, mark TC-PRA-003 as Skip with rationale: "No Practitioner with identifier found on target server — conditional assertion cannot be evaluated." This prevents a vacuous pass.

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-PRA-001 | REQ-PRA-001 | GET /Practitioner/{valid-id} returns 200 | Positive | HTTP 200, resourceType = Practitioner |
| TC-PRA-002 | REQ-PRA-002 | name element present | Positive | name is array, length >= 1 |
| TC-PRA-003 | REQ-PRA-003 | identifier has system and value if present | Boundary | **Precondition:** search for Practitioner with identifier populated (see above). If identifier present: identifier[0].system and identifier[0].value are non-null |
| TC-PRA-004 | REQ-PRA-001 | Non-existent ID returns 404 + OperationOutcome | Negative | HTTP 404, resourceType = OperationOutcome |
| TC-PRA-005 | REQ-GEN-001 | HL7 Validator confirms Practitioner conformance | Schema | Validator reports no errors |
| TC-PRA-006 | REQ-GEN-002b | meta.versionId present | Audit | meta.versionId is non-null string |

---

### 5.11 Framework Requirements

| TC ID | Requirement | Test Description | Type | Expected Result |
|---|---|---|---|---|
| TC-FRM-001 | REQ-GEN-005 | Suite executes against configurable base URL | Framework | `mvn test -DbaseUrl={url}` targets correct server without code changes — Non-automated. Verified as manual IQ/OQ checklist item. No feature file counterpart by design. |
| TC-FRM-002 | REQ-GEN-006 | Test execution report linked to Git commit SHA | Framework | Pipeline artifact metadata contains commit SHA matching triggering commit — Non-automated. Verified as manual IQ/OQ checklist item. No feature file counterpart by design. |
| TC-FRM-003 | REQ-GEN-007 | Git branch protection active on main | Framework | Direct push to `main` is rejected — verified per OQ-GIT-004 — Non-automated. Verified as manual IQ/OQ checklist item. No feature file counterpart by design. |
| TC-GEN-001 | REQ-GEN-004 | Unsupported resource type returns 404 + OperationOutcome | Negative | GET /FooBarResource/1 → HTTP 404, resourceType = OperationOutcome (not HTML error page) — Implemented as standalone Scenario in common/general.feature. |

---

## 6. Test Case Summary

| Resource | Total TCs | Positive | Negative | Boundary | Schema | Audit | Cross-ref |
|---|---|---|---|---|---|---|---|
| CapabilityStatement | 3 | 2 | 0 | 0 | 1 | 0 | 0 |
| Patient | 16 | 11 | 2 | 0 | 1 | 2 | 0 |
| Observation | 9 | 4 | 1 | 1 | 1 | 2 | 1 |
| AllergyIntolerance | 8 | 3 | 1 | 1 | 1 | 1 | 1 |
| MedicationRequest | 10 | 4 | 2 | 0 | 1 | 2 | 1 |
| DiagnosticReport | 7 | 3 | 1 | 0 | 1 | 1 | 1 |
| AuditEvent | 7 | 4 | 0 | 0 | 1 | 2 | 0 |
| OperationOutcome | 5 | 3 | 1 | 0 | 1 | 0 | 0 |
| Bundle | 8 | 4 | 1 | 0 | 1 | 1 | 0 |
| Practitioner | 6 | 2 | 1 | 1 | 1 | 1 | 0 |
| Framework | 4 | 0 | 1 | 0 | 0 | 0 | 0 |
| **Total** | **83** | **40** | **11** | **3** | **10** | **12** | **4** |

*Audit column increase from 6 → 12 reflects addition of meta.versionId assertions (TC-OBS-009, TC-MED-010, TC-DXR-007, TC-AUD-007, TC-BUN-007, TC-PRA-006) — closing the REQ-GEN-002b coverage gap identified in gap analysis.*

---

## 7. Pass/Fail Criteria

### 7.1 Individual Test Case

| Result | Criteria |
|---|---|
| **Pass** | All Karate assertions evaluate true AND HL7 Validator reports no errors for the captured response |
| **Fail** | Any Karate assertion evaluates false OR HL7 Validator reports one or more errors |
| **Skip** | Resource not declared in server CapabilityStatement — not a finding, documented as unsupported |
| **Blocked** | Test cannot execute due to environment issue — documented separately, not counted as fail |

### 7.2 Resource-Level

| Result | Criteria |
|---|---|
| **Pass** | All test cases for the resource pass |
| **Partial** | Some test cases pass, some fail — each failure documented in Gap Analysis |
| **Fail** | All or majority of test cases fail — indicates fundamental conformance gap |

### 7.3 Suite-Level

| Result | Criteria |
|---|---|
| **Pass** | All Class C test cases pass. All Class B test cases pass. All framework test cases pass. Zero open Critical deviations. Evidence linked to a valid Git commit SHA. |
| **Conditional Pass** | All Class C test cases pass. Minor Class B deviations documented with justification. |
| **Fail** | Any Class C test case fails without documented acceptable deviation. Framework test cases TC-FRM-002 or TC-FRM-003 fail. |

---

## 8. Defect Classification and Handling

| Severity | Definition | Example | Action |
|---|---|---|---|
| **Critical** | Class C requirement not met — patient safety risk | AllergyIntolerance returns no clinicalStatus | Document in Gap Analysis, flag as blocking finding |
| **Major** | Class B requirement not met — compliance gap | AuditEvent missing recorded timestamp | Document in Gap Analysis |
| **Minor** | Spec deviation with no direct clinical risk | Bundle total count off by one on empty result | Document in Gap Analysis |
| **Observation** | Non-spec issue worth noting | Inconsistent response time | Note in test execution report |

All findings regardless of severity are documented in GA-FHIR-001 Gap Analysis. Findings are attributed to the HAPI sandbox as the execution target — not treated as defects in the framework itself.

---

## 9. Test Data Management

| Principle | Implementation |
|---|---|
| No PHI | All tests use HAPI public sandbox only — no real patient data |
| Dynamic resource retrieval | Resource IDs retrieved via search where possible — not hardcoded |
| Negative path data | Synthetic malformed payloads constructed inline in feature files |
| Response capture | All responses saved to `responses/` for HL7 Validator post-processing |
| Data isolation | Each test run is independent — no state shared between feature files |
| Generated artifacts excluded from Git | `responses/` and `target/` covered by `.gitignore` — not committed |

---

## 10. Execution Environment Requirements

| Requirement | Specification |
|---|---|
| Git | 2.x — branch protection on `main` active |
| Java | 17 LTS (Temurin) — verified in IQ |
| Maven | 3.9.x — verified in IQ |
| Karate | 1.5.1 — verified in IQ |
| HL7 Validator | Latest stable — verified in IQ |
| Network | HTTPS access to `hapi.fhir.org` required |
| CI | GitHub Actions — Ubuntu 22.04 runner |
| Execution time | Full suite expected to complete within 10 minutes |

---

## 11. Entry and Exit Criteria

### 11.1 Entry Criteria — Testing May Begin When

- [ ] TQ-FHIR-IQ-001 completed and passed — including IQ-GIT all steps
- [ ] TQ-FHIR-OQ-001 completed and passed — including OQ-GIT all steps
- [ ] TQ-FHIR-PQ-001 completed and passed — including PQ-005
- [ ] All 68 requirements in RS-FHIR-001 v1.4 have at least one test case in this plan
- [ ] Traceability Matrix (TM-FHIR-001) populated
- [ ] Git repository on `main` branch with clean working tree
- [ ] Branch protection confirmed active on `main`
- [ ] GitHub Actions pipeline executing successfully
- [ ] HAPI FHIR sandbox confirmed accessible

### 11.2 Exit Criteria — Testing Is Complete When

- [ ] All 83 test cases executed
- [ ] All Class C test cases passed or deviations documented
- [ ] All Class B test cases passed or deviations documented
- [ ] TC-FRM-001, TC-FRM-002, TC-FRM-003, and TC-GEN-001 all passed
- [ ] HL7 Validator run against all captured responses
- [ ] Traceability Matrix shows 100% requirement coverage for all 68 active requirements in RS-FHIR-001 v1.4
- [ ] Gap Analysis (GA-FHIR-001) complete
- [ ] Test execution reports archived in GitHub Actions with timestamps and commit SHAs
- [ ] Git commit SHA of final execution run recorded in validation package

### 11.3 Evidence Archiving Requirement

Before validation is closed, the following must be recorded:

| Field | Value |
|---|---|
| Final execution commit SHA | |
| GitHub Actions run number | |
| Artifact name | |
| Artifact download confirmed | Yes / No |
| Date validation closed | |

This record links the completed validation package to the exact source state under which all test evidence was generated.

---

## 12. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Section 3.4 evidence traceability chain; added Step 0 pre-execution Git state check and post-execution git status check to execution sequence; added Section 5.11 framework test cases TC-FRM-001, TC-FRM-002, TC-FRM-003; updated test case summary totals to 70; updated suite-level pass criteria to include framework TCs and commit SHA; updated entry criteria to include Git and IQ/OQ/PQ Git steps; updated exit criteria to include TC-FRM coverage and commit SHA recording; added evidence archiving requirement table; added generated artifacts excluded from Git to test data management; added Git to environment requirements |
| 1.2 | 2026-03-30 | Amir Choshov | Fixed TC-OBS-007, TC-ALG-006, TC-MED-007, TC-DXR-005 requirement mappings to correct dedicated 404 requirements; fixed TC-PAT-010 and TC-ALG-008 mappings to REQ-GEN-002b and REQ-GEN-002a/002b; fixed TC-DXR-002 expected result to enumerate full DiagnosticReport status value set including partial and appended; added search precondition blocks for TC-OBS-004, TC-ALG-005, TC-PRA-003 to prevent vacuous passes; added AuditEvent search precondition block; expanded TC-BUN-005 to include follow-up GET atomicity verification steps; added TC-OBS-009, TC-MED-010, TC-DXR-007, TC-AUD-007, TC-BUN-007, TC-PRA-006 for REQ-GEN-002b meta.versionId coverage; added TC-GEN-001 for REQ-GEN-004; updated summary totals 70 → 77; updated entry/exit criteria counts 56 → 61, 70 → 77 |
| 1.3 | 2026-04-07 | Amir Choshov | Added implementation notes to TC-OO-002, TC-OO-003, TC-OO-004 (standalone Scenarios in common/operation-outcome.feature); added implementation note to TC-GEN-001 (standalone Scenario in common/general.feature); added non-automated notes to TC-FRM-001, TC-FRM-002, TC-FRM-003 (manual IQ/OQ checklist items, no feature file counterpart by design) |
| 1.4 | 2026-04-09 | Amir Choshov | TC-CAP-003 expected value updated — fhirVersion assertion accepts any valid R4 patch version (4.0.x) not just 4.0.1. Reflects portability fix for multi-server conformance testing. |
| 1.5 | 2026-04-11 | Amir Choshov | Added TC-PAT-012 through TC-PAT-016 and TC-BUN-008 from hardening pass. Total TC count updated from 77 to 83. |
| 1.6 | 2026-04-12 | Amir Choshov | Status Draft → Approved; updated Patient TC count 11→16, Bundle 7→8; updated entry/exit criteria to 68 reqs / 83 TCs; updated RS citation to v1.4 |

---

## 13. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | | |
| Reviewer | | | |

---

*This Test Plan governs all test execution activities for the FHIR R4 API Validation Suite. All 83 test cases defined in this document must be executed and recorded before validation is considered complete. The Traceability Matrix must confirm 100% coverage of all 68 RS-FHIR-001 v1.4 requirements before exit criteria are satisfied.*
