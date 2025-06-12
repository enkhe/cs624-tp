#!/bin/bash

# Post CRUD API Test Script
# Tests all CRUD operations for the Post API endpoints

# Get dynamic codespace URL
CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
API_BASE="https://${CODESPACE_NAME}-3001.app.github.dev/api/posts"
AUTH_API="https://${CODESPACE_NAME}-3001.app.github.dev/api/auth"
TEMP_FILE="/tmp/post_api_test.json"

echo "🧪 Testing Post CRUD API Endpoints"
echo "=================================="

# Test 1: GET all posts (should be empty initially)
echo "📋 Test 1: GET all posts"
response=$(curl -s -X GET $API_BASE)
echo "Response: $response"
echo ""

# Test 1.5: Get authentication token
echo "🔐 Test 1.5: Getting authentication token"
login_response=$(curl -s -X POST "$AUTH_API/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }')

token=$(echo $login_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$token" ]; then
    echo "⚠️ Admin login failed, trying to register a test user..."
    register_response=$(curl -s -X POST "$AUTH_API/register" \
      -H "Content-Type: application/json" \
      -d '{
        "username": "testuser",
        "email": "test@example.com",
        "password": "test123"
      }')
    echo "Register response: $register_response"
    
    # Try login with test user
    login_response=$(curl -s -X POST "$AUTH_API/login" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "test@example.com",
        "password": "test123"
      }')
    token=$(echo $login_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
fi

if [ -z "$token" ]; then
    echo "❌ Could not get authentication token. Login response: $login_response"
    exit 1
fi

echo "✅ Authentication successful. Token: ${token:0:20}..."
echo ""

# Test 2: Create a new post
echo "📝 Test 2: CREATE a new post"
create_response=$(curl -s -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "title": "Test Post Title",
    "content": "This is a test post content for CRUD testing.",
    "contact": "test@example.com",
    "images": ["https://via.placeholder.com/400x300?text=Test+Image"]
  }')

echo "Create Response: $create_response"

# Extract post ID from response
post_id=$(echo $create_response | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
if [ -n "$post_id" ]; then
    echo "✅ Test 2 PASSED: Post created with ID: $post_id"
    echo $post_id > $TEMP_FILE
else
    echo "❌ Test 2 FAILED: Could not extract post ID"
    exit 1
fi
echo ""

# Test 3: GET all posts (should now have 1 post)
echo "📋 Test 3: GET all posts (after creation)"
response=$(curl -s -X GET $API_BASE)
post_count=$(echo $response | grep -o '"_id"' | wc -l)
if [ "$post_count" -eq 1 ]; then
    echo "✅ Test 3 PASSED: 1 post found in database"
else
    echo "❌ Test 3 FAILED: Expected 1 post, found $post_count"
fi
echo ""

# Test 4: GET specific post by ID
echo "🔍 Test 4: GET post by ID"
get_response=$(curl -s -X GET "$API_BASE/$post_id")
echo "Get Response: $get_response"
if echo $get_response | grep -q "Test Post Title"; then
    echo "✅ Test 4 PASSED: Post retrieved successfully"
else
    echo "❌ Test 4 FAILED: Could not retrieve post by ID"
fi
echo ""

# Test 5: UPDATE the post
echo "✏️  Test 5: UPDATE post"
update_response=$(curl -s -X PUT "$API_BASE/$post_id" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "title": "Updated Test Post Title",
    "content": "This is updated content for the test post.",
    "contact": "updated@example.com",
    "images": ["https://via.placeholder.com/400x300?text=Updated+Image"]
  }')

echo "Update Response: $update_response"
if echo $update_response | grep -q "Updated Test Post Title"; then
    echo "✅ Test 5 PASSED: Post updated successfully"
else
    echo "❌ Test 5 FAILED: Post update failed"
fi
echo ""

# Test 6: Verify update by getting the post again
echo "🔍 Test 6: Verify update"
verify_response=$(curl -s -X GET "$API_BASE/$post_id")
if echo $verify_response | grep -q "Updated Test Post Title"; then
    echo "✅ Test 6 PASSED: Update verified successfully"
else
    echo "❌ Test 6 FAILED: Update verification failed"
fi
echo ""

# Test 7: DELETE the post
echo "🗑️  Test 7: DELETE post"
delete_response=$(curl -s -X DELETE "$API_BASE/$post_id" \
  -H "Authorization: Bearer $token")
echo "Delete Response: $delete_response"
if echo $delete_response | grep -q "deleted successfully\|success.*true"; then
    echo "✅ Test 7 PASSED: Post deleted successfully"
else
    echo "❌ Test 7 FAILED: Post deletion failed"
fi
echo ""

# Test 8: Verify deletion
echo "🔍 Test 8: Verify deletion"
verify_delete_response=$(curl -s -X GET "$API_BASE/$post_id")
if echo $verify_delete_response | grep -q "Cannot be found\|not found\|404"; then
    echo "✅ Test 8 PASSED: Post deletion verified"
else
    echo "❌ Test 8 FAILED: Post still exists after deletion"
fi
echo ""

# Test 9: GET all posts (should be empty again)
echo "📋 Test 9: GET all posts (after deletion)"
final_response=$(curl -s -X GET $API_BASE)
if [ "$final_response" = "[]" ]; then
    echo "✅ Test 9 PASSED: Posts array is empty after deletion"
else
    echo "❌ Test 9 FAILED: Expected empty array, got: $final_response"
fi
echo ""

# Cleanup
rm -f $TEMP_FILE

echo "🎉 Post CRUD API Testing Complete!"
echo "=================================="
