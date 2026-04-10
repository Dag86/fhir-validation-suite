@ignore
Feature: Assert AuditEvent type.system and type.code

  Scenario:
    Given url baseUrl
    And path 'AuditEvent', auditEventId
    When method GET
    Then status 200
    And match response.type == '#present'
    * def typeIsArray = response.type instanceof Array
    * def typeSystem = typeIsArray ? response.type[0].system : response.type.system
    * def typeCode = typeIsArray ? response.type[0].code : response.type.code
    * match typeSystem == '#present'
    * match typeCode == '#present'
    * karate.log('type.system: ' + typeSystem)
    * karate.log('type.code: ' + typeCode)
