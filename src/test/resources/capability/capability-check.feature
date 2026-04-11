@pre-check
Feature: CapabilityStatement Pre-Check
  # REQ-PRE-001: Suite SHALL query /metadata before all resource tests
  # REQ-PRE-002: Response SHALL return 200 and resourceType = CapabilityStatement
  # REQ-PRE-003: fhirVersion SHALL be 4.0.1

  Background:
    * url baseUrl

  Scenario: TC-CAP-001 | REQ-PRE-001 GET /metadata returns 200 and CapabilityStatement resourceType
    Given path 'metadata'
    When method GET
    Then status 200
    And assert responseTime < 10000
    And match response.resourceType == 'CapabilityStatement'

  Scenario: TC-CAP-002 | REQ-PRE-002 CapabilityStatement declares FHIR R4 version
    Given path 'metadata'
    When method GET
    Then status 200
    And match response.fhirVersion == '#regex 4\\.0\\.[0-9]+'

  Scenario: TC-CAP-003 | REQ-PRE-003 CapabilityStatement exposes supported resources list
    Given path 'metadata'
    When method GET
    Then status 200
    And match response.rest == '#[_ > 0]'
    And match response.rest[0].resource == '#[_ > 0]'
    * def supportedResources = response.rest[0].resource.map(r => r.type)
    * karate.log('Supported resource count:', supportedResources.length)
    * karate.log('Supported resources:', supportedResources)
