#!/bin/bash

# API Testing Script
# Usage: ./test-api.sh [base_url]
# Example: ./test-api.sh http://localhost:3000

BASE_URL=${1:-http://localhost:3000/api}
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Testing API at: $BASE_URL"
echo ""

# Test counter
PASSED=0
FAILED=0

# Test function
test_endpoint() {
    METHOD=$1
    ENDPOINT=$2
    DATA=$3
    EXPECTED_STATUS=$4
    DESCRIPTION=$5
    HEADERS=$6

    if [ -z "$HEADERS" ]; then
        HEADERS="Content-Type: application/json"
    fi

    if [ "$METHOD" = "GET" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL$ENDPOINT" -H "$HEADERS")
    else
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X $METHOD "$BASE_URL$ENDPOINT" -H "$HEADERS" -d "$DATA")
    fi

    if [ "$STATUS" = "$EXPECTED_STATUS" ]; then
        echo -e "${GREEN}✅ PASS${NC} - $DESCRIPTION (Status: $STATUS)"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC} - $DESCRIPTION (Expected: $EXPECTED_STATUS, Got: $STATUS)"
        FAILED=$((FAILED + 1))
    fi
}

echo "1. Testing Health Check..."
test_endpoint "GET" "/health" "" "200" "Health check"

echo ""
echo "2. Testing Authentication..."
test_endpoint "POST" "/auth/login" '{"username":"admin","password":"admin"}' "401" "Login with invalid credentials"
test_endpoint "POST" "/auth/login" '{"username":"test"}' "400" "Login with missing password"

echo ""
echo "3. Testing Protected Endpoints (without auth)..."
test_endpoint "GET" "/auth/profile" "" "401" "Get profile without token"
test_endpoint "GET" "/users" "" "401" "Get users without token"
test_endpoint "GET" "/absensi" "" "401" "Get absensi without token"
test_endpoint "GET" "/dashboard/statistics" "" "401" "Get dashboard stats without token"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Results:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    exit 1
fi

