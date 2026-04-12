@observation
Feature: Observation Resource Validation
  # REQ-OBS-001: GET /Observation/{id} returns 200 and resourceType = Observation
  # REQ-OBS-002: status is a valid ObservationStatus value
  # REQ-OBS-003: code.coding has system and code
  # REQ-OBS-004: valueQuantity has value and unit (conditional)
  # REQ-OBS-005: subject references Patient
  # REQ-OBS-006: meta.lastUpdated is present
  # REQ-OBS-007: Non-existent ID returns 404 + OperationOutcome
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002b: meta.versionId is present

  Background:
    * url baseUrl
    Given path 'Observation'
    And params ({ 'subject:missing': 'false', '_count': '1' })
    When method GET
    Then status 200
    * def hasEntry = response.entry != null && response.entry.length > 0
    * match hasEntry == true
    * def observationId = response.entry[0].resource.id
    * match response.entry[0].resource.resourceType == 'Observation'
    * karate.log('Resolved observationId: ' + observationId)

  Scenario: TC-OBS-001 | REQ-OBS-001 GET /Observation/{id} returns 200 and resourceType = Observation
    Given path 'Observation', observationId
    When method GET
    Then status 200
    And assert responseTime < 10000
    And match responseHeaders['Content-Type'][0] contains 'application/fhir+json'
    And match responseHeaders['ETag'][0] == '#present'
    And match response.resourceType == 'Observation'
    * karate.write(response, 'responses/observation/observation-read.json')

  Scenario: TC-OBS-002 | REQ-OBS-002 status is a valid ObservationStatus value
    Given path 'Observation', observationId
    When method GET
    Then status 200
    And match response.status == '#regex (registered|preliminary|final|amended|corrected|cancelled|entered-in-error|unknown)'
    * karate.log('status: ' + response.status)

  Scenario: TC-OBS-003 | REQ-OBS-003 code.coding has system and code
    Given path 'Observation', observationId
    When method GET
    Then status 200
    And match response.code == '#present'
    And match response.code.coding == '#[_ > 0]'
    And match response.code.coding[0].system == '#present'
    And match response.code.coding[0].code == '#present'
    * karate.log('code system: ' + response.code.coding[0].system)
    * karate.log('code code: ' + response.code.coding[0].code)

  Scenario: TC-OBS-004 | REQ-OBS-004 valueQuantity has value and unit (conditional)
    Given path 'Observation'
    And params ({ 'value-quantity': 'gt0', '_count': '1' })
    When method GET
    Then status 200
    * def hasEntry = response.entry != null && response.entry.length > 0
    * if (!hasEntry) karate.log('TC-OBS-004: SKIP — no Observation with valueQuantity found on server')
    * def vqId = hasEntry ? response.entry[0].resource.id : null
    * if (hasEntry) karate.call('classpath:observation/assert-value-quantity.feature', { vqId: vqId, baseUrl: baseUrl })

  Scenario: TC-OBS-005 | REQ-OBS-005 subject references Patient
    Given path 'Observation', observationId
    When method GET
    Then status 200
    And match response.subject == '#present'
    And match response.subject.reference == '#string'
    And match response.subject.reference == '#regex .*Patient.*'
    * karate.log('subject reference: ' + response.subject.reference)

  Scenario: TC-OBS-006 | REQ-OBS-006 | REQ-GEN-002a meta.lastUpdated is present
    Given path 'Observation', observationId
    When method GET
    Then status 200
    And match response.meta.lastUpdated == '#present'
    * karate.log('meta.lastUpdated: ' + response.meta.lastUpdated)

  Scenario: TC-OBS-007 | REQ-OBS-007 | REQ-OO-001 non-existent ID returns 404 and OperationOutcome
    Given path 'Observation', 'INVALID-ID-99999'
    When method GET
    Then status 404
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'
    * karate.log('404 severity: ' + response.issue[0].severity)
    * karate.log('404 code: ' + response.issue[0].code)

  Scenario: TC-OBS-008 | REQ-GEN-001 captured observation-read.json exists for HL7 Validator
    # karate.write() resolves paths under target/ when running under Maven
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/observation/observation-read.json'))
    * assert fileExists == true

  Scenario: TC-OBS-009 | REQ-GEN-002b meta.versionId is present
    Given path 'Observation', observationId
    When method GET
    Then status 200
    And match response.meta.versionId == '#present'
    * karate.log('meta.versionId: ' + response.meta.versionId)
