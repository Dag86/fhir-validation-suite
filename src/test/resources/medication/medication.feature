@medication
Feature: MedicationRequest Resource Validation
  # REQ-MED-001: GET /MedicationRequest/{id} returns 200 and resourceType = MedicationRequest
  # REQ-MED-002: status is a valid MedicationRequest status value
  # REQ-MED-003: intent is a valid MedicationRequest intent value
  # REQ-MED-004: subject references Patient
  # REQ-MED-005: medicationCodeableConcept or medicationReference is present
  # REQ-MED-006: meta.lastUpdated is present
  # REQ-MED-007: Non-existent ID returns 404 + OperationOutcome
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002b: meta.versionId is present
  # REQ-GEN-003: Malformed JSON returns 400 + OperationOutcome

  Background:
    * url baseUrl
    Given path 'MedicationRequest'
    And params ({ 'subject:missing': 'false', '_count': '1' })
    When method GET
    Then status 200
    * def medicationId = response.entry[0].resource.id
    * match response.entry[0].resource.resourceType == 'MedicationRequest'
    * karate.log('Resolved medicationId: ' + medicationId)

  Scenario: TC-MED-001 | REQ-MED-001 GET /MedicationRequest/{id} returns 200 and resourceType = MedicationRequest
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    And match response.resourceType == 'MedicationRequest'
    * karate.write(response, 'responses/medication/medication-read.json')

  Scenario: TC-MED-002 | REQ-MED-002 status is a valid MedicationRequest status value
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    And match response.status == '#regex (active|on-hold|cancelled|completed|entered-in-error|stopped|draft|unknown)'
    * karate.log('status: ' + response.status)

  Scenario: TC-MED-003 | REQ-MED-003 intent is a valid MedicationRequest intent value
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    And match response.intent == '#regex (proposal|plan|order|original-order|reflex-order|filler-order|instance-order|option)'
    * karate.log('intent: ' + response.intent)

  Scenario: TC-MED-004 | REQ-MED-004 subject references Patient
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    And match response.subject == '#present'
    And match response.subject.reference == '#string'
    And match response.subject.reference == '#regex .*Patient.*'
    * karate.log('subject reference: ' + response.subject.reference)

  Scenario: TC-MED-005 | REQ-MED-005 medicationCodeableConcept or medicationReference is present
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    * def hasMedCC = response.medicationCodeableConcept != null
    * def hasMedRef = response.medicationReference != null
    * def hasMedication = hasMedCC || hasMedRef
    * match hasMedication == true
    * if (hasMedCC) karate.log('medication: medicationCodeableConcept present')
    * if (hasMedRef) karate.log('medication: medicationReference present')

  Scenario: TC-MED-006 | REQ-MED-006 | REQ-GEN-002a meta.lastUpdated is present
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    And match response.meta.lastUpdated == '#present'
    * karate.log('meta.lastUpdated: ' + response.meta.lastUpdated)

  Scenario: TC-MED-007 | REQ-MED-007 | REQ-OO-001 non-existent ID returns 404 and OperationOutcome
    Given path 'MedicationRequest', 'INVALID-ID-99999'
    When method GET
    Then status 404
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'
    * karate.log('404 severity: ' + response.issue[0].severity)
    * karate.log('404 code: ' + response.issue[0].code)

  Scenario: TC-MED-008 | REQ-GEN-001 captured medication-read.json exists for HL7 Validator
    # karate.write() resolves paths under target/ when running under Maven
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/medication/medication-read.json'))
    * assert fileExists == true

  Scenario: TC-MED-009 | REQ-GEN-003 | REQ-OO-001 malformed JSON returns 400 and OperationOutcome
    # HAPI may return 422 instead of 400 — report as finding if so
    Given path 'MedicationRequest'
    And header Content-Type = 'application/fhir+json'
    And request 'this is not valid json'
    When method POST
    Then status 400
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'

  Scenario: TC-MED-010 | REQ-GEN-002b meta.versionId is present
    Given path 'MedicationRequest', medicationId
    When method GET
    Then status 200
    And match response.meta.versionId == '#present'
    * karate.log('meta.versionId: ' + response.meta.versionId)
