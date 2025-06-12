#!/bin/bash

# Master Test Runner for React Native App with Image Upload
# This script runs all# 6. React Nat# 7. Image Upl# 8. Product C# 9. Navigati# 10. Complete# 11. Full End# 12. Frontend Upload (JavaScript test)
echo -e "\n${BLUE}📋 Running: Frontend Upload (Node.js)${NC}"o-End Workflow
if run_test "Complete Workflow" "test_complete_workflow.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 12. Frontend Upload (JavaScript test)ion Upload Flow
if run_test "Complete Navigation Upload" "test_navigation_upload_complete.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 11. Full End-to-End Workflowpload Integration
if run_test "Navigation & Upload" "test_navigation_and_upload.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 10. Complete Navigation Upload Flowif run_test "Product Creation" "test_product_creation.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 9. Navigation and Upload Integrationtionality
if run_test "Image Upload" "test_image_upload.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 8. Product CreationData Handling
if run_test "React Native FormData" "test_react_native_formdata.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 7. Image Upload Functionalityion tests in the correct order

echo "🚀 Starting Comprehensive Test Suite for React Native App"
echo "=============================================="

# Set script directory
SCRIPT_DIR="/workspaces/cs624-tp/app-validations/test-scripts"
cd "$SCRIPT_DIR"

# Make all scripts executable
chmod +x *.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run test with status
run_test() {
    local test_name="$1"
    local test_script="$2"
    
    echo -e "\n${BLUE}📋 Running: $test_name${NC}"
    echo "----------------------------------------"
    
    if [ -f "$test_script" ]; then
        if ./"$test_script"; then
            echo -e "${GREEN}✅ $test_name - PASSED${NC}"
            return 0
        else
            echo -e "${RED}❌ $test_name - FAILED${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ $test_name - SCRIPT NOT FOUND: $test_script${NC}"
        return 1
    fi
}

# Function to check backend health
check_backend() {
    echo -e "\n${BLUE}🔍 Checking Backend Health${NC}"
    echo "----------------------------------------"
    
    if curl -s http://localhost:3001/api/health > /dev/null; then
        echo -e "${GREEN}✅ Backend is running on port 3001${NC}"
        return 0
    else
        echo -e "${RED}❌ Backend is not accessible on port 3001${NC}"
        echo -e "${YELLOW}💡 Please start the backend first: cd backend && npm start${NC}"
        return 1
    fi
}

# Test execution order
echo -e "\n${YELLOW}🔧 Pre-flight Checks${NC}"

# Check if backend is running
if ! check_backend; then
    echo -e "\n${RED}❌ Backend health check failed. Aborting tests.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🧪 Starting Test Execution${NC}"

# Track test results
PASSED=0
FAILED=0

# 1. Frontend Configuration Test
if run_test "Frontend Configuration" "test_frontend_config.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 2. Basic CRUD Operations
if run_test "CRUD Operations" "test_post_crud.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 3. Frontend Public Access Test
if run_test "Frontend Public Access" "test_frontend_public_access.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 4. React Native FormData Handling
if run_test "React Native FormData" "test_react_native_formdata.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 5. Image Upload Functionality
if run_test "Image Upload" "test_image_upload.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 6. Product Creation
if run_test "Product Creation" "test_product_creation.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 7. Navigation and Upload Integration
if run_test "Navigation & Upload" "test_navigation_and_upload.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 8. Complete Navigation Upload Flow
if run_test "Complete Navigation Upload" "test_navigation_upload_complete.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 9. Full End-to-End Workflow
if run_test "Complete Workflow" "test_complete_workflow.sh"; then
    ((PASSED++))
else
    ((FAILED++))
fi

# 10. Frontend Upload (JavaScript test)
echo -e "\n${BLUE}📋 Running: Frontend Upload (Node.js)${NC}"
echo "----------------------------------------"
if [ -f "test_frontend_upload.js" ]; then
    if node test_frontend_upload.js; then
        echo -e "${GREEN}✅ Frontend Upload - PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ Frontend Upload - FAILED${NC}"
        ((FAILED++))
    fi
else
    echo -e "${RED}❌ Frontend Upload - SCRIPT NOT FOUND${NC}"
    ((FAILED++))
fi

# Final Results
echo -e "\n${BLUE}=============================================="
echo "📊 TEST SUITE RESULTS"
echo "===============================================${NC}"
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"

TOTAL=$((PASSED + FAILED))
echo -e "${BLUE}📋 Total Tests: $TOTAL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! Your React Native app with image upload is working correctly.${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Some tests failed. Check the output above for details.${NC}"
    echo -e "${YELLOW}💡 Run individual test scripts to debug specific issues.${NC}"
    exit 1
fi
