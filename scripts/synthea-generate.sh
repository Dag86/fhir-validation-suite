#!/bin/bash
set -e

SYNTHEA_JAR=scripts/synthea-with-dependencies.jar

if [ ! -f "$SYNTHEA_JAR" ]; then
  echo "Synthea jar not found — downloading..."
  curl -L -o "$SYNTHEA_JAR" \
    https://github.com/synthetichealth/synthea/releases/download/master-branch-latest/synthea-with-dependencies.jar
fi

java -jar "$SYNTHEA_JAR" \
  -s 42 \
  -p 50 \
  --exporter.baseDirectory=synthea-output \
  --exporter.fhir.export=true \
  --exporter.fhir.use_r4=true \
  --exporter.hospital.fhir.export=true \
  --exporter.practitioner.fhir.export=true

echo "Synthea generation complete. Output: synthea-output/fhir/"
