@ignore
Feature: Assert AuditEvent type.system and type.code
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.type == '#present'
    And match response.type.system == '#present'
    And match response.type.code == '#present'
    * karate.log('type.system: ' + response.type.system)
    * karate.log('type.code: ' + response.type.code)
