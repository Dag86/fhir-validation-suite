Feature: Karate OQ - Schema Validation Pass
  Scenario: Valid schema match passes
    * def schema = { resourceType: '#string', id: '#string', name: '#array' }
    * def response = { resourceType: 'Patient', id: '123', name: [{ family: 'Smith' }] }
    * match response == schema
