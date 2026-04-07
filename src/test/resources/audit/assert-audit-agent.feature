@ignore
Feature: Assert AuditEvent agent array
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.agent == '#[_ > 0]'
    * karate.log('agent count: ' + response.agent.length)
