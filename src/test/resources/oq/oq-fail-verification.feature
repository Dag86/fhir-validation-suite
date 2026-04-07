Feature: Karate OQ - Fail Verification
  Scenario: Assert known false condition fails
    * def response = { resourceType: 'Observation' }
    * match response.resourceType == 'Patient'
