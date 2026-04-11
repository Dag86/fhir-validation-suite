Feature: OperationOutcome Validation
  Tests that the HAPI FHIR sandbox returns well-formed OperationOutcome
  resources for invalid requests, per REQ-ERR-001 through REQ-ERR-004.

  Background:
    * url baseUrl

  Scenario: TC-OO-001 OperationOutcome returned for invalid resource POST
    Given path 'Patient'
    And request {}
    And header Content-Type = 'application/fhir+json'
    When method post
    Then status 400
    And assert responseTime < 10000
    And match response.resourceType == 'OperationOutcome'

  Scenario: TC-OO-002 OperationOutcome issue array is present and non-empty
    Given path 'Patient'
    And request {}
    And header Content-Type = 'application/fhir+json'
    When method post
    Then status 400
    And match response.issue == '#[_ > 0]'

  Scenario: TC-OO-003 OperationOutcome issue severity is a valid value set member
    Given path 'Patient'
    And request {}
    And header Content-Type = 'application/fhir+json'
    When method post
    Then status 400
    And match each response.issue contains { severity: '#regex (fatal|error|warning|information)' }

  Scenario: TC-OO-004 OperationOutcome issue code is present
    Given path 'Patient'
    And request {}
    And header Content-Type = 'application/fhir+json'
    When method post
    Then status 400
    And match each response.issue contains { code: '#present' }

  Scenario: TC-OO-005 OperationOutcome captured to target/responses/
    Given path 'Patient'
    And request {}
    And header Content-Type = 'application/fhir+json'
    When method post
    Then status 400
    * def fileName = 'operation-outcome-' + java.lang.System.currentTimeMillis() + '.json'
    * karate.write(response, 'responses/' + fileName)
