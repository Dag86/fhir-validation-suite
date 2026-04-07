@ignore
Feature: Assert AuditEvent read and capture
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.resourceType == 'AuditEvent'
    * karate.write(response, 'responses/audit/audit-event-read.json')
