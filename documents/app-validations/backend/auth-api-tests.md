# Authentication API Testing

This guide contains curl commands for testing all authentication-related endpoints.

## Base URL
```bash
export API_BASE="http://localhost:3001/api/auth"
```

## User Registration

### Register New User - Success Case
```bash
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser123",
    "email": "testuser123@example.com",
    "password": "TestPassword123!",
    "phoneNumber": "+1-555-123-4567",
    "address": {
      "street": "123 Test Street",
      "city": "Test City",
      "state": "TS",
      "zipCode": "12345",
      "country": "USA"
    }
  }' | jq '.'
```

### Register User - Missing Required Fields
```bash
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com"
  }' | jq '.'
```

### Register User - Invalid Email Format
```bash
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "invalid-email",
    "password": "TestPassword123!"
  }' | jq '.'
```

### Register User - Duplicate Email
```bash
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "anotheruser",
    "email": "john.doe@example.com",
    "password": "TestPassword123!"
  }' | jq '.'
```

## User Login

### Login - Success Case
```bash
curl -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePass123!"
  }' | jq '.'
```

### Login - Save Token to Variable
```bash
TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: $TOKEN"
```

### Login - Wrong Password
```bash
curl -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "WrongPassword"
  }' | jq '.'
```

### Login - Non-existent User
```bash
curl -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nonexistent@example.com",
    "password": "SomePassword123!"
  }' | jq '.'
```

### Login - Missing Fields
```bash
curl -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com"
  }' | jq '.'
```

## User Management

### Get All Users (Admin Only)
```bash
# First get token
TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane.davis@example.com","password":"Jane@Davis2024"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Get all users
curl -X GET http://localhost:3001/api/users \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Get User by Username
```bash
# Get token
TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Get specific user
curl -X GET http://localhost:3001/api/users/johndoe \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

## Token Validation Tests

### Test Valid Token
```bash
# Get fresh token
TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Test token by accessing protected endpoint
curl -X GET http://localhost:3001/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '. | length'
```

### Test Invalid Token
```bash
curl -X GET http://localhost:3001/api/products \
  -H "Authorization: Bearer invalid_token_here" \
  -H "Content-Type: application/json" | jq '.'
```

### Test Missing Authorization Header
```bash
curl -X GET http://localhost:3001/api/products \
  -H "Content-Type: application/json" | jq '.'
```

### Test Expired Token (Manual)
```bash
# Use an old token that has expired
curl -X GET http://localhost:3001/api/products \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MTg5NzJhYTU3ZDExYzQwZTdlYzgzMCIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzQ5NjEyNDYxLCJleHAiOjE3NDk2MTYwNjF9.MxJPx91NXoirc--kTQ4czt3f45RvJlcqK4gr8Hvz9OA" \
  -H "Content-Type: application/json" | jq '.'
```

## Role-Based Access Testing

### Test Admin Access
```bash
# Login as admin
ADMIN_TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane.davis@example.com","password":"Jane@Davis2024"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Test admin-only endpoint
curl -X GET http://localhost:3001/api/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '. | length'
```

### Test Regular User Access
```bash
# Login as regular user
USER_TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Try to access admin-only endpoint (should fail)
curl -X GET http://localhost:3001/api/users \
  -H "Authorization: Bearer $USER_TOKEN" | jq '.'
```

## Password Security Tests

### Test Weak Password Registration
```bash
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "weakpassuser",
    "email": "weak@example.com",
    "password": "123"
  }' | jq '.'
```

### Test Common Password Registration
```bash
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "commonpassuser",
    "email": "common@example.com",
    "password": "password123"
  }' | jq '.'
```

## Email Validation Tests

### Test Various Email Formats
```bash
# Valid email
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","email":"valid@domain.com","password":"TestPass123!"}' | jq '.'

# Invalid email - no @
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","email":"invalidemail","password":"TestPass123!"}' | jq '.'

# Invalid email - no domain
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user3","email":"invalid@","password":"TestPass123!"}' | jq '.'

# Invalid email - special characters
curl -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user4","email":"inv@lid@domain.com","password":"TestPass123!"}' | jq '.'
```

## Batch Testing Script

### Create Comprehensive Auth Test Script
```bash
cat > /workspaces/cs624-tp/app-validations/backend/test-auth.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api/auth"

echo "🔐 Authentication API Testing"
echo "================================"

echo "1. Testing user registration..."
echo "✅ Valid registration:"
curl -s -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser_'$(date +%s)'",
    "email": "testuser_'$(date +%s)'@example.com",
    "password": "TestPassword123!"
  }' | jq '.message // .error'

echo ""
echo "❌ Invalid registration (missing password):"
curl -s -X POST $API_BASE/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com"
  }' | jq '.error'

echo ""
echo "2. Testing user login..."
echo "✅ Valid login:"
TOKEN=$(curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | jq -r '.token // empty')

if [ -n "$TOKEN" ]; then
    echo "Login successful - Token received"
    
    echo ""
    echo "3. Testing token validation..."
    PRODUCT_COUNT=$(curl -s -X GET http://localhost:3001/api/products \
      -H "Authorization: Bearer $TOKEN" | jq '. | length')
    echo "✅ Token valid - Retrieved $PRODUCT_COUNT products"
else
    echo "Login failed"
fi

echo ""
echo "❌ Invalid login (wrong password):"
curl -s -X POST $API_BASE/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"WrongPassword"}' \
  | jq '.error'

echo ""
echo "4. Testing unauthorized access..."
echo "❌ No token provided:"
curl -s -X GET http://localhost:3001/api/products | jq '.error'

echo ""
echo "❌ Invalid token:"
curl -s -X GET http://localhost:3001/api/products \
  -H "Authorization: Bearer invalid_token" | jq '.error'

echo ""
echo "🔐 Authentication testing completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/test-auth.sh
```

### Run the Auth Test Script
```bash
./test-auth.sh
```

## Environment Variables for Testing

```bash
# Set common test variables
export API_BASE="http://localhost:3001/api/auth"
export TEST_EMAIL="john.doe@example.com"
export TEST_PASSWORD="SecurePass123!"
export ADMIN_EMAIL="jane.davis@example.com"
export ADMIN_PASSWORD="Jane@Davis2024"

# Get tokens for testing
export USER_TOKEN=$(curl -s -X POST $API_BASE/login -H "Content-Type: application/json" -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
export ADMIN_TOKEN=$(curl -s -X POST $API_BASE/login -H "Content-Type: application/json" -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "User Token: $USER_TOKEN"
echo "Admin Token: $ADMIN_TOKEN"
```
