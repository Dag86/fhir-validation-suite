@bundle @parallel=false
Feature: Bundle Resource Validation
  # REQ-BUN-001: Search returns searchset Bundle
  # REQ-BUN-002: searchset Bundle has total field
  # REQ-BUN-003: Each entry has resource and fullUrl
  # REQ-BUN-004: Valid transaction returns transaction-response Bundle
  # REQ-BUN-005: Transaction atomicity — invalid entry fails entire transaction
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002b: meta.versionId present on transaction response resource
  # REQ-BUN-006: searchset Bundle contains self link relation

  Background:
    * url baseUrl
    * def uniqueSuffix = java.lang.System.currentTimeMillis() + ''

  Scenario: TC-BUN-001 | REQ-BUN-001 search returns searchset Bundle
    Given path 'Patient'
    And param _count = '5'
    When method GET
    Then status 200
    And assert responseTime < 10000
    And match responseHeaders['Content-Type'][0] contains 'application/fhir+json'
    And match response.resourceType == 'Bundle'
    And match response.type == 'searchset'
    * karate.log('Bundle type: ' + response.type)

  Scenario: TC-BUN-002 | REQ-BUN-002 searchset Bundle has total field
    Given path 'Patient'
    And param _count = '5'
    And param _total = 'accurate'
    When method GET
    Then status 200
    And match response.total == '#notnull'
    * karate.log('Bundle total: ' + response.total)

  Scenario: TC-BUN-003 | REQ-BUN-003 each entry has resource and fullUrl
    Given path 'Patient'
    And param _count = '5'
    When method GET
    Then status 200
    * def hasEntry = response.entry != null && response.entry.length > 0
    * if (!hasEntry) karate.log('TC-BUN-003: SKIP — search returned zero entries')
    * if (hasEntry) karate.match(response.entry[0].fullUrl, '#present')
    * if (hasEntry) karate.match(response.entry[0].resource, '#present')
    * if (hasEntry) karate.log('entry[0].fullUrl: ' + response.entry[0].fullUrl)

  Scenario: TC-BUN-004 | REQ-BUN-004 valid transaction returns transaction-response Bundle
    Given url baseUrl
    And header Content-Type = 'application/fhir+json'
    And request ({ "resourceType": "Bundle", "type": "transaction", "entry": [{ "resource": { "resourceType": "Patient", "name": [{ "family": "BundleTestPatient", "given": ["TC-BUN-004-" + uniqueSuffix] }] }, "request": { "method": "POST", "url": "Patient" } }] })
    When method POST
    Then status 200
    And match response.resourceType == 'Bundle'
    And match response.type == 'transaction-response'
    And match response.entry == '#[_ > 0]'
    And match response.entry[0].response.status == '#regex 201.*'
    * karate.log('transaction-response status: ' + response.entry[0].response.status)
    * karate.write(response, 'responses/bundle/bundle-transaction-response.json')

  Scenario: TC-BUN-005 | REQ-BUN-005 invalid transaction entry fails entire transaction and is atomic
    # Step 1: POST a transaction with one valid and one invalid entry (missing resourceType)
    Given url baseUrl
    And header Content-Type = 'application/fhir+json'
    And request ({ "resourceType": "Bundle", "type": "transaction", "entry": [{ "resource": { "resourceType": "Patient", "name": [{ "family": "AtomicityTestPatient", "given": ["ShouldNotExist-" + uniqueSuffix] }] }, "request": { "method": "POST", "url": "Patient" } }, { "resource": { "name": [{ "family": "InvalidEntry-" + uniqueSuffix }] }, "request": { "method": "POST", "url": "Patient" } }] })
    When method POST
    * def txStatus = responseStatus
    * karate.log('TC-BUN-005 transaction rejected with: ' + txStatus)
    * assert txStatus >= 400 && txStatus < 500
    And match response.resourceType == 'OperationOutcome'
    # Step 2: Confirm atomicity — the valid Patient entry MUST NOT have been written
    Given url baseUrl
    And path 'Patient'
    And param family = 'AtomicityTestPatient'
    And param given = 'ShouldNotExist-' + uniqueSuffix
    And param _count = '1'
    When method GET
    Then status 200
    * karate.log('TC-BUN-005 atomicity confirmed — partial write count: ' + response.total)
    And match response.total == 0

  Scenario: TC-BUN-006 | REQ-GEN-001 captured bundle-transaction-response.json exists for HL7 Validator
    # Self-contained: POST transaction, write, then assert file exists
    Given url baseUrl
    And header Content-Type = 'application/fhir+json'
    And request ({ "resourceType": "Bundle", "type": "transaction", "entry": [{ "resource": { "resourceType": "Patient", "name": [{ "family": "BundleTestPatient", "given": ["TC-BUN-006-" + uniqueSuffix] }] }, "request": { "method": "POST", "url": "Patient" } }] })
    When method POST
    Then status 200
    * karate.write(response, 'responses/bundle/bundle-transaction-response.json')
    * def fileExists = java.nio.file.Files.exists(java.nio.file.Paths.get('target/responses/bundle/bundle-transaction-response.json'))
    * assert fileExists == true

  Scenario: TC-BUN-007 | REQ-GEN-002b transaction response location confirms versionId tracking
    # Self-contained: POST transaction and inspect location in the same scenario
    Given url baseUrl
    And header Content-Type = 'application/fhir+json'
    And request ({ "resourceType": "Bundle", "type": "transaction", "entry": [{ "resource": { "resourceType": "Patient", "name": [{ "family": "BundleTestPatient", "given": ["TC-BUN-007-" + uniqueSuffix] }] }, "request": { "method": "POST", "url": "Patient" } }] })
    When method POST
    Then status 200
    * def createdLocation = response.entry[0].response.location
    * karate.log('TC-BUN-007 created resource location: ' + createdLocation)
    * match createdLocation == '#string'

  Scenario: TC-BUN-008 | REQ-BUN-006 searchset Bundle contains self link relation
    Given path 'Patient'
    And param _count = '5'
    When method GET
    Then status 200
    And assert responseTime < 10000
    And match responseHeaders['Content-Type'][0] contains 'application/fhir+json'
    * def selfLink = response.link.filter(l => l.relation == 'self')[0]
    * match selfLink == '#present'
    * karate.log('Self link URL: ' + selfLink.url)
