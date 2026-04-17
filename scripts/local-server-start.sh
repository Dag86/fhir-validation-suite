#!/bin/bash
set -e

COMPOSE_FILE="docker/docker-compose.yml"
METADATA_URL="http://localhost:8080/fhir/metadata"
MAX_ATTEMPTS=30
POLL_INTERVAL=5

docker compose -f "$COMPOSE_FILE" up -d

echo "Waiting 45s for HAPI cold-start initialization..."
sleep 45

echo "Waiting for HAPI FHIR R4 to become ready..."
attempt=0
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  if curl -sf "$METADATA_URL" > /dev/null 2>&1; then
    echo "HAPI FHIR R4 ready at http://localhost:8080/fhir"
    exit 0
  fi
  attempt=$((attempt + 1))
  echo "  attempt $attempt/$MAX_ATTEMPTS — not ready yet, retrying in ${POLL_INTERVAL}s..."
  sleep $POLL_INTERVAL
done

echo "ERROR: HAPI FHIR did not become ready after $((MAX_ATTEMPTS * POLL_INTERVAL))s"
exit 1
