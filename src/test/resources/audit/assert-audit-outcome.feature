@ignore
Feature: Assert AuditEvent outcome field
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.outcome == '#present'
    * karate.log('outcome: ' + response.outcome)
