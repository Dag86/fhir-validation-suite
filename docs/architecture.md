# Architecture Document

## FHIR R4 API Validation Suite

---

| Field | Detail |
|---|---|
| **Document ID** | AD-FHIR-001 |
| **Version** | 1.3 |
| **Status** | Approved |
| **Author** | Amir Choshov |
| **Date** | 2026-04-16 |
| **Project** | FHIR R4 API Validation Suite |

---

## 1. Purpose

This document describes the technical architecture of the FHIR R4 API Validation Suite. It defines the component structure, data flow, tool stack, directory layout, and design decisions that govern how the framework is built and operated.

This document provides the technical foundation for the IQ/OQ/PQ Tool Qualification and Test Plan. Any change to the framework architecture must be reflected in a revision to this document.

---

## 2. Architectural Overview

The FHIR R4 API Validation Suite is a three-layer validation framework:

```text
┌─────────────────────────────────────────────────────┐
│                  Layer 1: Test Execution             │
│                                                      │
│   Karate DSL Feature Files                          │
│   Clinical assertions — required fields,            │
│   value sets, formats, error structures,            │
│   audit metadata, cross-resource references         │
└─────────────────────┬───────────────────────────────┘
                      │ HTTP Request / Response
                      ▼
┌─────────────────────────────────────────────────────┐
│              Target: FHIR R4 Server                  │
│         https://hapi.fhir.org/baseR4                │
│         (configurable via karate-config.js)         │
└─────────────────────┬───────────────────────────────┘
                      │ Response Body (JSON)
                      ▼
┌─────────────────────────────────────────────────────┐
│             Layer 2: Schema Conformance              │
│                                                      │
│   HL7 FHIR Validator CLI                            │
│   Validates response against official               │
│   R4 StructureDefinitions — authoritative           │
│   spec conformance evidence                         │
└─────────────────────┬───────────────────────────────┘
                      │ Validation Results
                      ▼
┌─────────────────────────────────────────────────────┐
│              Layer 3: Regulatory Evidence            │
│                                                      │
│   Traceability Matrix                               │
│   Requirements → Test Cases → Results               │
│   IEC 62304 Class per requirement                   │
│   ISO 14971 Risk per requirement                    │
│   Gap Analysis report                               │
│   Git commit SHA linking evidence to source state   │
└─────────────────────────────────────────────────────┘
```

---

## 3. Component Descriptions

### 3.1 Git Version Control

**Role:** Source control, document versioning, change audit trail, and CI pipeline trigger.

**Responsibilities:**

- Maintains complete, immutable history of all source code and documentation changes
- Provides author identity, timestamp, and change description for every commit
- Triggers GitHub Actions CI pipeline on push and pull request events
- Branch protection on `main` enforces pull request review before any change is merged
- Commit SHA links each CI pipeline run to the exact code and document state that produced it

**Why Git matters regulatorily:**
21 CFR Part 820.40 requires document controls that ensure changes are reviewed, approved, and traceable. Git's commit history, combined with GitHub pull request reviews, satisfies these requirements. The commit SHA recorded in every pipeline artifact provides an unbroken chain of evidence from requirement to test case to execution result to a specific, retrievable version of the framework.

**Branch strategy:**

| Branch | Purpose | Protection Rules |
|---|---|---|
| `main` | Production-quality, approved state | No direct commits, no force-push, PR review required |
| `feature/*` | Development branches | No restrictions — merged to `main` via PR |

**Commit convention:**
Commits to `main` via pull request should include a meaningful description. For validation purposes, commits that change test cases or documentation should reference the affected requirement ID (e.g., `Add negative path tests for REQ-PAT-007`).

---

### 3.2 Karate DSL Test Suite

**Role:** Primary test execution engine. Sends HTTP requests to the FHIR server and asserts that responses conform to clinical and specification requirements.

**Why Karate:**

| Criterion | Rationale |
|---|---|
| Purpose-built for API contract testing | Native JSON/XML handling, built-in schema matching, no step definitions required |
| Enterprise healthcare adoption | Widely used in Java-based healthcare organizations — Epic, Cerner ecosystem shops |
| Readable by non-developers | `.feature` file syntax readable by regulatory affairs and QA managers |
| Audit-friendly reports | HTML reports generated out of the box — suitable for validation evidence packages |
| Maven integration | Fits naturally into Java project structure dominant in healthcare enterprise |
| Parallel execution | Built-in parallel runner reduces CI execution time without configuration |

**Alternatives considered:**

| Tool | Reason Not Selected |
|---|---|
| Postman/Newman | Less code-like, weaker schema validation, harder to version-control complex suites |
| REST Assured | Requires more Java boilerplate, less readable by non-technical reviewers |
| Playwright API mode | Strong choice but TypeScript stack less common in regulated healthcare enterprise |
| Robot Framework | Valid for regulated environments but adds Python dependency, less natural for FHIR JSON |

---

### 3.3 Apache Maven

**Role:** Build management, dependency resolution, and test execution orchestration.

**Responsibilities:**

- Declares and resolves Karate dependency via `pom.xml`
- Provides `mvn test` command consumed by GitHub Actions
- Manages Java classpath and test runner configuration
- Outputs Surefire test reports consumed by CI

**Why Maven over Gradle:**
Maven's declarative XML configuration is more auditable than Gradle's imperative Groovy/Kotlin DSL — a minor but relevant consideration in regulated environments where configuration files are reviewed artifacts.

---

### 3.4 HL7 FHIR Validator CLI

**Role:** Authoritative specification conformance validation layer.

**Responsibilities:**

- Receives FHIR resource JSON files captured from test responses
- Validates each resource against the official HL7 R4 StructureDefinitions
- Produces structured validation output indicating conformance status, errors, and warnings
- Provides specification-authoritative evidence distinct from Karate's assertion-based checks

**Why this matters regulatorily:**
Karate assertions encode the engineer's interpretation of the spec. The HL7 Validator encodes the spec itself. When both agree a resource is valid, the evidence is defensible. When they disagree, the discrepancy is a finding worth documenting.

**Source:** <https://github.com/hapifhir/org.hl7.fhir.core> — official HL7 tooling

**Note on version management:** The HL7 FHIR Validator is pinned to version 6.4.0 in the CI workflow. Pinning is required per change control principles — a floating version would introduce uncontrolled changes to validation behavior between runs. The `validator_cli.jar` is a large binary (100MB+) and is NOT committed to the Git repository. It is downloaded fresh in every CI pipeline run from the pinned 6.4.0 release URL. The `.gitignore` file excludes `validator/validator_cli.jar` from source control. The SHA-256 checksum of the downloaded binary is recorded during IQ qualification for version traceability.

---

### 3.5 GitHub Actions CI Pipeline

**Role:** Automated test execution on every code push.

**Responsibilities:**

- Triggers on push and pull request to `main` branch
- Installs Java 17 and Maven
- Downloads HL7 FHIR Validator CLI from official source
- Executes `mvn test` to run Karate suite
- Invokes FHIR Validator against captured response files
- Publishes HTML test reports as pipeline artifacts
- Archives timestamped execution evidence with Git commit SHA

**Why CI matters regulatorily:**
21 CFR Part 820 requires that design verification be repeatable and documented. A CI pipeline that runs on every commit produces timestamped, version-controlled validation evidence automatically. Manual test execution produces evidence only when someone remembers to run it.

---

### 3.6 CapabilityStatement Pre-Check

**Role:** Server capability discovery before test execution.

**Responsibilities:**

- Queries `GET /metadata` before any resource tests run
- Parses the CapabilityStatement to determine which resources the server supports
- Conditionally skips test suites for unsupported resources rather than failing them
- TC-CAP-002 asserts `fhirVersion` matches the regex `4\.0\.[0-9]+`, accepting any valid R4 patch version (4.0.0, 4.0.1, etc.) for server-agnostic portability

**Why this matters:**
A test that fails because the server doesn't support the resource is not a finding — it's a scope mismatch. The CapabilityStatement pre-check prevents false failures and makes the suite genuinely server-agnostic.

---

### 3.7 Schema Definition Files

The `schemas/` directory is reserved for future external schema definition files. In the current implementation, all FHIR resource schema validation is performed inline using Karate's native `match` assertions within each feature file. No external schema files are used.

The `schemas/.gitkeep` placeholder file maintains the directory in Git version control pending future schema file additions.

---

### 3.8 Multi-Server Execution

The suite is designed to execute against any FHIR R4 server via the `-DbaseUrl` system property. The suite has been verified against two servers:

| Server | URL | Result |
|---|---|---|
| HAPI FHIR sandbox | hapi.fhir.org/baseR4 | 80/80 PASS |
| SMART Health IT | launch.smarthealthit.org/v/r4/fhir | 73/80 — 7 conformance findings |

SMART Health IT conformance findings (correctly detected by the suite):

- ETag header absent on 4 resource types (non-conformant per FHIR R4 Section 3.1.0.2)
- Content-Type returns `application/json` instead of `application/fhir+json` on `/metadata` (non-conformant)
- `_total` parameter ignored — `total` absent from searchset Bundle responses (non-conformant)
- No Practitioner resources available on server (environmental — not a conformance defect)

All findings represent the suite correctly differentiating conformant from non-conformant server behavior. They do not indicate suite defects.

---

### 3.9 Local Test Environment

**Role:** Fully controlled, reproducible local execution target replacing dependency on the public HAPI sandbox.

**Components:**

| Component | Detail |
|---|---|
| Container runtime | Docker Desktop |
| FHIR server image | hapiproject/hapi:v7.4.0 |
| Data persistence | Named Docker volume: `fhir-validation_hapi-data` |
| Synthetic data generator | Synthea 3.2.0 |
| Generation parameters | Seed 42, population 50, state: Massachusetts |
| Data format | FHIR R4 transaction bundles (JSON) |
| Load mechanism | POST to `http://localhost:8080/fhir` via `scripts/synthea-load.sh` |

**Rationale:**
The public HAPI sandbox (hapi.fhir.org/baseR4) is an uncontrolled environment subject to outages, data mutation by other users, and schema changes outside this project's change control. A local server with a fixed Synthea seed produces a deterministic, reproducible dataset — satisfying reproducibility requirements for a maintained validated state.

**Environment targeting:**
The suite targets the local server via `-DbaseUrl=http://localhost:8080/fhir` passed as a Maven property. No feature file changes are required to switch between the local server and any other FHIR R4 environment. The server URL is resolved at runtime via `karate-config.js`.

**Supporting scripts:**

| Script | Purpose | Regulatory Rationale |
| --- | --- | --- |
| `scripts/local-server-start.sh` | Starts HAPI FHIR container; polls `/fhir/metadata` until ready | — |
| `scripts/local-server-stop.sh` | Stops and removes the container | — |
| `scripts/synthea-generate.sh` | Downloads Synthea jar if absent; generates 50 patients with seed 42 | — |
| `scripts/synthea-load.sh` | POSTs all generated FHIR bundles to the local server | — |
| Traceability Verification Script | Automated bidirectional REQ↔TC coverage check on every CI run | 21 CFR Part 820.70(i) — automated controls where feasible; prevents undocumented TC additions or requirement gaps from reaching main |

---

## 4. Data Flow

### 4.1 Single Resource Validation Flow

```text
1. Developer commits code and pushes to GitHub
   Git records: author, timestamp, SHA, changed files
         │
         ▼
2. GitHub Actions triggers pipeline
   Pipeline records: run number, commit SHA, trigger event
         │
         ▼
3. Maven executes Karate runner
         │
         ▼
4. Karate reads karate-config.js
   Resolves baseUrl from environment
         │
         ▼
5. CapabilityStatement pre-check
   GET {baseUrl}/metadata
   Parse supported resources
         │
         ▼
6. For each supported resource:
   Karate sends HTTP request
   GET {baseUrl}/{ResourceType}/{id}
         │
         ▼
7. FHIR server returns JSON response
         │
         ▼
8. Karate executes assertions:
   - HTTP status code
   - resourceType field
   - Required fields present
   - Value set conformance
   - Format validation
   - Cross-resource references
   - meta.lastUpdated (Part 11)
         │
         ▼
9. Response body saved to file
   responses/{ResourceType}/{id}.json
         │
         ▼
10. HL7 FHIR Validator CLI invoked
    validator_cli.jar {response file} -version 4.0.1
         │
         ▼
11. Karate HTML report generated
    HL7 Validator output captured
         │
         ▼
12. GitHub Actions archives reports as artifacts
    Artifact name includes run number
    Artifact metadata includes commit SHA
    Timestamped validation evidence linked to exact source state
```

### 4.2 Negative Path Flow

```text
1. Karate sends intentionally invalid request
   (missing required field, malformed JSON,
    invalid ID, wrong resource type)
         │
         ▼
2. FHIR server returns error response
         │
         ▼
3. Karate asserts:
   - Correct HTTP error status (400/404/422)
   - resourceType == "OperationOutcome"
   - issue array present and non-empty
   - issue.severity is valid value
   - issue.code is valid value
         │
         ▼
4. HL7 Validator validates OperationOutcome
   structure for spec conformance
```

---

## 5. Project Directory Structure

```text
fhir-validation-suite/
│
├── .gitignore                             # Excludes generated artifacts from Git
├── .github/
│   └── workflows/
│       └── fhir-validation.yml            # CI pipeline definition
│
├── docs/                                  # Validation documentation — version controlled
│   ├── validation-plan.md                 # VP-FHIR-001
│   ├── requirements-specification.md      # RS-FHIR-001
│   ├── architecture.md                    # AD-FHIR-001 (this document)
│   ├── test-plan.md                       # TP-FHIR-001
│   ├── traceability-matrix.md             # TM-FHIR-001
│   ├── gap-analysis.md                    # GA-FHIR-001
│   ├── validation-summary-report.md       # VA-FHIR-001
│   ├── diagrams/                          # Mermaid architecture and traceability diagrams
│   │   ├── 01-system-context.md
│   │   ├── 02-component-architecture.md
│   │   ├── 03-test-execution-flow.md
│   │   ├── 04-document-dependency.md
│   │   ├── 05-traceability-chain.md
│   │   ├── 06-risk-classification.md
│   │   └── README.md
│   └── qualification/
│       ├── IQ.md                          # Installation Qualification
│       ├── OQ.md                          # Operational Qualification
│       └── PQ.md                          # Performance Qualification
│
├── src/
│   └── test/
│       ├── java/
│       │   └── fhir/
│       │       └── ValidationRunner.java  # JUnit 5 parallel runner
│       └── resources/
│           ├── karate-config.js           # Environment configuration
│           ├── oq/                        # OQ verification feature files
│           │   ├── oq-pass-verification.feature
│           │   ├── oq-fail-verification.feature
│           │   ├── oq-schema-pass.feature
│           │   ├── oq-schema-fail.feature
│           │   └── oq-http-status.feature
│           ├── capability/
│           │   └── capability-check.feature
│           ├── patient/
│           │   └── patient.feature
│           ├── observation/
│           │   ├── observation.feature
│           │   └── assert-value-quantity.feature  # @ignore helper
│           ├── allergy/
│           │   └── allergy.feature
│           ├── medication/
│           │   └── medication.feature
│           ├── diagnostic/
│           │   └── diagnostic-report.feature
│           ├── audit/
│           │   ├── audit-event.feature
│           │   ├── assert-audit-agent.feature     # @ignore helper
│           │   ├── assert-audit-capture.feature   # @ignore helper
│           │   ├── assert-audit-outcome.feature   # @ignore helper
│           │   ├── assert-audit-read.feature      # @ignore helper
│           │   ├── assert-audit-recorded.feature  # @ignore helper
│           │   ├── assert-audit-type.feature      # @ignore helper
│           │   └── assert-audit-version.feature   # @ignore helper
│           ├── bundle/
│           │   └── bundle.feature
│           ├── practitioner/
│           │   └── practitioner.feature
│           └── common/
│               ├── operation-outcome.feature
│               ├── general.feature               # TC-GEN-001
│               └── capture-response.feature      # @ignore helper
│
├── schemas/                               # Reserved for future schema files
│   └── .gitkeep                          # Placeholder — no external schemas in current implementation
│
├── validator/                             # HL7 Validator directory
│   └── .gitkeep                          # Keeps directory in Git; jar excluded by .gitignore
│
├── oq/                                    # OQ test resource files — version controlled
│   ├── valid-patient.json
│   ├── invalid-patient.json
│   └── invalid-date-patient.json
│
├── target/                                # Maven build output — GITIGNORED
│   ├── karate-reports/                    # Generated HTML reports
│   └── responses/                         # Captured FHIR response files (via karate.write())
│                                          # Generated per run, not source artifacts
│
├── README.md                              # Project overview and quick start
├── CLAUDE.md                              # AI-assisted development context
└── pom.xml                                # Maven project definition — version controlled
```

---

## 6. .gitignore Specification

The following `.gitignore` must be present at project root before the first commit. Its presence is verified in IQ-GIT-003.

```gitignore
# Maven build output — generated on every build, not source
target/

# Captured FHIR responses — generated per test run, not source
responses/

# HL7 Validator binary — large binary downloaded fresh in CI
# See Architecture Section 3.4 for validator_cli.jar handling rationale
validator/validator_cli.jar

# Environment files — may contain tokens or credentials
.env
*.env

# IDE and OS artifacts
.idea/
*.iml
.DS_Store
*.class

# Log files
*.log
```

**Critical:** `validator/validator_cli.jar` must never be committed. It is 100MB+ and would bloat the repository. More importantly, a committed binary cannot be verified for integrity the way a freshly downloaded binary with a recorded checksum can. The CI pipeline downloads it fresh on every run from the official HL7 source.

---

## 7. CI Pipeline Architecture

### 7.1 Pipeline Trigger Events

| Event | Action |
|---|---|
| Push to `main` | Full suite execution |
| Pull request to `main` | Full suite execution — must pass before merge allowed |
| Manual trigger | Full suite execution with optional parameter overrides |
| Scheduled (weekly) | Full suite execution against sandbox to detect upstream changes |

### 7.2 Pipeline Stage Sequence

```text
Stage 1: Setup
├── Checkout repository (actions/checkout@v4)
│   Records commit SHA in pipeline metadata
├── Set up Java 17
├── Cache Maven dependencies
└── Download HL7 FHIR Validator CLI from official source
    Record SHA-256 of downloaded binary

Stage 2: Build
└── mvn clean compile

Stage 3: Test Execution
├── Run CapabilityStatement pre-check
├── Execute Karate test suite (mvn test)
└── Capture response files to responses/

Stage 4: Schema Validation
└── Invoke HL7 FHIR Validator against captured responses

Stage 5: Reporting
├── Publish Karate HTML reports as artifacts
│   Artifact name: validation-reports-{run_number}
├── Publish HL7 Validator output as artifacts
└── Echo commit SHA and run number to pipeline log

Stage 6: Status
└── Report pass/fail status on pull request
```

### 7.3 GitHub Actions Workflow Definition

```yaml
name: FHIR R4 Validation Suite

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am UTC
  workflow_dispatch:
    inputs:
      baseUrl:
        description: 'FHIR Server Base URL'
        required: false
        default: 'https://hapi.fhir.org/baseR4'

jobs:
  validate:
    runs-on: ubuntu-22.04

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Record commit SHA
        run: echo "Validation run against commit ${{ github.sha }}"

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: maven

      - name: Download HL7 FHIR Validator
        run: |
          wget -q https://github.com/hapifhir/org.hl7.fhir.core/releases/download/6.4.0/validator_cli.jar \
            -O validator/validator_cli.jar
          echo "Validator SHA-256: $(sha256sum validator/validator_cli.jar)"

      - name: Build project
        run: mvn clean compile -q

      - name: Execute validation suite
        run: |
          mvn test \
            -DbaseUrl=${{ github.event.inputs.baseUrl || 'https://hapi.fhir.org/baseR4' }}

      - name: Run HL7 FHIR Validator
        run: |
          find target/responses -name "*.json" | while read f; do
            java -jar validator/validator_cli.jar "$f" \
              -version 4.0.1 \
              -output "$(dirname $f)/$(basename $f .json)-validation.json"
          done

      - name: Publish test reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: validation-reports-${{ github.run_number }}
          path: |
            target/karate-reports/
            responses/
          retention-days: 90

      - name: Report status
        if: always()
        run: |
          echo "Validation completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
          echo "Run: ${{ github.run_number }}"
          echo "Commit: ${{ github.sha }}"
          echo "Branch: ${{ github.ref_name }}"
```

**Additional CI steps (implemented, not shown in abbreviated YAML above):**

The workflow also requires `permissions: contents: write` at the job level to allow the gh-pages publish step to push to the `gh-pages` branch.

Two additional steps run after the Report status step:

1. **Create index.html redirect** (`if: always()`): Generates an `index.html` file in `target/karate-reports/` containing an HTML redirect to `karate-summary.html`. This ensures the GitHub Pages root URL redirects visitors to the Karate report automatically.

2. **Publish Karate report to GitHub Pages** (`if: always()`): Uses `peaceiris/actions-gh-pages@v3` to publish the `target/karate-reports/` directory to the `gh-pages` branch with `destination_dir: .`. The live report is accessible at `https://dag86.github.io/fhir-validation-suite/`.

---

## 8. Maven Project Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>
  <groupId>com.fhir.validation</groupId>
  <artifactId>fhir-validation-suite</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <name>FHIR R4 API Validation Suite</name>
  <description>
    Regulatory-grade FHIR R4 API validation framework.
    IEC 62304 / ISO 14971 / 21 CFR Part 11 aligned.
  </description>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <karate.version>1.5.1</karate.version>
    <junit.version>5.10.0</junit.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>io.karatelabs</groupId>
      <artifactId>karate-junit5</artifactId>
      <version>${karate.version}</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>${junit.version}</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <testResources>
      <testResource>
        <directory>src/test/resources</directory>
      </testResource>
    </testResources>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.1.2</version>
        <configuration>
          <systemPropertyVariables>
            <baseUrl>${baseUrl}</baseUrl>
            <fhirVersion>${fhirVersion}</fhirVersion>
            <authToken>${authToken}</authToken>
          </systemPropertyVariables>
        </configuration>
      </plugin>
    </plugins>
  </build>

</project>
```

---

## 9. Design Decisions

### 9.1 Server-Agnostic Design

**Decision:** All server URLs are externalized to configuration. No test file contains a hardcoded URL.

**Rationale:** The framework's primary real-world value is its reusability against any FHIR R4 server. Hardcoded URLs would make it a sandbox-specific script rather than a validation framework.

### 9.2 CapabilityStatement Pre-Check

**Decision:** Every test run begins with a CapabilityStatement query that gates which resource tests execute.

**Rationale:** FHIR servers are not required to implement all resources. Testing unsupported resources produces misleading failures. The pre-check ensures test results reflect genuine conformance gaps, not scope mismatches.

### 9.3 Two-Layer Validation

**Decision:** Karate assertions and HL7 Validator are both used — not one or the other.

**Rationale:** Karate encodes clinical rules specific to this validation suite. The HL7 Validator encodes the full specification. Together they provide both targeted clinical assertions and authoritative spec conformance. Either alone is insufficient for regulated evidence.

### 9.4 Response File Capture

**Decision:** API responses are written to disk for post-execution HL7 Validator processing.

**Rationale:** The HL7 Validator CLI operates on files, not HTTP streams. Capturing responses enables authoritative validation without requiring a proxy or interceptor. It also creates a permanent record of what the server returned at the time of validation.

### 9.5 No PHI in Test Data

**Decision:** All test data uses the public HAPI sandbox. No real patient data is used at any point.

**Rationale:** HIPAA compliance requirement. The public sandbox provides sufficient real FHIR resource instances for all validation scenarios.

### 9.6 validator_cli.jar Not Committed to Git

**Decision:** The HL7 Validator binary is excluded from Git via `.gitignore` and downloaded fresh in CI.

**Rationale:** The binary is 100MB+ — committing it would make every clone slow and bloat the repository history permanently. More importantly, downloading from the official pinned release (6.4.0) on every CI run and recording the SHA-256 checksum provides stronger integrity assurance than a committed binary whose provenance may be unclear over time. The download URL is pinned to version 6.4.0 in the workflow definition — not the floating `/releases/latest/` URL — per change control requirements.

### 9.7 Branch Protection on Main

**Decision:** The `main` branch is protected — no direct commits, no force-push, pull request review required before merge.

**Rationale:** 21 CFR Part 820.40 requires that document changes be reviewed and approved. Branch protection ensures every change to validated artifacts goes through a reviewable PR. Force-push prevention ensures the Git history that constitutes the evidence chain cannot be retroactively altered.

---

## 10. Security Considerations

- No credentials, API keys, or tokens are committed to the repository
- `.gitignore` present at project root excluding generated artifacts and environment files
- Auth tokens passed via runtime Maven properties only — never hardcoded in source
- GitHub Actions secrets used for any secured server credentials
- `main` branch protected from direct commits and force-push
- Response files captured to disk must not contain PHI in production use
- The HAPI public sandbox is accessed over HTTPS only
- `validator_cli.jar` excluded from Git, downloaded from official HL7 source in CI only

---

## 11. Document Control

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-03-30 | Amir Choshov | Initial draft |
| 1.1 | 2026-03-30 | Amir Choshov | Added Section 3.1 Git component; added Section 6 .gitignore specification; added validator_cli.jar handling rationale to Section 3.4; added Git commit SHA to data flow; added oq/ directory and .gitignore to directory structure; added branch strategy table; added design decisions 9.6 and 9.7; updated security considerations; updated CI workflow to echo commit SHA and branch |
| 1.2 | 2026-04-11 | Amir Choshov | HL7 Validator pinned to 6.4.0 (was "latest stable" — floating version is a change control violation). CI workflow wget URL updated to pinned 6.4.0 release. Validator scan path corrected to target/responses/. GitHub Pages steps documented. CapabilityStatement version assertion updated to 4.0.x regex. Schema section corrected — external schemas not implemented; inline Karate assertions used. Directory structure corrected: schemas/.gitkeep only, target/responses/ path, missing helper features and docs added. Multi-server execution section added (§3.8). Status updated to Approved. |
| 1.3 | 2026-04-16 | Amir Choshov | Added §3.9 Local Test Environment — Docker-based HAPI FHIR R4 server (hapiproject/hapi:v7.4.0), named volume fhir-validation_hapi-data, Synthea 3.2.0 synthetic patient generation (seed 42, population 50, Massachusetts), supporting scripts inventory. Documents -DbaseUrl targeting mechanism and no-feature-file-change environment switching. |

---

## 12. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Author | Amir Choshov | | |
| Reviewer | | | |

---

*This Architecture Document governs the technical design of the FHIR R4 API Validation Suite. Changes to component selection, directory structure, or data flow must be reflected in a revision to this document.*
