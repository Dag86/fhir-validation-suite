@ignore
Feature: Assert AuditEvent recorded timestamp
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.recorded == '#present'
    * karate.log('recorded: ' + response.recorded)
