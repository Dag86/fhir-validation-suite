@allergy
Feature: AllergyIntolerance Resource Validation
  # REQ-ALG-001: GET /AllergyIntolerance/{id} returns 200 and resourceType = AllergyIntolerance
  # REQ-ALG-002: clinicalStatus.coding[0].code is one of: active, inactive, resolved
  # REQ-ALG-003: verificationStatus is present
  # REQ-ALG-004: patient reference is present
  # REQ-ALG-005: reaction[0].manifestation[0].coding is present (conditional)
  # REQ-ALG-006: Non-existent ID returns 404 + OperationOutcome
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002a: meta.lastUpdated is present
  # REQ-GEN-002b: meta.versionId is present

  Background:
    * url baseUrl
    Given path 'AllergyIntolerance'
    And params ({ 'patient:missing': 'false', '_count': '1' })
    When method GET
    Then status 200
    * def allergyId = response.entry[0].resource.id
    * match response.entry[0].resource.resourceType == 'AllergyIntolerance'
    * karate.log('Resolved allergyId: ' + allergyId)

  Scenario: TC-ALG-001 | REQ-ALG-001 GET /AllergyIntolerance/{id} returns 200 and resourceType = AllergyIntolerance
    Given path 'AllergyIntolerance', allergyId
    When method GET
    Then status 200
    And assert responseTime < 10000
    And match response.resourceType == 'AllergyIntolerance'
    * karate.write(response, 'responses/allergy/allergy-read.json')

  Scenario: TC-ALG-002 | REQ-ALG-002 clinicalStatus.coding[0].code is active inactive or resolved
    Given path 'AllergyIntolerance', allergyId
    When method GET
    Then status 200
    And match response.clinicalStatus == '#present'
    And match response.clinicalStatus.coding == '#[_ > 0]'
    And match response.clinicalStatus.coding[0].code == '#regex (active|inactive|resolved)'
    * karate.log('clinicalStatus: ' + response.clinicalStatus.coding[0].code)

  Scenario: TC-ALG-003 | REQ-ALG-003 verificationStatus is present
    Given path 'AllergyIntolerance', allergyId
    When method GET
    Then status 200
    And match response.verificationStatus == '#present'
    * karate.log('verificationStatus: ' + response.verificationStatus.coding[0].code)

  Scenario: TC-ALG-004 | REQ-ALG-004 patient reference is present
    Given path 'AllergyIntolerance', allergyId
    When method GET
    Then status 200
    And match response.patient == '#present'
    And match response.patient.reference == '#string'
    * karate.log('patient reference: ' + response.patient.reference)


  Scenario: TC-ALG-005 | REQ-ALG-005 reaction manifestation coding present (conditional)
    Given path 'AllergyIntolerance', allergyId
    When method GET
    Then status 200
    * def hasReaction = response.reaction != null && response.reaction.length > 0
    * if (!hasReaction) karate.log('TC-ALG-005: SKIP — no reaction element on resolved AllergyIntolerance ' + allergyId)
    * if (hasReaction) karate.match(response.reaction[0].manifestation, '#[_ > 0]')
    * if (hasReaction) karate.match(response.reaction[0].manifestation[0].coding, '#[_ > 0]')
    * if (hasReaction) karate.log('reaction manifestation coding present')

  Scenario: TC-ALG-006 | REQ-ALG-006 | REQ-OO-001 non-existent ID returns 404 and OperationOutcome
    Given path 'AllergyIntolerance', 'INVALID-ID-99999'
    When method GET
    Then status 404
    And match response.resourceType == 'OperationOutcome'
    And match response.issue == '#[_ > 0]'
    * karate.log('404 severity: ' + response.issue[0].severity)
    * karate.log('404 code: ' + response.issue[0].code)

  Scenario: TC-ALG-007 | REQ-GEN-001 captured allergy-read.json exists for HL7 Validator
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/allergy/allergy-read.json'))
    * assert fileExists == true

  Scenario: TC-ALG-008 | REQ-GEN-002a | REQ-GEN-002b meta.lastUpdated and meta.versionId are present
    Given path 'AllergyIntolerance', allergyId
    When method GET
    Then status 200
    And match response.meta.lastUpdated == '#present'
    And match response.meta.versionId == '#present'
    * karate.log('meta.lastUpdated: ' + response.meta.lastUpdated)
    * karate.log('meta.versionId: ' + response.meta.versionId)
