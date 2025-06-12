#!/bin/bash

# Backend API Automated Test Suite
# This script runs all backend API tests automatically

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="http://localhost:3000"
ADMIN_EMAIL="admin@admin.com"
ADMIN_PASSWORD="admin123"
TEST_USER_EMAIL="testuser@example.com"
TEST_USER_PASSWORD="password123"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_test() {
    echo -e "\n${YELLOW}Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
    ((TOTAL_TESTS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
    ((TOTAL_TESTS++))
}

# Check if backend is running
check_backend() {
    print_header "CHECKING BACKEND STATUS"
    
    if curl -s "$BACKEND_URL/api/docs" > /dev/null; then
        print_success "Backend is running on $BACKEND_URL"
    else
        print_error "Backend is not running on $BACKEND_URL"
        echo "Please start the backend service first:"
        echo "cd /workspaces/cs624-tp/backend && npm start"
        exit 1
    fi
}

# Test authentication endpoints
test_authentication() {
    print_header "TESTING AUTHENTICATION ENDPOINTS"
    
    # Test login with admin credentials
    print_test "Admin login"
    ADMIN_TOKEN=$(curl -s -X POST "$BACKEND_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}" \
        | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$ADMIN_TOKEN" ]; then
        print_success "Admin login successful"
        export ADMIN_TOKEN
    else
        print_error "Admin login failed"
    fi
    
    # Test user registration
    print_test "User registration"
    REGISTER_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\":\"$TEST_USER_EMAIL\",
            \"password\":\"$TEST_USER_PASSWORD\",
            \"name\":\"Test User\",
            \"role\":\"user\"
        }")
    
    if echo "$REGISTER_RESPONSE" | grep -q "token\|already exists"; then
        print_success "User registration endpoint working"
    else
        print_error "User registration failed"
    fi
    
    # Test user login
    print_test "User login"
    USER_TOKEN=$(curl -s -X POST "$BACKEND_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ ! -z "$USER_TOKEN" ]; then
        print_success "User login successful"
        export USER_TOKEN
    else
        print_error "User login failed"
    fi
}

# Test product endpoints
test_products() {
    print_header "TESTING PRODUCT ENDPOINTS"
    
    # Test get all products
    print_test "Get all products"
    PRODUCTS_RESPONSE=$(curl -s -X GET "$BACKEND_URL/api/products")
    
    if echo "$PRODUCTS_RESPONSE" | grep -q "products\|\\["; then
        print_success "Get all products working"
    else
        print_error "Get all products failed"
    fi
    
    # Test create product (admin only)
    if [ ! -z "$ADMIN_TOKEN" ]; then
        print_test "Create product (admin)"
        CREATE_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/products" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $ADMIN_TOKEN" \
            -d '{
                "name": "Test Product",
                "description": "A test product",
                "price": 99.99,
                "category": "Electronics",
                "stock": 10,
                "imageUrl": "https://example.com/image.jpg"
            }')
        
        if echo "$CREATE_RESPONSE" | grep -q "Test Product\|created"; then
            print_success "Create product working"
            # Extract product ID for future tests
            PRODUCT_ID=$(echo "$CREATE_RESPONSE" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
            export PRODUCT_ID
        else
            print_error "Create product failed"
        fi
    fi
    
    # Test create product without category (should fail)
    if [ ! -z "$ADMIN_TOKEN" ]; then
        print_test "Create product without category (should fail)"
        ERROR_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/products" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $ADMIN_TOKEN" \
            -d '{
                "name": "Invalid Product",
                "description": "Missing category",
                "price": 50.00,
                "stock": 5
            }')
        
        if echo "$ERROR_RESPONSE" | grep -q "category.*required\|validation"; then
            print_success "Product validation working (category required)"
        else
            print_error "Product validation not working properly"
        fi
    fi
}

# Test user endpoints
test_users() {
    print_header "TESTING USER ENDPOINTS"
    
    if [ ! -z "$ADMIN_TOKEN" ]; then
        # Test get all users (admin only)
        print_test "Get all users (admin)"
        USERS_RESPONSE=$(curl -s -X GET "$BACKEND_URL/api/users" \
            -H "Authorization: Bearer $ADMIN_TOKEN")
        
        if echo "$USERS_RESPONSE" | grep -q "users\|\\["; then
            print_success "Get all users working"
        else
            print_error "Get all users failed"
        fi
    fi
    
    if [ ! -z "$USER_TOKEN" ]; then
        # Test get user profile
        print_test "Get user profile"
        PROFILE_RESPONSE=$(curl -s -X GET "$BACKEND_URL/api/users/profile" \
            -H "Authorization: Bearer $USER_TOKEN")
        
        if echo "$PROFILE_RESPONSE" | grep -q "email\|name"; then
            print_success "Get user profile working"
        else
            print_error "Get user profile failed"
        fi
    fi
}

# Test chat endpoints
test_chat() {
    print_header "TESTING CHAT ENDPOINTS"
    
    if [ ! -z "$USER_TOKEN" ]; then
        print_test "Chat with AI"
        CHAT_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/chat" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $USER_TOKEN" \
            -d '{
                "message": "Hello, I need help with products"
            }')
        
        if echo "$CHAT_RESPONSE" | grep -q "response\|message"; then
            print_success "Chat endpoint working"
        else
            print_error "Chat endpoint failed"
        fi
    fi
}

# Test posts endpoints
test_posts() {
    print_header "TESTING POSTS ENDPOINTS"
    
    # Test get all posts
    print_test "Get all posts"
    POSTS_RESPONSE=$(curl -s -X GET "$BACKEND_URL/api/posts")
    
    if echo "$POSTS_RESPONSE" | grep -q "posts\|\\["; then
        print_success "Get all posts working"
    else
        print_error "Get all posts failed"
    fi
    
    if [ ! -z "$USER_TOKEN" ]; then
        # Test create post
        print_test "Create post"
        POST_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/posts" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $USER_TOKEN" \
            -d '{
                "title": "Test Post",
                "content": "This is a test post content",
                "category": "general"
            }')
        
        if echo "$POST_RESPONSE" | grep -q "Test Post\|created"; then
            print_success "Create post working"
        else
            print_error "Create post failed"
        fi
    fi
}

# Print test summary
print_summary() {
    print_header "TEST SUMMARY"
    echo -e "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}⚠️  Some tests failed. Please check the output above.${NC}"
        exit 1
    fi
}

# Main execution
main() {
    print_header "BACKEND API AUTOMATED TEST SUITE"
    echo "Starting comprehensive API testing..."
    
    check_backend
    test_authentication
    test_products
    test_users
    test_chat
    test_posts
    print_summary
}

# Run the tests
main "$@"
