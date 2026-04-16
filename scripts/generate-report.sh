#!/bin/bash
# Generate human-readable FHIR validation report
# Run this after: mvn test -DbaseUrl=https://...
#
# Usage: ./scripts/generate-report.sh
#
# Output: target/karate-reports/fhir-report.html

set -e

if [ ! -f "target/karate-reports/karate-summary-json.txt" ]; then
  echo "ERROR: target/karate-reports/karate-summary-json.txt not found."
  echo "Run mvn test first to generate Karate output."
  exit 1
fi

python3 - << 'PYEOF'
import json, sys, os

TEMPLATE = 'src/test/resources/reporting/fhir-report.html'
REPORTS  = 'target/karate-reports'
OUTPUT   = 'target/karate-reports/fhir-report.html'

FEATURE_NAMES = [
    'allergy.allergy',
    'audit.audit-event',
    'bundle.bundle',
    'capability.capability-check',
    'common.general',
    'common.operation-outcome',
    'diagnostic.diagnostic-report',
    'medication.medication',
    'observation.observation',
    'patient.patient',
    'practitioner.practitioner',
]

# Read template
with open(TEMPLATE, 'r', encoding='utf-8') as f:
    template = f.read()

# Read summary
with open(f'{REPORTS}/karate-summary-json.txt', 'r', encoding='utf-8') as f:
    summary = json.load(f)

# Read all feature JSON files
features = {}
for name in FEATURE_NAMES:
    path = f'{REPORTS}/{name}.json'
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            features[name] = json.load(f)
    else:
        print(f'Warning: {path} not found — skipping', file=sys.stderr)

# Build injection script
injected_data = {'summary': summary, 'features': features}
injected_json = json.dumps(injected_data, separators=(',', ':'))

injection = (
    '<script id="injected-data">\n'
    f'const INJECTED_REPORT_DATA = {injected_json};\n'
    '</script>'
)

placeholder = '<script id="injected-data">// DATA_INJECTION_PLACEHOLDER</script>'

if placeholder not in template:
    print('ERROR: placeholder not found in template. Was fhir-report.html modified?', file=sys.stderr)
    sys.exit(1)

output = template.replace(placeholder, injection, 1)

with open(OUTPUT, 'w', encoding='utf-8') as f:
    f.write(output)

size_kb = os.path.getsize(OUTPUT) // 1024
print(f'Report generated: {OUTPUT} ({size_kb} KB)')
PYEOF

echo ""
echo "Opening report..."
open target/karate-reports/fhir-report.html
