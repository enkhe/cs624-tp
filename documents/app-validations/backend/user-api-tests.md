# User API Testing

This guide contains curl commands for testing all user-related endpoints.

## Base URL and Authentication Setup
```bash
export API_BASE="http://localhost:3001/api"
export USERS_API="$API_BASE/users"

# Get admin token (required for most user endpoints)
export ADMIN_TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane.davis@example.com","password":"Jane@Davis2024"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Get regular user token
export USER_TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Admin Token: ${ADMIN_TOKEN:0:50}..."
echo "User Token: ${USER_TOKEN:0:50}..."
```

## User Management Operations

### Get All Users (Admin Only)
```bash
# Success case - Admin access
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
```

### Get All Users - Count Only
```bash
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '. | length'
```

### Get All Users - Specific Fields Only
```bash
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | {username, email, role, isActive}'
```

### Get User by Username
```bash
# Get specific user by username
curl -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
```

### Get User by Username - Non-Admin Access
```bash
# Regular user accessing another user's profile
curl -X GET $USERS_API/janedavis \
  -H "Authorization: Bearer $USER_TOKEN" | jq '.'
```

### Get User by Username - Own Profile
```bash
# User accessing their own profile
curl -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $USER_TOKEN" | jq '.'
```

### Get Non-Existent User
```bash
curl -X GET $USERS_API/nonexistentuser \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
```

## Authorization Testing

### Test Admin Access to User List
```bash
echo "Testing admin access to user list:"
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | jq '. | length'
```

### Test Regular User Access to User List (Should Fail)
```bash
echo "Testing regular user access to user list (should fail):"
curl -X GET $USERS_API \
  -H "Authorization: Bearer $USER_TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | jq '.'
```

### Test Unauthorized Access
```bash
echo "Testing unauthorized access:"
curl -X GET $USERS_API \
  -w "\nHTTP Status: %{http_code}\n" | jq '.'
```

### Test Invalid Token
```bash
echo "Testing invalid token:"
curl -X GET $USERS_API \
  -H "Authorization: Bearer invalid_token_here" \
  -w "\nHTTP Status: %{http_code}\n" | jq '.'
```

## User Profile Testing

### Get User Profile - Admin View
```bash
# Admin viewing any user's full profile
curl -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '{
    username,
    email,
    role,
    isActive,
    profileImage,
    phoneNumber,
    address,
    createdAt,
    updatedAt
  }'
```

### Get User Profile - User's Own Profile
```bash
# User viewing their own profile
curl -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $USER_TOKEN" | jq '{
    username,
    email,
    role,
    profileImage,
    phoneNumber,
    address
  }'
```

### Get User Profile - Public Information Only
```bash
# Extract only public information
curl -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '{
    username,
    profileImage,
    role
  }'
```

## User Search and Filtering

### Filter Users by Role
```bash
# Get all admin users
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.role == "admin")'

# Get all regular users
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.role == "user")'
```

### Filter Active Users
```bash
# Get only active users
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.isActive == true)'

# Get inactive users
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.isActive == false)'
```

### Search Users by Email Domain
```bash
# Find all users with example.com email
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.email | contains("example.com"))'
```

### Get Recent Users
```bash
# Get users created in the last month (adjust date as needed)
curl -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.createdAt > "2024-05-01")'
```

## User Statistics

### Get User Count by Role
```bash
echo "User count by role:"
curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq 'group_by(.role) | map({role: .[0].role, count: length})'
```

### Get Active vs Inactive Users
```bash
echo "Active vs Inactive users:"
curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq 'group_by(.isActive) | map({active: .[0].isActive, count: length})'
```

### Get Users with Complete Profiles
```bash
echo "Users with complete profiles (phone and address):"
curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.phoneNumber != null and .address != null) | {username, email}'
```

## Error Handling Tests

### Test Username Case Sensitivity
```bash
# Test if usernames are case sensitive
curl -X GET $USERS_API/JOHNDOE \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

curl -X GET $USERS_API/JohnDoe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
```

### Test Special Characters in Username
```bash
# Test username with special characters (should not exist)
curl -X GET $USERS_API/john@doe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

curl -X GET $USERS_API/john.doe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
```

### Test Very Long Username
```bash
# Test very long username
LONG_USERNAME=$(printf 'a%.0s' {1..100})
curl -X GET $USERS_API/$LONG_USERNAME \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'
```

## Performance Testing

### Test Response Time for User List
```bash
echo "Testing response time for user list:"
time curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" > /dev/null
```

### Test Multiple User Lookups
```bash
echo "Testing multiple user lookups:"
for username in johndoe janedavis mikesmith; do
    echo -n "Looking up $username... "
    time curl -s -X GET $USERS_API/$username \
      -H "Authorization: Bearer $ADMIN_TOKEN" > /dev/null
done
```

## Data Validation Tests

### Verify User Data Structure
```bash
echo "Verifying user data structure:"
curl -s -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq 'keys'
```

### Check Required Fields
```bash
echo "Checking if required fields are present:"
curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | {
    username: .username,
    email: .email,
    hasPassword: (.password != null),
    role: .role,
    isActive: .isActive
  }'
```

### Validate Email Formats
```bash
echo "Validating email formats:"
curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.[] | select(.email | test("^[^@]+@[^@]+\\.[^@]+$") | not) | {username, email}'
```

## Comprehensive User Testing Script

### Create User Test Suite
```bash
cat > /workspaces/cs624-tp/app-validations/backend/test-users.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api"
USERS_API="$API_BASE/users"

echo "👥 User API Testing"
echo "==================="

# Get tokens
echo "Getting authentication tokens..."
ADMIN_TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane.davis@example.com","password":"Jane@Davis2024"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

USER_TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ] || [ -z "$USER_TOKEN" ]; then
    echo "❌ Failed to get authentication tokens"
    exit 1
fi

echo "✅ Tokens obtained"
echo ""

# Test 1: Admin access to user list
echo "1. Testing admin access to user list..."
USER_COUNT=$(curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '. | length')

if [ "$USER_COUNT" -gt 0 ]; then
    echo "✅ Admin successfully retrieved $USER_COUNT users"
else
    echo "❌ Admin failed to retrieve users"
fi

# Test 2: Regular user access to user list (should fail)
echo ""
echo "2. Testing regular user access to user list (should be denied)..."
ERROR_MSG=$(curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $USER_TOKEN" | jq -r '.error // empty')

if [ -n "$ERROR_MSG" ]; then
    echo "✅ Regular user correctly denied access: $ERROR_MSG"
else
    echo "❌ Regular user incorrectly allowed access"
fi

# Test 3: Get specific user
echo ""
echo "3. Testing specific user retrieval..."
USER_NAME=$(curl -s -X GET $USERS_API/johndoe \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.username // empty')

if [ "$USER_NAME" = "johndoe" ]; then
    echo "✅ Successfully retrieved user: $USER_NAME"
else
    echo "❌ Failed to retrieve user"
fi

# Test 4: Get non-existent user
echo ""
echo "4. Testing non-existent user retrieval..."
ERROR_MSG=$(curl -s -X GET $USERS_API/nonexistentuser \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.error // empty')

if [ -n "$ERROR_MSG" ]; then
    echo "✅ Correctly returned error for non-existent user: $ERROR_MSG"
else
    echo "❌ Did not return error for non-existent user"
fi

# Test 5: Unauthorized access
echo ""
echo "5. Testing unauthorized access..."
ERROR_MSG=$(curl -s -X GET $USERS_API | jq -r '.error // empty')

if [ -n "$ERROR_MSG" ]; then
    echo "✅ Correctly denied unauthorized access: $ERROR_MSG"
else
    echo "❌ Did not deny unauthorized access"
fi

# Test 6: User role verification
echo ""
echo "6. Testing user role verification..."
ADMIN_COUNT=$(curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '[.[] | select(.role == "admin")] | length')
USER_COUNT=$(curl -s -X GET $USERS_API \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '[.[] | select(.role == "user")] | length')

echo "✅ Found $ADMIN_COUNT admin(s) and $USER_COUNT regular user(s)"

echo ""
echo "👥 User testing completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/test-users.sh
```

### Run User Test Suite
```bash
./test-users.sh
```

## Security Testing

### Test Token Expiration
```bash
echo "Testing token expiration handling:"
# This would need to be run after tokens expire (1 hour by default)
# curl -X GET $USERS_API \
#   -H "Authorization: Bearer $EXPIRED_TOKEN" | jq '.'
```

### Test Role Escalation
```bash
echo "Testing role escalation protection:"
# Verify regular users cannot access admin endpoints
curl -X GET $USERS_API \
  -H "Authorization: Bearer $USER_TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | jq '.error'
```

### Test Cross-User Access
```bash
echo "Testing cross-user access protection:"
# Test if users can access other users' data inappropriately
curl -X GET $USERS_API/janedavis \
  -H "Authorization: Bearer $USER_TOKEN" | jq '. | keys'
```

## Environment Variables for User Testing

```bash
# Set up user testing environment
export API_BASE="http://localhost:3001/api"
export USERS_API="$API_BASE/users"
export ADMIN_TOKEN=$(curl -s -X POST $API_BASE/auth/login -H "Content-Type: application/json" -d '{"email":"jane.davis@example.com","password":"Jane@Davis2024"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
export USER_TOKEN=$(curl -s -X POST $API_BASE/auth/login -H "Content-Type: application/json" -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Test usernames
export TEST_ADMIN_USER="janedavis"
export TEST_REGULAR_USER="johndoe"
export TEST_NONEXISTENT_USER="nonexistentuser"

echo "User testing environment ready!"
echo "Admin Token: ${ADMIN_TOKEN:0:50}..."
echo "User Token: ${USER_TOKEN:0:50}..."
```
