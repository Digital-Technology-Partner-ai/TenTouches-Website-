#!/usr/bin/env bash
# Diagnostic script for Ten Touches beta/admin endpoints.
#
# Safe default:
#   - read-only counter check
#   - invalid-input validation checks
#   - unauthenticated admin rejection check
#
# Live mutation checks are opt-in because they create beta-signup records.
# To run them intentionally:
#   LIVE_TEST=1 BASE_URL=https://tentouches.app ./test-signup.sh
#
# Authenticated admin check is also opt-in via ADMIN_PASSWORD. Never hard-code
# production credentials in this repo or in shell history.

set -euo pipefail

BASE_URL="${BASE_URL:-https://tentouches.app}"
LIVE_TEST="${LIVE_TEST:-0}"

function get_json_field_count() {
  grep -o '"count":[0-9]*' | cut -d':' -f2 || true
}

function expect_contains() {
  local label="$1"
  local response="$2"
  local expected="$3"

  echo "Response: $response"
  if echo "$response" | grep -q "$expected"; then
    echo "✅ $label"
  else
    echo "❌ $label"
    return 1
  fi
}

echo "=== TEN TOUCHES SIGNUP DIAGNOSTIC TESTS ==="
echo "Base URL: $BASE_URL"
echo "Live mutation checks: $LIVE_TEST"
echo ""

# Test 1: Health check - Get counter
echo "Test 1: Get Counter API"
COUNTER_RESPONSE=$(curl -s "$BASE_URL/.netlify/functions/get-counter")
expect_contains "Counter API is working" "$COUNTER_RESPONSE" '"count"'
echo ""

if [ "$LIVE_TEST" = "1" ]; then
  # Test 2: Submit with all fields. This creates a clearly labelled live test record.
  echo "Test 2: Submit with name, email, and mobile — LIVE MUTATION"
  TEST_EMAIL="hudson-live-test-$(date +%s)@example.com"
  SUBMIT_RESPONSE=$(curl -s -X POST "$BASE_URL/.netlify/functions/submit-beta" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Hudson live diagnostic\", \"email\": \"$TEST_EMAIL\", \"mobile\": \"+44 7700 900000\"}")
  expect_contains "Submission with mobile works" "$SUBMIT_RESPONSE" '"success":true'
  echo "Created diagnostic signup email: $TEST_EMAIL"
  echo ""

  # Test 3: Submit without mobile. This creates a clearly labelled live test record.
  echo "Test 3: Submit without mobile — LIVE MUTATION"
  TEST_EMAIL2="hudson-live-test-no-mobile-$(date +%s)@example.com"
  SUBMIT_RESPONSE2=$(curl -s -X POST "$BASE_URL/.netlify/functions/submit-beta" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Hudson live diagnostic no mobile\", \"email\": \"$TEST_EMAIL2\"}")
  expect_contains "Submission without mobile works" "$SUBMIT_RESPONSE2" '"success":true'
  echo "Created diagnostic signup email: $TEST_EMAIL2"
  echo ""

  # Test 4: Submit with empty mobile. This creates a clearly labelled live test record.
  echo "Test 4: Submit with empty mobile string — LIVE MUTATION"
  TEST_EMAIL3="hudson-live-test-empty-mobile-$(date +%s)@example.com"
  SUBMIT_RESPONSE3=$(curl -s -X POST "$BASE_URL/.netlify/functions/submit-beta" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"Hudson live diagnostic empty mobile\", \"email\": \"$TEST_EMAIL3\", \"mobile\": \"\"}")
  expect_contains "Submission with empty mobile works" "$SUBMIT_RESPONSE3" '"success":true'
  echo "Created diagnostic signup email: $TEST_EMAIL3"
  echo ""
else
  echo "Tests 2-4: skipped live signup mutation checks. Set LIVE_TEST=1 to run them intentionally."
  echo ""
fi

# Test 5: Validation - missing name. This should not create a record.
echo "Test 5: Validation - missing name"
VALIDATION_RESPONSE=$(curl -s -w " HTTP_STATUS:%{http_code}" -X POST "$BASE_URL/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"hudson-validation@example.com\"}")
expect_contains "Validation rejects missing name" "$VALIDATION_RESPONSE" 'HTTP_STATUS:400'
echo ""

# Test 6: Validation - missing email. This should not create a record.
echo "Test 6: Validation - missing email"
VALIDATION_RESPONSE2=$(curl -s -w " HTTP_STATUS:%{http_code}" -X POST "$BASE_URL/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Hudson validation\"}")
expect_contains "Validation rejects missing email" "$VALIDATION_RESPONSE2" 'HTTP_STATUS:400'
echo ""

# Test 7: Admin API access.
echo "Test 7: Admin API with password"
if [ -z "${ADMIN_PASSWORD:-}" ]; then
  echo "⚠️  Skipping admin API authenticated check: ADMIN_PASSWORD is not set"
else
  ADMIN_RESPONSE=$(curl -s "$BASE_URL/.netlify/functions/admin-signups" \
    -H "X-Admin-Password: $ADMIN_PASSWORD")
  SIGNUP_COUNT=$(echo "$ADMIN_RESPONSE" | get_json_field_count)
  echo "Total signups: $SIGNUP_COUNT"
  if [ -n "$SIGNUP_COUNT" ] && [ "$SIGNUP_COUNT" -gt 0 ]; then
    echo "✅ Admin API working"
  else
    echo "❌ Admin API failed"
    exit 1
  fi
fi
echo ""

# Test 8: Admin API without password should fail.
echo "Test 8: Admin API without password (should reject)"
ADMIN_RESPONSE2=$(curl -s -w " HTTP_STATUS:%{http_code}" "$BASE_URL/.netlify/functions/admin-signups")
expect_contains "Admin API properly rejects unauthorized requests" "$ADMIN_RESPONSE2" 'HTTP_STATUS:401'
echo ""

echo "=== TEST SUMMARY ==="
echo "Diagnostics completed. Safe checks run by default; live signup mutations require LIVE_TEST=1."
