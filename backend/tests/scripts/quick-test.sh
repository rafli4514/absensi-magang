#!/bin/bash

# Quick API Test Script
# Tests critical endpoints without authentication

BASE_URL=${1:-http://localhost:3000/api}

echo "🧪 Quick API Test"
echo "Testing: $BASE_URL"
echo ""

# Health Check
echo "1. Health Check..."
curl -s "$BASE_URL/health" | jq '.' || echo "❌ Failed or jq not installed"
echo ""

# Test login endpoint exists (should return 400 for missing data, not 404)
echo "2. Login Endpoint (should return 400 for missing credentials)..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/auth/login" -H "Content-Type: application/json" -d '{}')
if [ "$STATUS" = "400" ]; then
    echo "✅ Login endpoint exists (Status: $STATUS)"
else
    echo "❌ Login endpoint issue (Status: $STATUS, expected 400)"
fi
echo ""

echo "✅ Quick test completed!"
echo ""
echo "Note: For full testing, run: npm test"

