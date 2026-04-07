@audit
Feature: AuditEvent Resource Validation
  # REQ-AUD-001: GET /AuditEvent/{id} returns 200 and resourceType = AuditEvent
  # REQ-AUD-002: type field present with system and code (21 CFR 11.10(e) — action identification)
  # REQ-AUD-003: recorded timestamp present in ISO 8601 format (21 CFR 11.10(e) — time-stamped audit trails)
  # REQ-AUD-004: agent array present (21 CFR 11.10(e) — operator identification)
  # REQ-AUD-005: outcome field present (21 CFR 11.10(e) — action result recorded)
  # REQ-GEN-001: HL7 Validator can process the captured response
  # REQ-GEN-002b: meta.versionId is present

  Background:
    * url baseUrl
    Given path 'AuditEvent'
    And param _count = '1'
    When method GET
    Then status 200
    * def hasEntry = response.entry != null && response.entry.length > 0
    * def auditEventAvailable = hasEntry
    * def auditEventId = hasEntry ? response.entry[0].resource.id : null
    * if (auditEventAvailable) karate.log('Resolved auditEventId: ' + auditEventId)
    * if (!auditEventAvailable) karate.log('TC-AUD block: SKIP — no AuditEvent resources on server')

  Scenario: TC-AUD-001 | REQ-AUD-001 GET /AuditEvent/{id} returns 200 and resourceType = AuditEvent
    * if (!auditEventAvailable) karate.log('TC-AUD-001: SKIP — no AuditEvent resources on server')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-read.feature', { auditEventId: auditEventId, baseUrl: baseUrl })

  Scenario: TC-AUD-002 | REQ-AUD-002 type.system and type.code are present
    * if (!auditEventAvailable) karate.log('TC-AUD-002: SKIP — no AuditEvent resources on server')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-type.feature', { auditEventId: auditEventId, baseUrl: baseUrl })

  Scenario: TC-AUD-003 | REQ-AUD-003 recorded timestamp is present
    * if (!auditEventAvailable) karate.log('TC-AUD-003: SKIP — no AuditEvent resources on server')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-recorded.feature', { auditEventId: auditEventId, baseUrl: baseUrl })

  Scenario: TC-AUD-004 | REQ-AUD-004 agent array is present
    * if (!auditEventAvailable) karate.log('TC-AUD-004: SKIP — no AuditEvent resources on server')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-agent.feature', { auditEventId: auditEventId, baseUrl: baseUrl })

  Scenario: TC-AUD-005 | REQ-AUD-005 outcome field is present
    * if (!auditEventAvailable) karate.log('TC-AUD-005: SKIP — no AuditEvent resources on server')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-outcome.feature', { auditEventId: auditEventId, baseUrl: baseUrl })

  Scenario: TC-AUD-006 | REQ-GEN-001 captured audit-event-read.json exists for HL7 Validator
    * if (!auditEventAvailable) karate.log('TC-AUD-006: SKIP — no AuditEvent captured, server returned no resources')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-capture.feature', { auditEventId: auditEventId, baseUrl: baseUrl })

  Scenario: TC-AUD-007 | REQ-GEN-002b meta.versionId is present
    * if (!auditEventAvailable) karate.log('TC-AUD-007: SKIP — no AuditEvent resources on server')
    * if (auditEventAvailable) karate.call('classpath:audit/assert-audit-version.feature', { auditEventId: auditEventId, baseUrl: baseUrl })
