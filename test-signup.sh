#!/bin/bash
# Diagnostic test script for Ten Touches beta signup
# Run this to verify all components are working

echo "=== TEN TOUCHES SIGNUP DIAGNOSTIC TESTS ==="
echo ""

# Test 1: Health check - Get counter
echo "Test 1: Get Counter API"
COUNTER_RESPONSE=$(curl -s "https://tentouches.app/.netlify/functions/get-counter")
echo "Response: $COUNTER_RESPONSE"
if echo "$COUNTER_RESPONSE" | grep -q '"count"'; then
    echo "✅ Counter API is working"
else
    echo "❌ Counter API failed"
fi
echo ""

# Test 2: Submit with all fields
echo "Test 2: Submit with name, email, and mobile"
TEST_EMAIL="test-$(date +%s)@example.com"
SUBMIT_RESPONSE=$(curl -s -X POST "https://tentouches.app/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Test User\", \"email\": \"$TEST_EMAIL\", \"mobile\": \"+44 7700 123456\"}")
echo "Response: $SUBMIT_RESPONSE"
if echo "$SUBMIT_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Submission with mobile works"
else
    echo "❌ Submission with mobile failed"
fi
echo ""

# Test 3: Submit without mobile (optional field)
echo "Test 3: Submit without mobile (optional)"
TEST_EMAIL2="test-no-mobile-$(date +%s)@example.com"
SUBMIT_RESPONSE2=$(curl -s -X POST "https://tentouches.app/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Test User No Mobile\", \"email\": \"$TEST_EMAIL2\"}")
echo "Response: $SUBMIT_RESPONSE2"
if echo "$SUBMIT_RESPONSE2" | grep -q '"success":true'; then
    echo "✅ Submission without mobile works"
else
    echo "❌ Submission without mobile failed"
fi
echo ""

# Test 4: Submit with empty mobile (what frontend sends)
echo "Test 4: Submit with empty mobile string (frontend behavior)"
TEST_EMAIL3="test-empty-mobile-$(date +%s)@example.com"
SUBMIT_RESPONSE3=$(curl -s -X POST "https://tentouches.app/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Test Empty Mobile\", \"email\": \"$TEST_EMAIL3\", \"mobile\": \"\"}")
echo "Response: $SUBMIT_RESPONSE3"
if echo "$SUBMIT_RESPONSE3" | grep -q '"success":true'; then
    echo "✅ Submission with empty mobile works"
else
    echo "❌ Submission with empty mobile failed"
fi
echo ""

# Test 5: Validation - missing name
echo "Test 5: Validation - missing name"
VALIDATION_RESPONSE=$(curl -s -X POST "https://tentouches.app/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"test@example.com\"}")
echo "Response: $VALIDATION_RESPONSE"
if echo "$VALIDATION_RESPONSE" | grep -q '400'; then
    echo "✅ Validation working - rejects missing name"
else
    echo "❌ Validation failed"
fi
echo ""

# Test 6: Validation - missing email
echo "Test 6: Validation - missing email"
VALIDATION_RESPONSE2=$(curl -s -X POST "https://tentouches.app/.netlify/functions/submit-beta" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"Test\"}")
echo "Response: $VALIDATION_RESPONSE2"
if echo "$VALIDATION_RESPONSE2" | grep -q '400'; then
    echo "✅ Validation working - rejects missing email"
else
    echo "❌ Validation failed"
fi
echo ""

# Test 7: Admin API access
# Requires ADMIN_PASSWORD in the local environment. Do not hard-code production
# admin credentials in this repo or in shell history.
echo "Test 7: Admin API with password"
if [ -z "$ADMIN_PASSWORD" ]; then
    echo "⚠️  Skipping admin API authenticated check: ADMIN_PASSWORD is not set"
else
    ADMIN_RESPONSE=$(curl -s "https://tentouches.app/.netlify/functions/admin-signups" \
      -H "X-Admin-Password: $ADMIN_PASSWORD")
    SIGNUP_COUNT=$(echo "$ADMIN_RESPONSE" | grep -o '"count":[0-9]*' | cut -d':' -f2)
    echo "Total signups: $SIGNUP_COUNT"
    if [ -n "$SIGNUP_COUNT" ] && [ "$SIGNUP_COUNT" -gt 0 ]; then
        echo "✅ Admin API working"
    else
        echo "❌ Admin API failed"
    fi
fi
echo ""

# Test 8: Admin API without password (should fail)
echo "Test 8: Admin API without password (should reject)"
ADMIN_RESPONSE2=$(curl -s -w "%{http_code}" "https://tentouches.app/.netlify/functions/admin-signups")
echo "Response code: $ADMIN_RESPONSE2"
if echo "$ADMIN_RESPONSE2" | grep -q '401'; then
    echo "✅ Admin API properly rejects unauthorized requests"
else
    echo "❌ Admin API security issue"
fi
echo ""

echo "=== TEST SUMMARY ==="
echo "All backend tests completed."
echo ""
echo "If all tests pass but the form still doesn't work in browser:"
echo "1. Check browser console for JavaScript errors"
echo "2. Check if Netlify Forms is interfering with API submission"
echo "3. Verify the counter display isn't breaking due to large numbers"
