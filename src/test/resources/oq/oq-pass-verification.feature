Feature: Karate OQ - Pass Verification
  Scenario: Assert known true condition passes
    * def response = { resourceType: 'Patient', id: '123' }
    * match response.resourceType == 'Patient'
    * match response.id == '123'
