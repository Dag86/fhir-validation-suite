#!/bin/bash

BASE_URL="${1:-http://localhost:8080/fhir}"
FHIR_DIR="synthea-output/fhir"

if [ ! -d "$FHIR_DIR" ] || [ -z "$(ls "$FHIR_DIR"/*.json 2>/dev/null)" ]; then
  echo "ERROR: No Synthea output found. Run scripts/synthea-generate.sh first."
  exit 1
fi

success=0
failure=0
total=0

for file in "$FHIR_DIR"/*.json; do
  filename="$(basename "$file")"
  total=$((total + 1))

  http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$BASE_URL" \
    -H "Content-Type: application/fhir+json" \
    --data-binary "@$file")

  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    echo "OK: $filename"
    success=$((success + 1))
  else
    echo "FAIL (HTTP $http_code): $filename"
    failure=$((failure + 1))
  fi
done

echo "Loaded $success/$total bundles successfully."

if [ $failure -gt 0 ]; then
  exit 1
fi
