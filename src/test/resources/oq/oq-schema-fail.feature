Feature: Karate OQ - Schema Validation Fail
  Scenario: Missing required field fails schema match
    * def schema = { resourceType: '#string', id: '#string', name: '#array' }
    * def response = { resourceType: 'Patient', id: '123' }
    * match response == schema
