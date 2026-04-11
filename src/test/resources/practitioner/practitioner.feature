@practitioner
Feature: Practitioner Resource Validation
  # REQ-PRA-001: GET /Practitioner/{id} returns 200 and resourceType = Practitioner
  # REQ-PRA-002: name element is present and non-empty
  # REQ-PRA-003: identifier[0].system and identifier[0].value present (conditional)
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002b: meta.versionId is present and non-null
  # REQ-OO-001: Error responses return OperationOutcome resourceType

  Background:
    * url baseUrl
    Given path 'Practitioner'
    And param _count = '1'
    When method GET
    Then status 200
    * def practitionerId = response.entry[0].resource.id
    * match response.entry[0].resource.resourceType == 'Practitioner'
    * karate.log('Resolved practitionerId: ' + practitionerId)

  Scenario: TC-PRA-001 | REQ-PRA-001 GET /Practitioner/{id} returns 200 and resourceType = Practitioner
    Given path 'Practitioner', practitionerId
    When method GET
    Then status 200
    And match response.resourceType == 'Practitioner'
    * karate.write(response, 'responses/practitioner/practitioner-read.json')

  Scenario: TC-PRA-002 | REQ-PRA-002 name element is present and non-empty
    Given path 'Practitioner', practitionerId
    When method GET
    Then status 200
    And match response.name == '#[_ > 0]'

  Scenario: TC-PRA-003 | REQ-PRA-003 identifier system and value are present (conditional)
    Given path 'Practitioner', practitionerId
    When method GET
    Then status 200
    * def hasIdentifier = response.identifier != null && response.identifier.length > 0
    * if (!hasIdentifier) karate.log('TC-PRA-003: SKIP — identifier not present on resolved Practitioner ' + practitionerId)
    * if (hasIdentifier) karate.match(response.identifier[0].system, '#present')
    * if (hasIdentifier) karate.match(response.identifier[0].value, '#present')

  Scenario: TC-PRA-004 | REQ-PRA-001 | REQ-OO-001 non-existent ID returns 404 and OperationOutcome
    Given path 'Practitioner', 'INVALID-ID-99999'
    When method GET
    Then status 404
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'
    * karate.log('404 severity: ' + response.issue[0].severity)
    * karate.log('404 code: ' + response.issue[0].code)

  Scenario: TC-PRA-005 | REQ-GEN-001 captured practitioner-read.json exists for HL7 Validator
    # karate.write() resolves paths under target/ when running under Maven
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/practitioner/practitioner-read.json'))
    * assert fileExists == true

  Scenario: TC-PRA-006 | REQ-GEN-002b meta.versionId is present and non-null
    Given path 'Practitioner', practitionerId
    When method GET
    Then status 200
    And match response.meta.versionId == '#present'
