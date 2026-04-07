@ignore
Feature: Capture AuditEvent and assert file exists
  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    * karate.write(response, 'responses/audit/audit-event-read.json')
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/audit/audit-event-read.json'))
    * assert fileExists == true
