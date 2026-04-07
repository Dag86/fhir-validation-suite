@ignore
Feature: Assert valueQuantity on a specific Observation
  # Called by TC-OBS-004 when a valueQuantity Observation is found
  # Params: vqId (string), baseUrl (string)

  Scenario:
    Given url baseUrl
    And path 'Observation', vqId
    When method GET
    Then status 200
    And match response.valueQuantity == '#present'
    And match response.valueQuantity.value == '#number'
    And match response.valueQuantity.unit == '#string'
    * karate.log('valueQuantity.value: ' + response.valueQuantity.value)
    * karate.log('valueQuantity.unit: ' + response.valueQuantity.unit)
