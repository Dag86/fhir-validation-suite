# Installation Qualification (IQ)
## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | TQ-FHIR-IQ-001 |
| **Version** | 1.1 |
| **Status** | Draft |
| **Author** | Amir Choshov |
| **Date** | 2026-03-30 |
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
| IQ-GIT-001 | `git --version` | Output contains `git version 2.` | | | | |
| IQ-GIT-002 | `git remote -v` | Remote `origin` points to correct GitHub repository URL | | | | |
| IQ-GIT-003 | `ls -la .gitignore` | `.gitignore` file exists at project root | | | | |
| IQ-GIT-004 | `cat .gitignore \| grep "target/"` | `target/` present in `.gitignore` | | | | |
| IQ-GIT-005 | `cat .gitignore \| grep "responses/"` | `responses/` present in `.gitignore` | | | | |
| IQ-GIT-006 | `cat .gitignore \| grep "validator_cli.jar"` | `validator/validator_cli.jar` present in `.gitignore` | | | | |
| IQ-GIT-007 | Review GitHub repository Settings → Branches | Branch protection rule exists for `main`: require PR review, no direct push, no force-push | | | | |
| IQ-GIT-008 | `git log --oneline -5` | At least one commit present — project initialized | | | | |
| IQ-GIT-009 | `git status` | Working tree clean — no untracked generated artifacts in repository | | | | |

**Environment Record:**

| Field | Value |
|---|---|
| Git Version | |
| Repository Remote URL | |
| Default Branch | |
| Branch Protection Confirmed | Yes / No |
| .gitignore Present | Yes / No |
| IQ Date | |

**Notes:**
- IQ-GIT-007 must be verified in the GitHub repository web interface under Settings → Branches. It cannot be verified from the command line without admin API access.
- If `git status` shows untracked files in `responses/` or `target/`, the `.gitignore` is not correctly configured. Resolve before proceeding.
- `validator/validator_cli.jar` should not appear in `git status` output. If it does, it has not been excluded correctly and must not be committed.

**IQ-GIT Overall Result:** ☐ Pass  ☐ Fail

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
| IQ-JDK-001 | `java -version` | Output contains `openjdk version "17` | | | | |
| IQ-JDK-002 | `javac -version` | Output contains `javac 17` | | | | |
| IQ-JDK-003 | `java -XshowSettings:all -version 2>&1 \| grep "java.home"` | Path resolves to Temurin installation | | | | |

**Environment Record:**

| Field | Value |
|---|---|
| OS | |
| Java Version (full output) | |
| Java Home Path | |
| Installation Date | |

**Notes:**
Java version must be exactly 17 LTS. Java 11 is not supported by Karate 1.5.x parallel runner. Java 21 is compatible but not the pinned version for this project.

**IQ-JDK Overall Result:** ☐ Pass  ☐ Fail

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
| IQ-MVN-001 | `mvn -version` | Output contains `Apache Maven 3.9` | | | | |
| IQ-MVN-002 | `mvn dependency:resolve -q` | Exits with code 0, no errors | | | | |
| IQ-MVN-003 | `mvn dependency:tree \| grep karate` | Shows `io.karatelabs:karate-junit5:1.5.1` | | | | |
| IQ-MVN-004 | `mvn dependency:tree \| grep junit` | Shows `org.junit.jupiter:junit-jupiter:5.10.0` | | | | |

**Environment Record:**

| Field | Value |
|---|---|
| Maven Version | |
| Maven Home Path | |
| Local Repository Path | |
| Installation Date | |

**IQ-MVN Overall Result:** ☐ Pass  ☐ Fail

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
| IQ-KAR-001 | `mvn dependency:tree \| grep karate-junit5` | `1.5.1` present | | | | |
| IQ-KAR-002 | `mvn clean compile -q` | Exits with code 0 | | | | |
| IQ-KAR-003 | Verify file exists: `src/test/resources/karate-config.js` | File present on classpath | | | | |
| IQ-KAR-004 | Verify file exists: `src/test/java/fhir/ValidationRunner.java` | File present and compiles | | | | |

**Environment Record:**

| Field | Value |
|---|---|
| Karate Version Resolved | |
| JUnit Version Resolved | |
| Compile Date | |

**IQ-KAR Overall Result:** ☐ Pass  ☐ Fail

---

## 8. IQ — HL7 FHIR Validator CLI

**Objective:** Confirm the official HL7 FHIR Validator CLI is present, executable, the correct build from the official source, and excluded from Git as required.

**Acceptance Criteria:**
- `validator_cli.jar` is present at `validator/validator_cli.jar`
- Jar is executable by Java 17
- Downloaded from official HL7 GitHub releases only — not a third-party mirror
- SHA-256 checksum recorded for version traceability
- `validator_cli.jar` does NOT appear in `git status` output — confirmed excluded by `.gitignore`

**Verification Steps:**

| Step ID | Command / Check | Expected Result | Actual Result | Pass/Fail | Date | Initials |
|---|---|---|---|---|---|---|
| IQ-VAL-001 | `ls -la validator/validator_cli.jar` | File exists, size > 50MB | | | | |
| IQ-VAL-002 | `java -jar validator/validator_cli.jar -version` | Outputs HL7 FHIR Validator version string | | | | |
| IQ-VAL-003 | Review CI workflow download URL | Points to `github.com/hapifhir/org.hl7.fhir.core/releases` | | | | |
| IQ-VAL-004 | `sha256sum validator/validator_cli.jar` | Record checksum | | | | |
| IQ-VAL-005 | `git status \| grep validator_cli.jar` | No output — jar is gitignored and not tracked | | | | |

**Checksum Record:**

| Field | Value |
|---|---|
| Validator Version | |
| SHA-256 Checksum | |
| Download Source URL | |
| Download Date | |
| Recorded By | |

**IQ-VAL Overall Result:** ☐ Pass  ☐ Fail

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
| IQ-GHA-001 | Review workflow YAML — GitHub Actions syntax check | No syntax errors flagged by GitHub | | | | |
| IQ-GHA-002 | Confirm `actions/checkout@v4` referenced | Pinned version present | | | | |
| IQ-GHA-003 | Confirm `actions/setup-java@v4` with `java-version: '17'` | Correct version pinned | | | | |
| IQ-GHA-004 | Confirm artifact retention set to 90 days | `retention-days: 90` present | | | | |
| IQ-GHA-005 | `git log --oneline -- .github/workflows/fhir-validation.yml` | Workflow file present in Git history | | | | |

**IQ-GHA Overall Result:** ☐ Pass  ☐ Fail

---

## 10. IQ Summary

| Tool | Steps | Passed | Failed | Overall | Date Completed | Initials |
|---|---|---|---|---|---|---|
| Git | 9 | | | | | |
| Java JDK 17 | 3 | | | | | |
| Apache Maven | 4 | | | | | |
| Karate DSL | 4 | | | | | |
| HL7 FHIR Validator CLI | 5 | | | | | |
| GitHub Actions | 5 | | | | | |
| **Total** | **30** | | | | | |

**IQ Overall Status:** ☐ Pass  ☐ Fail — Proceed to OQ

---

## 11. Deviation Log

| ID | Step | Deviation Description | Resolution | Resolved Date | Initials |
|---|---|---|---|---|---|
| | | | | | |

---

## 12. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Section 4 Git IQ with 9 verification steps; added IQ-VAL-005 verifying validator_cli.jar is gitignored; added IQ-GHA-005 verifying workflow file is in Git history; updated IQ summary totals |

---

## 13. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | | |
| Reviewer | | | |

---

*IQ must be fully passed before proceeding to OQ. Any open deviations must be resolved and recorded in the deviation log.*