Feature: General FHIR API Behaviour
  Tests general API behaviour not specific to a single resource type,
  per REQ-GEN-003.

  Background:
    * url baseUrl

  Scenario: TC-GEN-001 Unsupported resource type returns 404 and OperationOutcome
    Given path 'UnsupportedResourceXYZ'
    When method get
    Then status 404
    And assert responseTime < 10000
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'
    And match each response.issue contains { severity: '#present', code: '#present' }
