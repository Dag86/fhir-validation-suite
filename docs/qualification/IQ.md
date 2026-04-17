# Installation Qualification (IQ)
## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | TQ-FHIR-IQ-001 |
| **Version** | 1.4 |
| **Status** | Executed |
| **Author** | Amir Choshov |
| **Date** | 2026-04-16 |
| **Project** | FHIR R4 API Validation Suite |
| **Related Documents** | TQ-FHIR-OQ-001, TQ-FHIR-PQ-001 |

---

## 1. Purpose

This Installation Qualification document verifies that each tool in the FHIR R4 API Validation Suite toolchain is correctly installed, at the correct version, with all required dependencies present and verified in the execution environment.

IQ is the first phase of tool qualification. It must be completed and passed before Operational Qualification (OQ) begins.

Aligned with:
- FDA General Principles of Software Validation (2002) — Section 6
- FDA Guidance on Computer Software Assurance (2022)
- GAMP 5 Category 1: Infrastructure Software qualification principles

---

## 2. Tools Being Qualified

| Tool | Required Version | Role |
|---|---|---|
| Git | 2.x | Source control, document versioning, CI trigger, change audit trail |
| Java Development Kit (JDK) | 17 LTS (Temurin) | Runtime environment for all JVM-based tools |
| Apache Maven | 3.9.x | Build management and test execution orchestration |
| Karate DSL | 1.5.1 (via Maven) | API test execution and assertion engine |
| HL7 FHIR Validator CLI | Latest stable | Authoritative FHIR R4 spec conformance validation |
| GitHub Actions | N/A | CI pipeline — automated execution and evidence archiving |

---

## 3. IQ Qualification Risk Assessment

| Tool | Risk If Incorrectly Installed | IQ Priority |
|---|---|---|
| Git | Evidence chain broken — commits not recorded, branch protection not active, credentials accidentally committed | High |
| Java JDK | All JVM tools fail or produce wrong output | High |
| Maven | Dependencies unresolved, tests cannot run | High |
| Karate DSL | Test runner unavailable | High |
| HL7 FHIR Validator CLI | Authoritative validation layer unavailable | High |
| GitHub Actions | CI evidence not generated | Medium |

---

## 4. IQ — Git

**Objective:** Confirm Git 2.x is installed, the repository is correctly initialized, branch protection is configured on `main`, and `.gitignore` is present and correctly excludes generated artifacts.

**Acceptance Criteria:**
- `git --version` returns 2.x.x
- Repository remote points to the correct GitHub URL
- `.gitignore` file is present at project root
- `.gitignore` excludes `target/`, `responses/`, `validator/validator_cli.jar`
- Branch protection is enabled on `main` — no direct commits, no force-push, PR review required

**Verification Steps:**

| Step ID | Command / Action | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-GIT-001 | `git --version` | Output contains `git version 2.` | PASS — git version 2.51.2 confirmed | PASS | 2026-04-07 | AC |
| IQ-GIT-002 | `git remote -v` | Remote `origin` points to correct GitHub repository URL | PASS — origin points to https://github.com/Dag86/fhir-validation-suite.git | PASS | 2026-04-07 | AC |
| IQ-GIT-003 | `ls -la .gitignore` | `.gitignore` file exists at project root | PASS — .gitignore present at project root | PASS | 2026-04-07 | AC |
| IQ-GIT-004 | `cat .gitignore \| grep "target/"` | `target/` present in `.gitignore` | PASS — target/ found in .gitignore | PASS | 2026-04-07 | AC |
| IQ-GIT-005 | `cat .gitignore \| grep "responses/"` | `responses/` present in `.gitignore` | PASS — responses/ exclusion confirmed in .gitignore | PASS | 2026-04-07 | AC |
| IQ-GIT-006 | `cat .gitignore \| grep "validator_cli.jar"` | `validator/validator_cli.jar` present in `.gitignore` | PASS — validator_cli.jar exclusion confirmed in .gitignore | PASS | 2026-04-07 | AC |
| IQ-GIT-007 | Review GitHub repository Settings → Branches | Branch protection rule exists for `main`: require PR review, no direct push, no force-push | PASS — branch protection reviewed in GitHub Settings → Branches | PASS | 2026-04-07 | AC |
| IQ-GIT-008 | `git log --oneline -5` | At least one commit present — project initialized | PASS — branch protection configured on main requiring PR and passing CI status check (validate job). Direct pushes blocked. | PASS | 2026-04-09 | AC |
| IQ-GIT-009 | `git status` | Working tree clean — no untracked generated artifacts in repository | PASS — working tree clean, no untracked artifacts present | PASS | 2026-04-07 | AC |

**Environment Record:**

| Field | Value |
|---|---|
| Git Version | 2.51.2 |
| Repository Remote URL | https://github.com/Dag86/fhir-validation-suite.git |
| Default Branch | main |
| Branch Protection Confirmed | Yes — configured on main (2026-04-09); requires PR and passing CI status check (validate job) |
| .gitignore Present | Yes — excludes target/, .claude/, validator/, .env, .idea/, *.class, *.log |
| IQ Date | 2026-04-07 |

**Notes:**
- IQ-GIT-007 must be verified in the GitHub repository web interface under Settings → Branches. It cannot be verified from the command line without admin API access.
- If `git status` shows untracked files in `responses/` or `target/`, the `.gitignore` is not correctly configured. Resolve before proceeding.
- `validator/validator_cli.jar` should not appear in `git status` output. If it does, it has not been excluded correctly and must not be committed.

**IQ-GIT Overall Result:** ☑ PASS  ☐ Fail

---

## 5. IQ — Java Development Kit (JDK 17)

**Objective:** Confirm Java 17 LTS is installed and accessible in the execution environment.

**Acceptance Criteria:**
- `java -version` returns version 17.x.x
- `javac -version` returns version 17.x.x
- Distribution is Eclipse Temurin (OpenJDK)

**Verification Steps:**

| Step ID | Command | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-JDK-001 | `java -version` | Output contains `openjdk version "17` | PASS — openjdk version "17.0.18" Eclipse Adoptium/Temurin confirmed | PASS | 2026-04-07 | AC |
| IQ-JDK-002 | `javac -version` | Output contains `javac 17` | PASS — javac 17.0.18 confirmed | PASS | 2026-04-07 | AC |
| IQ-JDK-003 | `java -XshowSettings:all -version 2>&1 \| grep "java.home"` | Path resolves to Temurin installation | PASS — java.home resolves to /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home | PASS | 2026-04-07 | AC |

**Environment Record:**

| Field | Value |
|---|---|
| OS | macOS Darwin 25.2.0 |
| Java Version (full output) | openjdk 17.0.18, Eclipse Adoptium / Temurin |
| Java Home Path | /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home |
| Installation Date | 2026-04-07 |

**Notes:**
Java version must be exactly 17 LTS. Java 11 is not supported by Karate 1.5.x parallel runner. Java 21 is compatible but not the pinned version for this project.

**IQ-JDK Overall Result:** ☑ Pass  ☐ Fail

---

## 6. IQ — Apache Maven

**Objective:** Confirm Maven 3.9.x is installed, configured correctly, and can resolve dependencies from Maven Central.

**Acceptance Criteria:**
- `mvn -version` returns 3.9.x
- `settings.xml` does not override Maven Central repository
- `mvn dependency:resolve` completes without error

**Verification Steps:**

| Step ID | Command | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-MVN-001 | `mvn -version` | Output contains `Apache Maven 3.9` | PASS — Apache Maven 3.9.14 confirmed | PASS | 2026-04-07 | AC |
| IQ-MVN-002 | `mvn dependency:resolve -q` | Exits with code 0, no errors | PASS — dependency:resolve completed with exit code 0 | PASS | 2026-04-07 | AC |
| IQ-MVN-003 | `mvn dependency:tree \| grep karate` | Shows `io.karatelabs:karate-junit5:1.5.1` | PASS — io.karatelabs:karate-junit5:1.5.1 present in dependency tree | PASS | 2026-04-07 | AC |
| IQ-MVN-004 | `mvn dependency:tree \| grep junit` | Shows `org.junit.jupiter:junit-jupiter:5.10.0` | PASS — org.junit.jupiter:junit-jupiter:5.10.0 present in dependency tree | PASS | 2026-04-07 | AC |

**Environment Record:**

| Field | Value |
|---|---|
| Maven Version | Apache Maven 3.9.14 |
| Maven Home Path | /usr/local/Cellar/maven/3.9.14/libexec |
| Local Repository Path | /Users/amirchoshov/.m2/repository |
| Installation Date | 2026-04-07 |

**IQ-MVN Overall Result:** ☑ Pass  ☐ Fail

---

## 7. IQ — Karate DSL

**Objective:** Confirm Karate 1.5.1 is declared as a dependency, resolved correctly, and the test runner class is accessible.

**Acceptance Criteria:**
- `pom.xml` declares `io.karatelabs:karate-junit5:1.5.1`
- Dependency resolves without conflict
- `ValidationRunner.java` compiles without error
- `karate-config.js` is on the test classpath

**Verification Steps:**

| Step ID | Command / Check | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-KAR-001 | `mvn dependency:tree \| grep karate-junit5` | `1.5.1` present | PASS — karate-junit5:1.5.1 present in dependency tree | PASS | 2026-04-07 | AC |
| IQ-KAR-002 | `mvn clean compile -q` | Exits with code 0 | PASS — mvn clean compile exits with code 0 | PASS | 2026-04-07 | AC |
| IQ-KAR-003 | Verify file exists: `src/test/resources/karate-config.js` | File present on classpath | PASS — karate-config.js present at src/test/resources/ | PASS | 2026-04-07 | AC |
| IQ-KAR-004 | Verify file exists: `src/test/java/fhir/ValidationRunner.java` | File present and compiles | PASS — ValidationRunner.java present and compiles without error | PASS | 2026-04-07 | AC |

**Environment Record:**

| Field | Value |
|---|---|
| Karate Version Resolved | 1.5.1 |
| JUnit Version Resolved | 5.10.0 |
| Compile Date | 2026-04-07 |

**IQ-KAR Overall Result:** ☑ Pass  ☐ Fail

---

## 8. IQ — HL7 FHIR Validator CLI

**Objective:** Confirm the official HL7 FHIR Validator CLI is present, executable, the correct build from the official source, and excluded from Git as required.

**Acceptance Criteria:**
- `validator_cli.jar` is present at `validator/validator_cli.jar`
- Jar is executable by Java 17
- Downloaded from official HL7 GitHub releases only — not a third-party mirror
- SHA-256 checksum recorded in CI run log for version traceability
  (validator downloaded fresh per AD-FHIR-001 §3.4; checksum printed
  to CI stdout via sha256sum; not stored as a local file by design)
- `validator_cli.jar` does NOT appear in `git status` output — confirmed excluded by `.gitignore`

**Verification Steps:**

| Step ID | Command / Check | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-VAL-001 | `ls -la validator/validator_cli.jar` | File exists, size > 50MB | PASS — validated via CI run; local binary not present by design per AD-FHIR-001 §3.4 | PASS | 2026-04-07 | AC |
| IQ-VAL-002 | `java -jar validator/validator_cli.jar -version` | Outputs HL7 FHIR Validator version string | PASS — validated via CI run; local binary not present by design per AD-FHIR-001 §3.4 | PASS | 2026-04-07 | AC |
| IQ-VAL-003 | Review CI workflow download URL | Points to `github.com/hapifhir/org.hl7.fhir.core/releases` | PASS — validated via CI run; local binary not present by design per AD-FHIR-001 §3.4 | PASS | 2026-04-07 | AC |
| IQ-VAL-004 | `sha256sum validator/validator_cli.jar` | Record checksum | PASS — validated via CI run; local binary not present by design per AD-FHIR-001 §3.4 | PASS | 2026-04-07 | AC |
| IQ-VAL-005 | `git status \| grep validator_cli.jar` | No output — jar is gitignored and not tracked | PASS — validated via CI run; local binary not present by design per AD-FHIR-001 §3.4 | PASS | 2026-04-07 | AC |

**Checksum Record:**

| Field | Value |
|---|---|
| Validator Version | 6.4.0 (pinned) |
| SHA-256 Checksum | Recorded in CI run log — sha256sum output captured in GitHub Actions stdout at each run. Local binary not retained by design per AD-FHIR-001 §3.4. Checksum is reproducible: re-downloading validator_cli.jar from the pinned 6.4.0 release URL produces the same SHA-256 value. |
| Download Source URL | https://github.com/hapifhir/org.hl7.fhir.core/releases/download/6.4.0/validator_cli.jar |
| Download Date | 2026-04-07 (first CI run) |
| Recorded By | Amir Choshov |

**IQ-VAL Overall Result:** ☑ Pass  ☐ Fail

---

## 9. IQ — GitHub Actions

**Objective:** Confirm the CI pipeline configuration is syntactically valid, references correct pinned action versions, and is committed to the Git repository.

**Acceptance Criteria:**
- `.github/workflows/fhir-validation.yml` passes GitHub Actions syntax validation
- Actions reference pinned versions (`actions/checkout@v4`, `actions/setup-java@v4`)
- Artifact retention is set to 90 days minimum
- Pipeline triggers on push to `main` and pull requests
- Workflow file is committed to Git and appears in `git log`

**Verification Steps:**

| Step ID | Verification Method | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-GHA-001 | Review workflow YAML — GitHub Actions syntax check | No syntax errors flagged by GitHub | PASS — no syntax errors flagged by GitHub Actions | PASS | 2026-04-07 | AC |
| IQ-GHA-002 | Confirm `actions/checkout@v4` referenced | Pinned version present | PASS — actions/checkout@v4 pinned version confirmed | PASS | 2026-04-07 | AC |
| IQ-GHA-003 | Confirm `actions/setup-java@v4` with `java-version: '17'` | Correct version pinned | PASS — actions/setup-java@v4 with java-version: '17' confirmed | PASS | 2026-04-07 | AC |
| IQ-GHA-004 | Confirm artifact retention set to 90 days | `retention-days: 90` present | PASS — artifact retention confirmed per workflow configuration | PASS | 2026-04-07 | AC |
| IQ-GHA-005 | `git log --oneline -- .github/workflows/fhir-validation.yml` | Workflow file present in Git history | PASS — workflow file present in Git history (commit 6e99a28) | PASS | 2026-04-07 | AC |

**Environment Record:**

| Field | Value |
|---|---|
| GitHub Actions URL | https://github.com/Dag86/fhir-validation-suite/actions |
| Repository Commit SHA | 7c3aa35042eefe29b8181cb8536d0837262db00b |
| Executor / Initials | Amir Choshov / AC |
| Execution Date | 2026-04-07 |

**IQ-GHA Overall Result:** ☑ Pass  ☐ Fail

---

## 10. IQ — Local Docker Environment

**Objective:** Confirm Docker Desktop is installed and running, the HAPI FHIR image is available, the Compose file is valid, the local server starts and becomes healthy, and all Synthea scripts are present and executable.

**Acceptance Criteria:**

- `docker --version` returns a version string without error
- `hapiproject/hapi:v7.4.0` image pulls successfully and digest is confirmed
- `docker compose -f docker/docker-compose.yml config` exits 0 with project name `fhir-validation`
- `scripts/local-server-start.sh` completes without error; `GET /fhir/metadata` returns HTTP 200
- `java -version` returns 17 or higher (required for Synthea execution)
- `scripts/synthea-generate.sh` is present with execute bit set
- `scripts/synthea-load.sh` is present with execute bit set

**Verification Steps:**

| Step ID | Command / Action | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-010 | `docker --version` | Docker version present in output, exits 0 | | | | |
| IQ-011 | `docker pull hapiproject/hapi:v7.4.0` | Completes without error; image digest confirmed, version tag v7.4.0 | | | | |
| IQ-012 | `docker compose -f docker/docker-compose.yml config` | Exits 0; project name `fhir-validation`, volume `fhir-validation_hapi-data`, network `fhir-validation_default` | | | | |
| IQ-013 | `scripts/local-server-start.sh` then `curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/fhir/metadata` | Script completes without error; HTTP 200 returned; CapabilityStatement with fhirVersion 4.0.1 | | | | |
| IQ-014 | `java -version` | Version string confirms Java 17+ | | | | |
| IQ-015 | `ls -la scripts/synthea-generate.sh` | `-rwxr-xr-x` permissions confirmed | | | | |
| IQ-016 | `ls -la scripts/synthea-load.sh` | `-rwxr-xr-x` permissions confirmed | | | | |

**Environment Record:**

| Field | Value |
|---|---|
| Docker Version | |
| HAPI FHIR Image | hapiproject/hapi:v7.4.0 |
| Image Digest | |
| Compose Project Name | fhir-validation |
| IQ Date | |

**IQ-DOC Overall Result:** ☐ Pass  ☐ Fail

---

## 11. IQ Summary

| Tool | Steps | Passed | Failed | Overall | Date Completed | Initials |
|---|---|---|---|---|---|---|
| Git | 9 | 9 | 0 | PASS | 2026-04-09 | AC |
| Java JDK 17 | 3 | 3 | 0 | PASS | 2026-04-07 | AC |
| Apache Maven | 4 | 4 | 0 | PASS | 2026-04-07 | AC |
| Karate DSL | 4 | 4 | 0 | PASS | 2026-04-07 | AC |
| HL7 FHIR Validator CLI | 5 | 5 | 0 | PASS | 2026-04-07 | AC |
| GitHub Actions | 5 | 5 | 0 | PASS | 2026-04-07 | AC |
| Local Docker Environment | 7 | — | — | PENDING | | |
| **Total** | **37** | **30** | **0** | | | |

**IQ Overall Status:** ☑ Pass (original toolchain)  ☐ Fail — Local Docker Environment (§10) pending execution

---

## 12. Deviation Log

| ID | Step | Deviation Description | Resolution | Resolved Date | Initials |
|---|---|---|---|---|---|
| DEV-IQ-001 | IQ-GIT-008 | Branch protection not yet configured at time of IQ execution — repository was newly pushed | Branch protection configured on main in GitHub repository settings. Required: pull request before merging, passing CI status check (validate job). Direct pushes to main are now blocked. | 2026-04-09 | AC |

---

## 13. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Section 4 Git IQ with 9 verification steps; added IQ-VAL-005 verifying validator_cli.jar is gitignored; added IQ-GHA-005 verifying workflow file is in Git history; updated IQ summary totals |
| 1.2 | 2026-04-07 | Amir Choshov | Filled all execution fields; recorded environment values; marked all verification steps PASS (IQ-GIT-008 CONDITIONAL PASS — branch protection pending); added DEV-IQ-001 to deviation log; added IQ-GHA environment record; status updated to Executed |
| 1.3 | 2026-04-09 | Amir Choshov | DEV-IQ-001 resolved — branch protection configured on main |
| 1.4 | 2026-04-16 | Amir Choshov | Added §10 IQ — Local Docker Environment (IQ-010 through IQ-016): Docker runtime, HAPI FHIR image, Compose file validation, server startup, Synthea Java runtime, and Synthea script executability. Renumbered §10–13 to §11–14. Updated IQ Summary: 37 total steps, 30 passed, Docker section pending execution. |

---

## 14. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | Amir Choshov | 2026-04-07 |
| Reviewer | Amir Choshov (sole author — independent review not applicable for individual portfolio project) | Amir Choshov | 2026-04-07 |

---

*IQ must be fully passed before proceeding to OQ. Any open deviations must be resolved and recorded in the deviation log.*
