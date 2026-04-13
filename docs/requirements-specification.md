# Requirements Specification
## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | RS-FHIR-001 |
| **Version** | 1.4 |
| **Status** | Approved |
| **Author** | Amir Choshov |
| **Date** | 2026-04-12 |
| **Project** | FHIR R4 API Validation Suite |

---

## 1. Purpose

This document defines the functional and compliance requirements for the FHIR R4 API Validation Suite. It establishes the testable requirements that govern validation coverage, derived from the HL7 FHIR R4 specification and applicable regulatory standards.

All test cases produced in this project must trace back to a requirement defined in this document. Requirements without corresponding test cases constitute coverage gaps and must be documented in the Traceability Matrix.

---

## 2. Scope

### 2.1 In Scope

- Validation of FHIR R4 REST API endpoints against the HL7 R4 specification
- Resources: `Patient`, `Practitioner`, `Observation`, `AllergyIntolerance`, `DiagnosticReport`, `MedicationRequest`, `AuditEvent`, `OperationOutcome`, `Bundle`, `CapabilityStatement`
- Positive path, negative path, and boundary condition testing
- Schema conformance validation using the official HL7 FHIR Validator CLI
- Audit trail and metadata assertions relevant to 21 CFR Part 11
- CI/CD pipeline execution via GitHub Actions
- Git version control for source code, documentation, and evidence traceability
- Response time validation (server latency assertions per FHIR R4 performance expectations)
- HTTP response header validation (`Content-Type`, `ETag` per FHIR R4 Section 3.1.0.2)
- Conditional read behavior (`If-None-Match` / HTTP 304 Not Modified)
- Patient search parameter coverage (`gender`, `birthdate`, `identifier`, `_id`)
- Pagination link structure validation (Bundle `self` link per FHIR search framework)
- Multi-server conformance testing (HAPI FHIR as primary target; SMART Health IT as secondary verification server)

### 2.2 Out of Scope

- FHIR R5 resources
- SMART on FHIR OAuth authentication flows (Phase 2)
- FHIR Subscription resources
- US Core profile-specific constraints (Phase 2)
- Performance and load testing
- UI layer validation

### 2.3 Target System

| Field | Value |
|---|---|
| **Primary System** | HAPI FHIR Public Sandbox |
| **FHIR Version** | R4 (4.0.x) |
| **Primary Base URL** | https://hapi.fhir.org/baseR4 |
| **Authentication** | None (public sandbox) |
| **Secondary System** | SMART Health IT Sandbox |
| **Secondary Base URL** | https://launch.smarthealthit.org/v/r4/fhir |
| **Secondary Purpose** | Multi-server conformance verification — 73/80 TCs pass; 7 conformance findings identified |

---

## 3. Regulatory Standards

The following standards govern the requirements defined in this document:

| Standard | Application |
|---|---|
| **HL7 FHIR R4** | Primary specification for all resource structure requirements |
| **IEC 62304** | Software safety classification for risk-based test prioritization |
| **ISO 14971** | Risk management — each requirement maps to a clinical risk |
| **21 CFR Part 11** | Electronic records and audit trail requirements |
| **21 CFR Part 820** | Quality System Regulation — design verification and validation |
| **21 CFR Part 820.40** | Document controls — version history, change traceability, retrievability |
| **ONC 21st Century Cures Act** | Federal mandate for FHIR R4 interoperability compliance |

### 3.1 IEC 62304 Safety Classifications Used In This Document

| Class | Definition | Application |
|---|---|---|
| **Class A** | No injury possible | Not applicable to this suite |
| **Class B** | Non-serious injury possible | Infrastructure, error handling resources |
| **Class C** | Serious injury or death possible | Clinical data resources — Patient, Observation, Medication, Allergy |

---

## 4. Requirements

### 4.1 Pre-Validation Requirements

---

**REQ-PRE-001**
The validation suite SHALL query the server CapabilityStatement at `GET /metadata` before executing any resource tests.

- **Source:** HL7 FHIR R4 Section 3.1.0 — Capability Statement
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Prevents false failures caused by testing unsupported capabilities
- **Rationale:** A server may not implement all resources. Pre-checking prevents misleading test results.

---

**REQ-PRE-002**
The CapabilityStatement response SHALL have HTTP status 200 and `resourceType` of `CapabilityStatement`.

- **Source:** HL7 FHIR R4 Section 3.1.0
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Server non-compliance with base FHIR spec

---

**REQ-PRE-003**
The CapabilityStatement SHALL declare a valid FHIR R4 version (`4.0.x` patch series).

- **Source:** HL7 FHIR R4 CapabilityStatement.fhirVersion
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Version mismatch causing incorrect data interpretation

---

### 4.2 Patient Resource Requirements

> **Clinical Risk Context:** Patient identity errors are classified as Never Events in healthcare. A wrong-patient error can result in the wrong treatment, wrong medication, or wrong procedure being administered. All Patient requirements are IEC 62304 Class C.

---

**REQ-PAT-001**
A valid `GET /Patient/{id}` request SHALL return HTTP status 200 and `resourceType` of `Patient`.

- **Source:** HL7 FHIR R4 Patient Resource
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** System failure preventing patient data retrieval

---

**REQ-PAT-002**
The Patient resource SHALL contain at least one `name` element with a `family` value.

- **Source:** HL7 FHIR R4 Patient.name — required for patient identification
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Wrong patient selection due to missing identity data

---

**REQ-PAT-003**
The Patient resource SHALL contain at least one `identifier` element with both `system` and `value` fields.

- **Source:** HL7 FHIR R4 Patient.identifier
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Duplicate patient records, wrong-patient events

---

**REQ-PAT-004**
If `birthDate` is present, it SHALL conform to the format `YYYY-MM-DD`.

- **Source:** HL7 FHIR R4 date datatype definition
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Age-dependent dosing errors from malformed date data

---

**REQ-PAT-005**
If `gender` is present, its value SHALL be one of: `male`, `female`, `other`, `unknown`.

- **Source:** HL7 FHIR R4 AdministrativeGender value set
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Gender-specific clinical decision errors

---

**REQ-PAT-006**
The Patient resource SHALL contain a `meta.lastUpdated` timestamp.

- **Source:** HL7 FHIR R4 Resource.meta — 21 CFR Part 11 audit requirement
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Inability to reconstruct data change history for audit

---

**REQ-PAT-007**
A `GET /Patient/{id}` request with a non-existent ID SHALL return HTTP status 404 and an `OperationOutcome` resource.

- **Source:** HL7 FHIR R4 Section 3.1.0.6 — HTTP Status Codes
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Silent failure masking missing patient records

---

**REQ-PAT-008**
A `GET /Patient?name={value}` search SHALL return a `Bundle` resource of type `searchset`.

- **Source:** HL7 FHIR R4 Search Framework
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Incorrect search results leading to wrong patient selection

---

**REQ-PAT-012**
The server SHALL return HTTP 304 Not Modified when a conditional read request includes an `If-None-Match` header matching the current resource ETag.

- **Source:** HL7 FHIR R4 Section 3.1.0.2 — Conditional Read
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Identity integrity — stale cache serving outdated patient record could lead to wrong treatment decision
- **Test reference:** TC-PAT-012

---

**REQ-PAT-013**
The server SHALL support search by `gender` parameter and return a `searchset` Bundle.

- **Source:** HL7 FHIR R4 Patient search parameters
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Identity — inability to filter by demographic could return wrong patient record
- **Test reference:** TC-PAT-013

---

**REQ-PAT-014**
The server SHALL support search by `birthdate` parameter and return a `searchset` Bundle.

- **Source:** HL7 FHIR R4 Patient search parameters
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Identity — incorrect birthdate search could return wrong patient record
- **Test reference:** TC-PAT-014

---

**REQ-PAT-015**
The server SHALL support search by `identifier` parameter and return a `searchset` Bundle.

- **Source:** HL7 FHIR R4 Patient search parameters
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Identity — identifier search is the primary mechanism for unique patient lookup in clinical systems
- **Test reference:** TC-PAT-015

---

**REQ-PAT-016**
The server SHALL support search by `_id` parameter and return a `searchset` Bundle containing the matching resource.

- **Source:** HL7 FHIR R4 Patient search parameters
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Identity — `_id` search must return exactly the requested patient, not a similar one
- **Test reference:** TC-PAT-016

---

### 4.3 Observation Resource Requirements

> **Clinical Risk Context:** Observations represent lab results, vital signs, and clinical findings. An incorrect Observation value — wrong unit, wrong reference range, missing status — can directly drive clinical decisions including medication dosing and surgical intervention.

---

**REQ-OBS-001**
A valid `GET /Observation/{id}` request SHALL return HTTP status 200 and `resourceType` of `Observation`.

- **Source:** HL7 FHIR R4 Observation Resource
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** System failure preventing lab result retrieval

---

**REQ-OBS-002**
The Observation resource SHALL contain a `status` field with a value from the ObservationStatus value set: `registered`, `preliminary`, `final`, `amended`, `corrected`, `cancelled`, `entered-in-error`, `unknown`.

- **Source:** HL7 FHIR R4 Observation.status — required field
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Clinician acting on a preliminary result as if it were final

---

**REQ-OBS-003**
The Observation resource SHALL contain a `code` element with at least one `coding` entry containing a `system` and `code`.

- **Source:** HL7 FHIR R4 Observation.code — required field
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Unidentifiable observation type leading to misinterpretation

---

**REQ-OBS-004**
If `valueQuantity` is present, it SHALL contain both `value` (numeric) and `unit` fields.

- **Source:** HL7 FHIR R4 Quantity datatype
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Unit-of-measure errors in dosing calculations (e.g., mg vs mcg)

---

**REQ-OBS-005**
The Observation resource SHALL contain a `subject` reference linking to a Patient resource.

- **Source:** HL7 FHIR R4 Observation.subject
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Observation attributed to wrong patient

---

**REQ-OBS-006**
The Observation resource SHALL contain a `meta.lastUpdated` timestamp.

- **Source:** 21 CFR Part 11 — audit trail requirement
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Inability to determine when a result was recorded or modified

---

**REQ-OBS-007**
A `GET /Observation/{id}` request with a non-existent ID SHALL return HTTP status 404 and an `OperationOutcome` resource.

- **Source:** HL7 FHIR R4 Section 3.1.0.6 — HTTP Status Codes
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Silent failure masking missing lab results — clinician receives no indication that data was not found
- **Note:** Mirrors REQ-PAT-007 — every Class C resource requires a dedicated negative path requirement. A server returning a non-FHIR 404 HTML page instead of an OperationOutcome would break FHIR client error handling for clinical systems.

---

### 4.4 AllergyIntolerance Resource Requirements

> **Clinical Risk Context:** AllergyIntolerance records are among the highest clinical risk data in healthcare. A missing or malformed allergy record can result in administration of a contraindicated substance, potentially causing anaphylaxis or death.

---

**REQ-ALG-001**
A valid `GET /AllergyIntolerance/{id}` request SHALL return HTTP status 200 and `resourceType` of `AllergyIntolerance`.

- **Source:** HL7 FHIR R4 AllergyIntolerance Resource
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** System failure preventing allergy data retrieval

---

**REQ-ALG-002**
The AllergyIntolerance resource SHALL contain a `clinicalStatus` element with a valid code from the AllergyIntoleranceClinicalStatusCodes value set: `active`, `inactive`, `resolved`.

- **Source:** HL7 FHIR R4 AllergyIntolerance.clinicalStatus — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Inactive allergy treated as active or vice versa

---

**REQ-ALG-003**
The AllergyIntolerance resource SHALL contain a `verificationStatus` element.

- **Source:** HL7 FHIR R4 AllergyIntolerance.verificationStatus — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Unverified allergy driving clinical decision

---

**REQ-ALG-004**
The AllergyIntolerance resource SHALL contain a `patient` reference linking to a Patient resource.

- **Source:** HL7 FHIR R4 AllergyIntolerance.patient — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Allergy attributed to wrong patient

---

**REQ-ALG-005**
If `reaction` is present, each reaction SHALL contain at least one `manifestation` with a `coding` entry.

- **Source:** HL7 FHIR R4 AllergyIntolerance.reaction.manifestation
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Reaction severity unknown to treating clinician

---

**REQ-ALG-006**
A `GET /AllergyIntolerance/{id}` request with a non-existent ID SHALL return HTTP status 404 and an `OperationOutcome` resource.

- **Source:** HL7 FHIR R4 Section 3.1.0.6 — HTTP Status Codes
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Silent failure masking missing allergy records — a system that silently fails to retrieve an allergy record may leave a clinician unaware of a contraindication, creating a direct anaphylaxis risk pathway.

---

### 4.5 MedicationRequest Resource Requirements

> **Clinical Risk Context:** MedicationRequest represents a prescription or medication order. Errors in medication name, dose, route, or patient reference are direct patient harm pathways.

---

**REQ-MED-001**
A valid `GET /MedicationRequest/{id}` request SHALL return HTTP status 200 and `resourceType` of `MedicationRequest`.

- **Source:** HL7 FHIR R4 MedicationRequest Resource
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** System failure preventing medication order retrieval

---

**REQ-MED-002**
The MedicationRequest resource SHALL contain a `status` field with a value from the MedicationRequestStatus value set: `active`, `on-hold`, `cancelled`, `completed`, `entered-in-error`, `stopped`, `draft`, `unknown`.

- **Source:** HL7 FHIR R4 MedicationRequest.status — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Cancelled order administered due to incorrect status

---

**REQ-MED-003**
The MedicationRequest resource SHALL contain an `intent` field with a valid value: `proposal`, `plan`, `order`, `original-order`, `reflex-order`, `filler-order`, `instance-order`, `option`.

- **Source:** HL7 FHIR R4 MedicationRequest.intent — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Proposal treated as active order

---

**REQ-MED-004**
The MedicationRequest resource SHALL contain either `medicationCodeableConcept` or `medicationReference`.

- **Source:** HL7 FHIR R4 MedicationRequest.medication[x] — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Unidentified medication administered

---

**REQ-MED-005**
The MedicationRequest resource SHALL contain a `subject` reference linking to a Patient resource.

- **Source:** HL7 FHIR R4 MedicationRequest.subject — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Medication administered to wrong patient

---

**REQ-MED-006**
The MedicationRequest resource SHALL contain a `meta.lastUpdated` timestamp.

- **Source:** 21 CFR Part 11 — audit trail requirement
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Unable to determine when order was placed or modified

---

**REQ-MED-007**
A `GET /MedicationRequest/{id}` request with a non-existent ID SHALL return HTTP status 404 and an `OperationOutcome` resource.

- **Source:** HL7 FHIR R4 Section 3.1.0.6 — HTTP Status Codes
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Silent failure masking missing medication orders — a system that silently fails to retrieve a medication order may result in a duplicate prescription, missed contraindication check, or administration of an order believed to have been retrieved but was not.

---

### 4.6 DiagnosticReport Resource Requirements

> **Clinical Risk Context:** DiagnosticReport links clinical observations to interpretive reports — pathology, radiology, and lab panels. An incomplete or malformed report can delay diagnosis or drive incorrect treatment decisions.

---

**REQ-DXR-001**
A valid `GET /DiagnosticReport/{id}` request SHALL return HTTP status 200 and `resourceType` of `DiagnosticReport`.

- **Source:** HL7 FHIR R4 DiagnosticReport Resource
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** System failure preventing diagnostic report retrieval

---

**REQ-DXR-002**
The DiagnosticReport resource SHALL contain a `status` field with a value from the DiagnosticReportStatus value set: `registered`, `partial`, `preliminary`, `final`, `amended`, `corrected`, `appended`, `cancelled`, `entered-in-error`, `unknown`.

- **Source:** HL7 FHIR R4 DiagnosticReport.status — required field
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Preliminary report acted upon as final
- **Note:** DiagnosticReport status includes `partial` and `appended` which are not present in ObservationStatus. Test assertions must use this resource-specific value set, not the Observation value set.

---

**REQ-DXR-003**
The DiagnosticReport resource SHALL contain a `code` element identifying the type of report.

- **Source:** HL7 FHIR R4 DiagnosticReport.code — required
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Unidentifiable report type

---

**REQ-DXR-004**
The DiagnosticReport resource SHALL contain a `subject` reference.

- **Source:** HL7 FHIR R4 DiagnosticReport.subject
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Report attributed to wrong patient

---

**REQ-DXR-005**
A `GET /DiagnosticReport/{id}` request with a non-existent ID SHALL return HTTP status 404 and an `OperationOutcome` resource.

- **Source:** HL7 FHIR R4 Section 3.1.0.6 — HTTP Status Codes
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Silent failure masking missing diagnostic reports — a clinician system that fails to retrieve a report without a FHIR-compliant error response cannot determine whether the report does not exist or whether a system error occurred, potentially delaying diagnosis.

---

### 4.7 AuditEvent Resource Requirements

> **Clinical Risk Context:** AuditEvent is the primary mechanism for 21 CFR Part 11 compliance in FHIR systems. It records who accessed or modified what data and when. Without reliable AuditEvent records, regulated systems cannot demonstrate data integrity to FDA auditors.

---

**REQ-AUD-001**
A valid `GET /AuditEvent/{id}` request SHALL return HTTP status 200 and `resourceType` of `AuditEvent`.

- **Source:** HL7 FHIR R4 AuditEvent Resource
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Audit trail unavailable for compliance review
- **21 CFR Part 11:** Section 11.10(e) — audit trail requirement

---

**REQ-AUD-002**
The AuditEvent resource SHALL contain a `type` element identifying the event category.

- **Source:** HL7 FHIR R4 AuditEvent.type — required
- **IEC 62304 Class:** B
- **21 CFR Part 11:** Section 11.10(e)

---

**REQ-AUD-003**
The AuditEvent resource SHALL contain a `recorded` timestamp in ISO 8601 format.

- **Source:** HL7 FHIR R4 AuditEvent.recorded — required
- **IEC 62304 Class:** B
- **21 CFR Part 11:** Section 11.10(e) — time-stamped audit trails

---

**REQ-AUD-004**
The AuditEvent resource SHALL contain an `agent` array with at least one entry containing a `who` reference or `name`.

- **Source:** HL7 FHIR R4 AuditEvent.agent — required
- **IEC 62304 Class:** B
- **21 CFR Part 11:** Section 11.10(e) — operator identification in audit trail

---

**REQ-AUD-005**
The AuditEvent resource SHALL contain an `outcome` field indicating success or failure of the audited action.

- **Source:** HL7 FHIR R4 AuditEvent.outcome
- **IEC 62304 Class:** B
- **21 CFR Part 11:** Section 11.10(e)

---

### 4.8 OperationOutcome Requirements

> **Context:** OperationOutcome is the FHIR-mandated error response structure. Every error condition — 400, 404, 422, 500 — must return an OperationOutcome, not a plain HTTP error. This requirement applies to all negative path tests across all resources.

---

**REQ-OO-001**
Any request that results in an error SHALL return a response with `resourceType` of `OperationOutcome`.

- **Source:** HL7 FHIR R4 Section 3.1.0.6
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Non-FHIR error responses breaking client error handling

---

**REQ-OO-002**
The OperationOutcome SHALL contain at least one `issue` element.

- **Source:** HL7 FHIR R4 OperationOutcome.issue — required
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Uninformative error responses preventing issue resolution

---

**REQ-OO-003**
Each `issue` element SHALL contain a `severity` field with value: `fatal`, `error`, `warning`, or `information`.

- **Source:** HL7 FHIR R4 OperationOutcome.issue.severity — required
- **IEC 62304 Class:** B

---

**REQ-OO-004**
Each `issue` element SHALL contain a `code` field from the IssueType value set.

- **Source:** HL7 FHIR R4 OperationOutcome.issue.code — required
- **IEC 62304 Class:** B

---

### 4.9 Bundle Resource Requirements

> **Context:** Most real FHIR transactions use Bundle rather than individual resources. Search results, transaction batches, and history queries all return Bundles. Validating Bundle structure ensures real-world interoperability.

---

**REQ-BUN-001**
A FHIR search query SHALL return a response with `resourceType` of `Bundle` and `type` of `searchset`.

- **Source:** HL7 FHIR R4 Search Framework
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Search results returned in non-standard format breaking integrations

---

**REQ-BUN-002**
A `searchset` Bundle SHALL contain a `total` field indicating the number of matching resources.

- **Source:** HL7 FHIR R4 Bundle.total
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Incomplete result set presented as complete

---

**REQ-BUN-003**
Each entry in a `searchset` Bundle SHALL contain a `resource` element and a `fullUrl`.

- **Source:** HL7 FHIR R4 Bundle.entry
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Unreferenceable resources in search results

---

**REQ-BUN-004**
A valid `transaction` Bundle POST to the base URL SHALL return a `Bundle` of type `transaction-response`.

- **Source:** HL7 FHIR R4 Transaction processing rules
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Transaction outcomes not confirmable

---

**REQ-BUN-005**
If any entry in a `transaction` Bundle is invalid, the entire transaction SHALL fail and no resources SHALL be created.

- **Source:** HL7 FHIR R4 Section 3.2.0.5 — transaction atomicity
- **IEC 62304 Class:** C
- **ISO 14971 Risk:** Partial data writes creating incomplete or inconsistent clinical records

---

**REQ-BUN-006**
The server SHALL include a `self` link relation in the `link` array of every `searchset` Bundle response.

- **Source:** HL7 FHIR R4 Bundle.link — search result navigation
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Interoperability — absence of self link breaks FHIR client navigation and pagination patterns
- **Test reference:** TC-BUN-008

---

### 4.10 Practitioner Resource Requirements

---

**REQ-PRA-001**
A valid `GET /Practitioner/{id}` request SHALL return HTTP status 200 and `resourceType` of `Practitioner`.

- **Source:** HL7 FHIR R4 Practitioner Resource
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** System failure preventing provider identity retrieval

---

**REQ-PRA-002**
The Practitioner resource SHALL contain at least one `name` element.

- **Source:** HL7 FHIR R4 Practitioner.name
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Order attributed to unidentified provider

---

**REQ-PRA-003**
If `identifier` is present, each identifier SHALL contain both `system` and `value`.

- **Source:** HL7 FHIR R4 Identifier datatype
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Duplicate or ambiguous provider records

---

## 5. General Requirements Applicable To All Resources

---

**REQ-GEN-001**
All resources SHALL be validated against the official HL7 FHIR R4 StructureDefinition using the FHIR Validator CLI.

- **Source:** HL7 FHIR R4 Validation Framework
- **IEC 62304 Class:** B
- **Rationale:** Authoritative spec conformance evidence suitable for regulated validation packages

---

**REQ-GEN-002a**
All resources SHALL contain a `meta.lastUpdated` field containing a valid ISO 8601 datetime timestamp.

- **Source:** HL7 FHIR R4 Resource.meta.lastUpdated — 21 CFR Part 11
- **IEC 62304 Class:** B
- **21 CFR Part 11:** Section 11.10(e) — time-stamped audit trails
- **Note:** Replaces REQ-GEN-002 (retired v1.2). Separated from REQ-GEN-002b to allow independent traceability. `meta.lastUpdated` is already covered by resource-specific requirements (REQ-OBS-006, REQ-MED-006, REQ-PAT-006) for Class C resources. REQ-GEN-002a extends this assertion to Class B resources: Practitioner, AuditEvent, and OperationOutcome.

---

**REQ-GEN-002b**
All resources SHALL contain a `meta.versionId` field containing a non-null string value.

- **Source:** HL7 FHIR R4 Resource.meta.versionId — 21 CFR Part 11
- **IEC 62304 Class:** B
- **21 CFR Part 11:** Section 11.10(e) — version-controlled audit trail
- **Note:** Replaces REQ-GEN-002 (retired v1.2). `meta.versionId` is independently testable from `meta.lastUpdated` and was not previously covered by any resource-specific requirement. This requirement closes the gap identified in gap analysis — `meta.versionId` was only tested for Patient and AllergyIntolerance in v1.1. All resources must now assert versionId presence.

---

**REQ-GEN-003**
Requests with malformed JSON bodies SHALL return HTTP status 400 and an `OperationOutcome`.

- **Source:** HL7 FHIR R4 Section 3.1.0.6
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** Silent acceptance of malformed data

---

**REQ-GEN-004**
Requests for unsupported resource types SHALL return HTTP status 404 and an `OperationOutcome`.

- **Source:** HL7 FHIR R4 Section 3.1.0.6
- **IEC 62304 Class:** B

---

**REQ-GEN-005**
The validation suite SHALL support configurable base URL to allow execution against any FHIR R4 compliant server without code changes.

- **Source:** Framework design requirement
- **Rationale:** Enables reuse against vendor systems in real-world validation engagements

---

**REQ-GEN-006**
All test execution reports SHALL be linked to a specific Git commit SHA providing traceability between validation evidence and the exact source code state at the time of execution.

- **Source:** 21 CFR Part 820.40 — document control and traceability
- **IEC 62304 Class:** B
- **Rationale:** Ensures validation evidence is reproducible and attributable to a known, immutable state of the framework. A report without a commit SHA cannot be definitively linked to the code that produced it.

---

**REQ-GEN-007**
The validation framework source code and all validation documents SHALL be maintained under Git version control with branch protection enabled on the `main` branch preventing direct commits and force-push operations.

- **Source:** 21 CFR Part 820.40 — document control; 21 CFR Part 11 — electronic record integrity
- **IEC 62304 Class:** B
- **Rationale:** Branch protection on `main` ensures every change passes through a reviewable pull request, creating an auditable approval record for all modifications to the framework and its documentation. Force-push prevention ensures the evidence chain cannot be retroactively altered.

---

**REQ-GEN-008**
All FHIR R4 API responses SHALL be returned within 10,000 milliseconds under normal sandbox operating conditions.

- **Source:** Non-functional conformance baseline — operational acceptance criterion
- **IEC 62304 Class:** B
- **ISO 14971 Risk:** System latency causing delayed access to clinical data

---

## 6. Requirements Summary

| ID | Resource | Description | IEC 62304 Class |
|---|---|---|---|
| REQ-PRE-001 | CapabilityStatement | Pre-check before all tests | B |
| REQ-PRE-002 | CapabilityStatement | Valid response structure | B |
| REQ-PRE-003 | CapabilityStatement | Valid FHIR R4 version (4.0.x) declared | B |
| REQ-PAT-001 | Patient | Valid GET returns 200 | C |
| REQ-PAT-002 | Patient | name.family required | C |
| REQ-PAT-003 | Patient | identifier required | C |
| REQ-PAT-004 | Patient | birthDate format | C |
| REQ-PAT-005 | Patient | gender value set | C |
| REQ-PAT-006 | Patient | meta.lastUpdated present | C |
| REQ-PAT-007 | Patient | 404 returns OperationOutcome | C |
| REQ-PAT-008 | Patient | Search returns searchset Bundle | C |
| REQ-PAT-012 | Patient | Conditional read returns 304 when ETag matches | C |
| REQ-PAT-013 | Patient | Search by gender returns searchset Bundle | C |
| REQ-PAT-014 | Patient | Search by birthdate returns searchset Bundle | C |
| REQ-PAT-015 | Patient | Search by identifier returns searchset Bundle | C |
| REQ-PAT-016 | Patient | Search by _id returns searchset Bundle | C |
| REQ-OBS-001 | Observation | Valid GET returns 200 | C |
| REQ-OBS-002 | Observation | status value set | C |
| REQ-OBS-003 | Observation | code required | C |
| REQ-OBS-004 | Observation | valueQuantity has value and unit | C |
| REQ-OBS-005 | Observation | subject references Patient | C |
| REQ-OBS-006 | Observation | meta.lastUpdated present | C |
| REQ-OBS-007 | Observation | 404 returns OperationOutcome | C |
| REQ-ALG-001 | AllergyIntolerance | Valid GET returns 200 | C |
| REQ-ALG-002 | AllergyIntolerance | clinicalStatus value set | C |
| REQ-ALG-003 | AllergyIntolerance | verificationStatus required | C |
| REQ-ALG-004 | AllergyIntolerance | patient reference required | C |
| REQ-ALG-005 | AllergyIntolerance | reaction manifestation coded | C |
| REQ-ALG-006 | AllergyIntolerance | 404 returns OperationOutcome | C |
| REQ-MED-001 | MedicationRequest | Valid GET returns 200 | C |
| REQ-MED-002 | MedicationRequest | status value set | C |
| REQ-MED-003 | MedicationRequest | intent value set | C |
| REQ-MED-004 | MedicationRequest | medication[x] required | C |
| REQ-MED-005 | MedicationRequest | subject references Patient | C |
| REQ-MED-006 | MedicationRequest | meta.lastUpdated present | C |
| REQ-MED-007 | MedicationRequest | 404 returns OperationOutcome | C |
| REQ-DXR-001 | DiagnosticReport | Valid GET returns 200 | C |
| REQ-DXR-002 | DiagnosticReport | status value set (enumerated) | C |
| REQ-DXR-003 | DiagnosticReport | code required | C |
| REQ-DXR-004 | DiagnosticReport | subject reference required | C |
| REQ-DXR-005 | DiagnosticReport | 404 returns OperationOutcome | C |
| REQ-AUD-001 | AuditEvent | Valid GET returns 200 | B |
| REQ-AUD-002 | AuditEvent | type required | B |
| REQ-AUD-003 | AuditEvent | recorded timestamp required | B |
| REQ-AUD-004 | AuditEvent | agent required | B |
| REQ-AUD-005 | AuditEvent | outcome required | B |
| REQ-OO-001 | OperationOutcome | Errors return OperationOutcome | B |
| REQ-OO-002 | OperationOutcome | issue array required | B |
| REQ-OO-003 | OperationOutcome | issue.severity value set | B |
| REQ-OO-004 | OperationOutcome | issue.code value set | B |
| REQ-BUN-001 | Bundle | Search returns searchset | B |
| REQ-BUN-002 | Bundle | total field present | B |
| REQ-BUN-003 | Bundle | entry has resource and fullUrl | B |
| REQ-BUN-004 | Bundle | transaction returns response Bundle | B |
| REQ-BUN-005 | Bundle | transaction atomicity on failure | C |
| REQ-BUN-006 | Bundle | searchset Bundle contains self link | B |
| REQ-PRA-001 | Practitioner | Valid GET returns 200 | B |
| REQ-PRA-002 | Practitioner | name required | B |
| REQ-PRA-003 | Practitioner | identifier structure | B |
| REQ-GEN-001 | All | HL7 Validator conformance | B |
| ~~REQ-GEN-002~~ | ~~All~~ | ~~meta.versionId and lastUpdated~~ | ~~Retired v1.2 — split into 002a/002b~~ |
| REQ-GEN-002a | All | meta.lastUpdated present | B |
| REQ-GEN-002b | All | meta.versionId present | B |
| REQ-GEN-003 | All | Malformed JSON returns 400 | B |
| REQ-GEN-004 | All | Unsupported resource returns 404 | B |
| REQ-GEN-005 | All | Configurable base URL | B |
| REQ-GEN-006 | All | Test reports linked to Git commit SHA | B |
| REQ-GEN-007 | All | Git version control with branch protection | B |
| REQ-GEN-008 | All | API response time < 10,000ms | B |

**Total Active Requirements: 68**
**Class C (Critical): 39**
**Class B (High): 29**

*REQ-GEN-002 retired in v1.2 — replaced by REQ-GEN-002a and REQ-GEN-002b. The retired requirement row is retained for traceability history.*

---

## 7. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added 21 CFR Part 820.40 to regulatory standards; added REQ-GEN-006 and REQ-GEN-007 for Git traceability and branch protection; updated requirements summary totals |
| 1.2 | 2026-03-30 | Amir Choshov | Added REQ-OBS-007, REQ-ALG-006, REQ-MED-007, REQ-DXR-005 — dedicated 404 negative path requirements for all Class C resources; retired REQ-GEN-002 and replaced with REQ-GEN-002a (meta.lastUpdated) and REQ-GEN-002b (meta.versionId) for independent testability; updated REQ-DXR-002 to enumerate full DiagnosticReport status value set including partial and appended; updated summary table and totals (56 → 61 active requirements, Class C: 30 → 34) |
| 1.3 | 2026-04-11 | Amir Choshov | Added REQ-PAT-012 through REQ-PAT-016 and REQ-BUN-006 from hardening pass. Updated REQ-PRE-003 to accept `4.0.x` regex rather than literal `4.0.1`. Status updated to Approved. Scope updated: added response time, header, conditional read, search parameter, pagination, and multi-server test types. Target system updated: SMART Health IT added as secondary server. Total requirements: 67 (39 Class C, 28 Class B). |
| 1.4 | 2026-04-12 | Amir Choshov | Added REQ-GEN-008 (response time) to formally trace responseTime assertions in feature files; updated summary totals 67 → 68 (39 Class C, 29 Class B). |

---

## 8. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | | |
| Reviewer | | | |

---

*This document is part of the FHIR R4 API Validation Suite validation package. All requirements in this document must be covered in the Traceability Matrix before validation is considered complete.*