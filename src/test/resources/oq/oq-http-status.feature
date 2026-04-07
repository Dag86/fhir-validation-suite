Feature: Karate OQ - HTTP Status Assertion
  Scenario: Correct HTTP status assertion passes
    Given url 'https://hapi.fhir.org/baseR4/metadata'
    When method GET
    Then status 200
