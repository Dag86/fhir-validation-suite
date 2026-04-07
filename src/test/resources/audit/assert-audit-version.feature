@ignore
Feature: Assert AuditEvent meta.versionId
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.meta.versionId == '#present'
    * karate.log('meta.versionId: ' + response.meta.versionId)
