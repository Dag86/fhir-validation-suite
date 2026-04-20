#!/bin/bash

echo "=== Traceability Verification ==="
echo "Checking bidirectional REQ <-> TC coverage..."
echo ""

FEATURES_TMP=$(mktemp)
TM_TMP=$(mktemp)
FAIL=0

grep -rh "Scenario:" src/test/resources/ --include="*.feature" | \
  grep -o "TC-[A-Z]*-[0-9]*" | sort > "$FEATURES_TMP"

grep -o "TC-[A-Z]*-[0-9]*" docs/traceability-matrix.md | \
  sort -u > "$TM_TMP"

ORPHAN_FEATURES=$(comm -23 "$FEATURES_TMP" "$TM_TMP")
if [ -n "$ORPHAN_FEATURES" ]; then
  echo "FAIL: TCs in feature files but not in TM:"
  echo "$ORPHAN_FEATURES"
  FAIL=1
else
  FEATURE_COUNT=$(wc -l < "$FEATURES_TMP" | tr -d ' ')
  echo "PASS: $FEATURE_COUNT automated TCs all present in TM"
fi

MISSING_FEATURES=$(comm -23 "$TM_TMP" "$FEATURES_TMP" | grep -v "TC-FRM-")
if [ -n "$MISSING_FEATURES" ]; then
  echo "FAIL: TCs in TM missing from feature files (excluding TC-FRM-*):"
  echo "$MISSING_FEATURES"
  FAIL=1
else
  echo "PASS: 0 orphan TCs in TM without feature file implementation"
fi

REQ_COUNT=$(grep -o "REQ-[A-Z]*-[0-9]*[a-z]*" docs/traceability-matrix.md | \
  grep -v "^REQ-GEN-002$" | sort -u | wc -l | tr -d ' ')
EXPECTED_REQS=68
if [ "$REQ_COUNT" -ne "$EXPECTED_REQS" ]; then
  echo "FAIL: Expected $EXPECTED_REQS requirements, found $REQ_COUNT"
  FAIL=1
else
  echo "PASS: $REQ_COUNT/68 requirements present in TM"
fi

rm -f "$FEATURES_TMP" "$TM_TMP"

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "=== TRACEABILITY VERIFICATION PASSED ==="
  exit 0
else
  echo "=== TRACEABILITY VERIFICATION FAILED ==="
  exit 1
fi
