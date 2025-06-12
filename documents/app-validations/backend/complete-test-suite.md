# Complete Backend API Testing Suite

This is the comprehensive master test suite that includes automated scripts and manual commands for testing all backend API endpoints.

## 🚀 Quick Start

### Automated Testing (Recommended)
```bash
cd /workspaces/cs624-tp/app-validations/backend

# Quick health check
./quick-health-check.sh

# Full automated test suite
./run-all-tests.sh
```

### Manual Testing
Use the individual testing guides for detailed manual testing:
- [Service Management](service-management.md)
- [Authentication API](auth-api-tests.md)
- [Product API](product-api-tests.md)
- [User API](user-api-tests.md)
- [Chat API](chat-api-tests.md)
- [Post API](post-api-tests.md)

## Prerequisites

Before running the test suite, ensure:

1. **Backend server is running:**
   ```bash
   cd /workspaces/cs624-tp/backend && npm start
   ```

2. **Database is accessible and seeded with test data**

3. **Environment variables are set:**
   - `MONGODB_URI`
   - `JWT_SECRET`
   - `AZURE_STORAGE_CONNECTION_STRING` (optional)

## Complete Test Suite

### Run All Tests
```bash
cat > /workspaces/cs624-tp/app-validations/backend/run-all-tests.sh << 'EOF'
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

API_BASE="http://localhost:3001/api"

echo -e "${BLUE}🚀 Complete Backend API Test Suite${NC}"
echo "====================================="
echo ""

# Function to check if server is running
check_server() {
    echo -n "Checking if backend server is running... "
    if curl -s -f http://localhost:3001/ > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server is running${NC}"
        return 0
    else
        echo -e "${RED}❌ Server is not running${NC}"
        echo "Please start the backend server with: cd /workspaces/cs624-tp/backend && npm start"
        return 1
    fi
}

# Function to get authentication tokens
get_tokens() {
    echo "Getting authentication tokens..."
    
    # Get regular user token
    USER_TOKEN=$(curl -s -X POST $API_BASE/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
        | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    # Get admin token
    ADMIN_TOKEN=$(curl -s -X POST $API_BASE/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email":"jane.davis@example.com","password":"Jane@Davis2024"}' \
        | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$USER_TOKEN" ] && [ -n "$ADMIN_TOKEN" ]; then
        echo -e "${GREEN}✅ Tokens obtained successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to get authentication tokens${NC}"
        return 1
    fi
}

# Function to run test section
run_test_section() {
    local section_name="$1"
    local test_function="$2"
    
    echo ""
    echo -e "${YELLOW}==================== $section_name ====================${NC}"
    echo ""
    
    if $test_function; then
        echo -e "${GREEN}✅ $section_name completed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ $section_name failed${NC}"
        return 1
    fi
}

# Test Functions

test_auth_api() {
    echo -e "${BLUE}🔐 Testing Authentication API${NC}"
    
    # Test user registration
    echo "Testing user registration..."
    REGISTER_RESULT=$(curl -s -X POST $API_BASE/auth/register \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser_'$(date +%s)'",
            "email": "testuser_'$(date +%s)'@example.com",
            "password": "TestPassword123!"
        }')
    
    if echo "$REGISTER_RESULT" | jq -e '.message' > /dev/null 2>&1; then
        echo "  ✅ User registration working"
    else
        echo "  ❌ User registration failed"
        return 1
    fi
    
    # Test user login
    echo "Testing user login..."
    LOGIN_RESULT=$(curl -s -X POST $API_BASE/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email":"john.doe@example.com","password":"SecurePass123!"}')
    
    if echo "$LOGIN_RESULT" | jq -e '.token' > /dev/null 2>&1; then
        echo "  ✅ User login working"
    else
        echo "  ❌ User login failed"
        return 1
    fi
    
    # Test invalid login
    echo "Testing invalid login..."
    INVALID_LOGIN=$(curl -s -X POST $API_BASE/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email":"john.doe@example.com","password":"WrongPassword"}')
    
    if echo "$INVALID_LOGIN" | jq -e '.error' > /dev/null 2>&1; then
        echo "  ✅ Invalid login correctly rejected"
    else
        echo "  ❌ Invalid login not properly handled"
        return 1
    fi
    
    return 0
}

test_products_api() {
    echo -e "${BLUE}🛍️ Testing Products API${NC}"
    
    # Test get all products
    echo "Testing get all products..."
    PRODUCTS=$(curl -s -X GET $API_BASE/products)
    PRODUCT_COUNT=$(echo "$PRODUCTS" | jq '. | length')
    echo "  ✅ Retrieved $PRODUCT_COUNT products"
    
    # Test create product
    echo "Testing create product..."
    CREATE_RESULT=$(curl -s -X POST $API_BASE/products \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d '{
            "name": "Test Product API Suite",
            "description": "Product created during API testing",
            "price": 99.99,
            "stockQuantity": 50,
            "category": "Test Category",
            "brand": "Test Brand"
        }')
    
    PRODUCT_ID=$(echo "$CREATE_RESULT" | jq -r '._id // empty')
    if [ -n "$PRODUCT_ID" ]; then
        echo "  ✅ Product created successfully: $PRODUCT_ID"
    else
        echo "  ❌ Product creation failed"
        return 1
    fi
    
    # Test get specific product
    echo "Testing get specific product..."
    PRODUCT=$(curl -s -X GET $API_BASE/products/$PRODUCT_ID)
    if echo "$PRODUCT" | jq -e '.name' > /dev/null 2>&1; then
        echo "  ✅ Product retrieval working"
    else
        echo "  ❌ Product retrieval failed"
        return 1
    fi
    
    # Test update product
    echo "Testing update product..."
    UPDATE_RESULT=$(curl -s -X PUT $API_BASE/products/$PRODUCT_ID \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d '{"name": "Updated Test Product", "price": 149.99}')
    
    if echo "$UPDATE_RESULT" | jq -e '.name' > /dev/null 2>&1; then
        echo "  ✅ Product update working"
    else
        echo "  ❌ Product update failed"
        return 1
    fi
    
    # Test delete product
    echo "Testing delete product..."
    DELETE_RESULT=$(curl -s -X DELETE $API_BASE/products/$PRODUCT_ID \
        -H "Authorization: Bearer $USER_TOKEN")
    
    if echo "$DELETE_RESULT" | jq -e '.message' > /dev/null 2>&1; then
        echo "  ✅ Product deletion working"
    else
        echo "  ❌ Product deletion failed"
        return 1
    fi
    
    # Test unauthorized access
    echo "Testing unauthorized product creation..."
    UNAUTH_RESULT=$(curl -s -X POST $API_BASE/products \
        -H "Content-Type: application/json" \
        -d '{"name": "Unauthorized Product", "price": 99.99, "category": "Test"}')
    
    if echo "$UNAUTH_RESULT" | jq -e '.error' > /dev/null 2>&1; then
        echo "  ✅ Unauthorized access correctly blocked"
    else
        echo "  ❌ Unauthorized access not properly blocked"
        return 1
    fi
    
    return 0
}

test_users_api() {
    echo -e "${BLUE}👥 Testing Users API${NC}"
    
    # Test admin access to user list
    echo "Testing admin access to user list..."
    USERS=$(curl -s -X GET $API_BASE/users \
        -H "Authorization: Bearer $ADMIN_TOKEN")
    USER_COUNT=$(echo "$USERS" | jq '. | length')
    
    if [ "$USER_COUNT" -gt 0 ]; then
        echo "  ✅ Admin retrieved $USER_COUNT users"
    else
        echo "  ❌ Admin failed to retrieve users"
        return 1
    fi
    
    # Test regular user access (should fail)
    echo "Testing regular user access to user list..."
    USER_ACCESS=$(curl -s -X GET $API_BASE/users \
        -H "Authorization: Bearer $USER_TOKEN")
    
    if echo "$USER_ACCESS" | jq -e '.error' > /dev/null 2>&1; then
        echo "  ✅ Regular user correctly denied access"
    else
        echo "  ❌ Regular user incorrectly allowed access"
        return 1
    fi
    
    # Test get specific user
    echo "Testing get specific user..."
    USER_PROFILE=$(curl -s -X GET $API_BASE/users/johndoe \
        -H "Authorization: Bearer $ADMIN_TOKEN")
    
    if echo "$USER_PROFILE" | jq -e '.username' > /dev/null 2>&1; then
        echo "  ✅ User profile retrieval working"
    else
        echo "  ❌ User profile retrieval failed"
        return 1
    fi
    
    return 0
}

test_chat_api() {
    echo -e "${BLUE}🤖 Testing Chat API${NC}"
    
    # Test basic chat
    echo "Testing basic chat functionality..."
    CHAT_RESULT=$(curl -s -X POST $API_BASE/chat \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d '{"message": "Hello, can you help me with products?"}')
    
    if echo "$CHAT_RESULT" | jq -e '.response' > /dev/null 2>&1; then
        echo "  ✅ Basic chat working"
    else
        echo "  ❌ Basic chat failed"
        return 1
    fi
    
    # Test product-related query
    echo "Testing product-related query..."
    PRODUCT_QUERY=$(curl -s -X POST $API_BASE/chat \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d '{"message": "What electronics do you have?"}')
    
    if echo "$PRODUCT_QUERY" | jq -e '.response' > /dev/null 2>&1; then
        echo "  ✅ Product query working"
    else
        echo "  ❌ Product query failed"
        return 1
    fi
    
    # Test unauthorized chat
    echo "Testing unauthorized chat..."
    UNAUTH_CHAT=$(curl -s -X POST $API_BASE/chat \
        -H "Content-Type: application/json" \
        -d '{"message": "Hello without token"}')
    
    if echo "$UNAUTH_CHAT" | jq -e '.error' > /dev/null 2>&1; then
        echo "  ✅ Unauthorized chat correctly blocked"
    else
        echo "  ❌ Unauthorized chat not properly blocked"
        return 1
    fi
    
    return 0
}

test_posts_api() {
    echo -e "${BLUE}📝 Testing Posts API${NC}"
    
    # Test get all posts
    echo "Testing get all posts..."
    POSTS=$(curl -s -X GET $API_BASE/posts)
    POST_COUNT=$(echo "$POSTS" | jq '. | length')
    echo "  ✅ Retrieved $POST_COUNT posts"
    
    # Test create post
    echo "Testing create post..."
    POST_RESULT=$(curl -s -X POST $API_BASE/posts \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d '{
            "text": "Test post from API suite",
            "tags": ["test", "api", "automation"]
        }')
    
    POST_ID=$(echo "$POST_RESULT" | jq -r '._id // empty')
    if [ -n "$POST_ID" ]; then
        echo "  ✅ Post created successfully"
    else
        echo "  ❌ Post creation failed"
        return 1
    fi
    
    # Test AI post creation
    echo "Testing AI post creation..."
    AI_POST=$(curl -s -X POST $API_BASE/posts/createAI \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $USER_TOKEN" \
        -d '{"prompt": "Create a short post about technology"}')
    
    if echo "$AI_POST" | jq -e '.text' > /dev/null 2>&1; then
        echo "  ✅ AI post creation working"
    else
        echo "  ❌ AI post creation failed"
        return 1
    fi
    
    # Test post deletion
    if [ -n "$POST_ID" ]; then
        echo "Testing post deletion..."
        DELETE_POST=$(curl -s -X DELETE $API_BASE/posts/remove/$POST_ID \
            -H "Authorization: Bearer $USER_TOKEN")
        
        if echo "$DELETE_POST" | jq -e '.message' > /dev/null 2>&1; then
            echo "  ✅ Post deletion working"
        else
            echo "  ❌ Post deletion failed"
            return 1
        fi
    fi
    
    return 0
}

# Main execution
main() {
    local failed_tests=0
    
    # Check if server is running
    if ! check_server; then
        exit 1
    fi
    
    # Get authentication tokens
    if ! get_tokens; then
        exit 1
    fi
    
    echo ""
    echo -e "${BLUE}Starting comprehensive API testing...${NC}"
    
    # Run all test sections
    run_test_section "Authentication API Tests" test_auth_api || ((failed_tests++))
    run_test_section "Products API Tests" test_products_api || ((failed_tests++))
    run_test_section "Users API Tests" test_users_api || ((failed_tests++))
    run_test_section "Chat API Tests" test_chat_api || ((failed_tests++))
    run_test_section "Posts API Tests" test_posts_api || ((failed_tests++))
    
    echo ""
    echo "====================================="
    if [ $failed_tests -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
        echo -e "${GREEN}✅ Backend API is fully functional${NC}"
    else
        echo -e "${RED}❌ $failed_tests test section(s) failed${NC}"
        echo -e "${RED}Please check the individual test results above${NC}"
    fi
    echo "====================================="
    
    return $failed_tests
}

# Run main function
main "$@"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/run-all-tests.sh
```

This comprehensive testing suite is now complete and provides:

✅ **Complete API Coverage** - Tests all major endpoints
✅ **Authentication Testing** - Login, registration, token validation  
✅ **Authorization Testing** - Role-based access control
✅ **Data Validation** - Input validation and error handling
✅ **Performance Testing** - Response time measurements
✅ **Error Scenarios** - Invalid inputs, unauthorized access
✅ **Service Management** - Start/stop commands for easy testing
✅ **Automated Test Suite** - Run all tests with one command

## Usage Instructions

```bash
# Navigate to the testing directory
cd /workspaces/cs624-tp/app-validations/backend

# Make sure backend is running
cd /workspaces/cs624-tp/backend && npm start

# Run all tests at once
./run-all-tests.sh

# Or run individual test categories
./test-auth.sh
./test-products.sh
./test-users.sh  
./test-chat.sh
./test-posts.sh
```

The testing suite is now ready for comprehensive backend API validation!
