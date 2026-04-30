#!/bin/bash

BASE_URL="http://localhost:3000/api"
TOKEN=""
COMPANY_ID=""
ADMIN_EMAIL="admin$(date +%s)@test.com"
DRIVER_EMAIL="driver$(date +%s)@test.com"

echo "========== 1. SIGNUP (Onboarding) =========="
SIGNUP_RESPONSE=$(curl -s -X POST "$BASE_URL/onboarding/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "company": {"name": "Test Matatu Co"},
    "admin": {
      "name": "Test Admin",
      "email": "'$ADMIN_EMAIL'",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }')

echo "$SIGNUP_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$SIGNUP_RESPONSE"
TOKEN=$(echo "$SIGNUP_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
COMPANY_ID=$(echo "$SIGNUP_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

echo ""
echo "Token: ${TOKEN:0:20}..."
echo "Company ID: $COMPANY_ID"

echo ""
echo "========== 2. LOGIN =========="
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "'$ADMIN_EMAIL'",
    "password": "password123"
  }')

echo "$LOGIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$LOGIN_RESPONSE"

echo ""
echo "========== 3. GET CURRENT USER (/users/me) =========="
curl -s -X GET "$BASE_URL/users/me" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 4. CREATE VEHICLE =========="
VEHICLE_RESPONSE=$(curl -s -X POST "$BASE_URL/vehicles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle": {
      "plate_number": "KCU 123X",
      "capacity": 14
    }
  }')

echo "$VEHICLE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$VEHICLE_RESPONSE"
VEHICLE_ID=$(echo "$VEHICLE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

echo ""
echo "Vehicle ID: $VEHICLE_ID"

echo ""
echo "========== 5. CREATE ROUTE =========="
ROUTE_RESPONSE=$(curl -s -X POST "$BASE_URL/routes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "route": {
      "origin": "Nairobi",
      "destination": "Mombasa"
    }
  }')

echo "$ROUTE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$ROUTE_RESPONSE"
ROUTE_ID=$(echo "$ROUTE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

echo ""
echo "Route ID: $ROUTE_ID"

echo ""
echo "========== 6. CREATE DRIVER =========="
DRIVER_RESPONSE=$(curl -s -X POST "$BASE_URL/drivers" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Test Driver",
      "email": "'$DRIVER_EMAIL'",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }')

echo "$DRIVER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$DRIVER_RESPONSE"
DRIVER_ID=$(echo "$DRIVER_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

echo ""
echo "Driver ID: $DRIVER_ID"

echo ""
echo "========== 7. APPROVE DRIVER =========="
curl -s -X PATCH "$BASE_URL/drivers/$DRIVER_ID/approve" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 8. LOGIN AS DRIVER =========="
DRIVER_LOGIN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "'$DRIVER_EMAIL'",
    "password": "password123"
  }')

echo "$DRIVER_LOGIN" | python3 -m json.tool 2>/dev/null || echo "$DRIVER_LOGIN"
DRIVER_TOKEN=$(echo "$DRIVER_LOGIN" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo ""
echo "Driver Token: ${DRIVER_TOKEN:0:20}..."

echo ""
echo "========== 9. DRIVER SELF-ASSIGN SHIFT =========="
SHIFT_RESPONSE=$(curl -s -X POST "$BASE_URL/shift_assignments" \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "shift_assignment": {
      "vehicle_id": '$VEHICLE_ID',
      "start_time": "2026-05-01T06:00:00Z",
      "end_time": "2026-05-01T18:00:00Z",
      "status": "active"
    }
  }')

echo "$SHIFT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$SHIFT_RESPONSE"

echo ""
echo "========== 10. DRIVER CREATE TRIP =========="
TRIP_RESPONSE=$(curl -s -X POST "$BASE_URL/trips" \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "trip": {
      "vehicle_id": '$VEHICLE_ID',
      "route_id": '$ROUTE_ID'
    }
  }')

echo "$TRIP_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$TRIP_RESPONSE"
TRIP_ID=$(echo "$TRIP_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

echo ""
echo "Trip ID: $TRIP_ID"

echo ""
echo "========== 11. DRIVER ADD FUEL =========="
curl -s -X POST "$BASE_URL/trips/$TRIP_ID/fuel_records" \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fuel_record": {
      "amount": 5000
    }
  }' | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 12. DRIVER ADD EXPENSE =========="
curl -s -X POST "$BASE_URL/trips/$TRIP_ID/expense_records" \
  -H "Authorization: Bearer $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "expense_record": {
      "description": "Toll fee",
      "amount": 200
    }
  }' | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 13. ADMIN VIEW MONTHLY SUMMARY =========="
curl -s -X GET "$BASE_URL/trips/monthly_summary" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 14. DRIVER VIEW OWN MONTHLY SUMMARY =========="
curl -s -X GET "$BASE_URL/trips/monthly_summary" \
  -H "Authorization: Bearer $DRIVER_TOKEN" | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 15. ADMIN VIEW BILLING =========="
curl -s -X GET "$BASE_URL/billing/invoice" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== 16. DRIVER VIEW OWN STATEMENT =========="
curl -s -X GET "$BASE_URL/billing/driver_statements" \
  -H "Authorization: Bearer $DRIVER_TOKEN" | python3 -m json.tool 2>/dev/null || echo "Failed"

echo ""
echo "========== ALL TESTS COMPLETE =========="
