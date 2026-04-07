@diagnostic
Feature: DiagnosticReport Resource Validation
  # REQ-DXR-001: GET /DiagnosticReport/{id} returns 200 and resourceType = DiagnosticReport
  # REQ-DXR-002: status is a valid DiagnosticReport status value
  # REQ-DXR-003: code.coding has system and code
  # REQ-DXR-004: subject references Patient
  # REQ-DXR-005: Non-existent ID returns 404 + OperationOutcome
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002b: meta.versionId is present

  Background:
    * url baseUrl
    Given path 'DiagnosticReport'
    And params ({ 'subject:missing': 'false', '_count': '1' })
    When method GET
    Then status 200
    * def diagnosticReportId = response.entry[0].resource.id
    * karate.log('Resolved diagnosticReportId: ' + diagnosticReportId)

  Scenario: TC-DXR-001 | REQ-DXR-001 GET /DiagnosticReport/{id} returns 200 and resourceType = DiagnosticReport
    Given path 'DiagnosticReport', diagnosticReportId
    When method GET
    Then status 200
    And match response.resourceType == 'DiagnosticReport'
    * karate.write(response, 'responses/diagnostic/diagnostic-report-read.json')

  Scenario: TC-DXR-002 | REQ-DXR-002 status is a valid DiagnosticReport status value
    Given path 'DiagnosticReport', diagnosticReportId
    When method GET
    Then status 200
    And match response.status == '#regex (registered|partial|preliminary|final|amended|corrected|appended|cancelled|entered-in-error|unknown)'
    * karate.log('status: ' + response.status)

  Scenario: TC-DXR-003 | REQ-DXR-003 code.coding has system and code
    Given path 'DiagnosticReport', diagnosticReportId
    When method GET
    Then status 200
    And match response.code == '#present'
    And match response.code.coding == '#[_ > 0]'
    And match response.code.coding[0].system == '#present'
    And match response.code.coding[0].code == '#present'
    * karate.log('code system: ' + response.code.coding[0].system)
    * karate.log('code code: ' + response.code.coding[0].code)

  Scenario: TC-DXR-004 | REQ-DXR-004 subject references Patient
    Given path 'DiagnosticReport', diagnosticReportId
    When method GET
    Then status 200
    And match response.subject == '#present'
    And match response.subject.reference == '#string'
    And match response.subject.reference == '#regex .*Patient.*'
    * karate.log('subject reference: ' + response.subject.reference)

  Scenario: TC-DXR-005 | REQ-DXR-005 | REQ-OO-001 non-existent ID returns 404 and OperationOutcome
    Given path 'DiagnosticReport', 'INVALID-ID-99999'
    When method GET
    Then status 404
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'
    * karate.log('404 severity: ' + response.issue[0].severity)
    * karate.log('404 code: ' + response.issue[0].code)

  Scenario: TC-DXR-006 | REQ-GEN-001 captured diagnostic-report-read.json exists for HL7 Validator
    # karate.write() resolves paths under target/ when running under Maven
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/diagnostic/diagnostic-report-read.json'))
    * assert fileExists == true

  Scenario: TC-DXR-007 | REQ-GEN-002b meta.versionId is present
    Given path 'DiagnosticReport', diagnosticReportId
    When method GET
    Then status 200
    And match response.meta.versionId == '#present'
    * karate.log('meta.versionId: ' + response.meta.versionId)
