@ignore
Feature: Capture Response to Disk
  # Reusable helper: call with { responseBody: <object>, filePath: <string> }
  # karate.write() serializes the object as valid JSON (colon-separated, not map notation)
  # NOTE: Under Maven, karate.write() resolves filePath relative to target/ (the build output
  # directory). Captured files land at target/responses/{ResourceType}/{filename}.json.
  # target/ is gitignored — see .gitignore line 2.

  Scenario:
    * karate.write(responseBody, filePath)
    * karate.log('Captured response to:', filePath)
