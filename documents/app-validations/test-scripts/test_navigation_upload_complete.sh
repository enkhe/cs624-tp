#!/bin/bash

echo "🧭 === NAVIGATION AND IMAGE UPLOAD COMPLETE TEST ==="
echo "Testing: Authentication → Product Creation → Navigation → Image Upload"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="http://localhost:3001"
FRONTEND_URL="http://localhost:8082"

echo -e "${BLUE}🔍 Step 1: Checking services...${NC}"

# Check backend
if curl -s "$BACKEND_URL/api/products" > /dev/null; then
    echo -e "${GREEN}✅ Backend is accessible${NC}"
else
    echo -e "${RED}❌ Backend is not accessible${NC}"
    exit 1
fi

# Check frontend
if curl -s "$FRONTEND_URL" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend server is accessible${NC}"
else
    echo -e "${YELLOW}⚠️ Frontend server may not be fully ready${NC}"
fi

echo ""
echo -e "${BLUE}🔐 Step 2: Testing authentication...${NC}"

# Create test user credentials
TEST_EMAIL="test_nav_$(date +%s)@example.com"
TEST_USERNAME="navtest_$(date +%s)"
TEST_PASSWORD="TestPassword123!"

echo "Creating test user: $TEST_USERNAME"

# Register user
REGISTER_DATA="{
  \"username\": \"$TEST_USERNAME\",
  \"email\": \"$TEST_EMAIL\", 
  \"password\": \"$TEST_PASSWORD\"
}"

REGISTER_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "$REGISTER_DATA")

if echo "$REGISTER_RESPONSE" | grep -q "success\|token\|User registered"; then
    echo -e "${GREEN}✅ User registration successful${NC}"
else
    echo -e "${YELLOW}⚠️ Registration response: $REGISTER_RESPONSE${NC}"
fi

# Login to get token
LOGIN_DATA="{
  \"username\": \"$TEST_USERNAME\",
  \"password\": \"$TEST_PASSWORD\"
}"

echo "Logging in to get authentication token..."
LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "$LOGIN_DATA")

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✅ Login successful, token obtained${NC}"
    echo "Token (first 20 chars): ${TOKEN:0:20}..."
else
    echo -e "${RED}❌ Login failed${NC}"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi

echo ""
echo -e "${BLUE}🛍️ Step 3: Testing product creation...${NC}"

# Test product creation with auth token
PRODUCT_DATA='{
  "name": "Navigation Test Product",
  "description": "A product created to test the complete navigation and upload workflow",
  "price": 149.99,
  "stockQuantity": 25,
  "brand": "TestFlow Brand",
  "category": "Navigation Test",
  "images": ["https://via.placeholder.com/400x400?text=Navigation+Test"]
}'

echo "Creating product with authentication..."
PRODUCT_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/products" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "$PRODUCT_DATA")

if echo "$PRODUCT_RESPONSE" | grep -q '"_id"'; then
    PRODUCT_ID=$(echo "$PRODUCT_RESPONSE" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✅ Product created successfully${NC}"
    echo "Product ID: $PRODUCT_ID"
else
    echo -e "${RED}❌ Failed to create product${NC}"
    echo "Response: $PRODUCT_RESPONSE"
    exit 1
fi

echo ""
echo -e "${BLUE}📱 Step 4: Frontend component verification...${NC}"

# Check App.js navigation logic
if grep -q "setSelectedProduct.*setActiveTab.*ProductDetails" /workspaces/cs624-tp/frontend/app/\(tabs\)/App.js; then
    echo -e "${GREEN}✅ App.js has correct navigation logic${NC}"
else
    echo -e "${RED}❌ App.js navigation logic issue${NC}"
fi

# Check ProductCreateFormNew callback
if [ -f "/workspaces/cs624-tp/frontend/app/(tabs)/ProductCreateFormNew.js" ]; then
    if grep -q "onProductCreated.*result\.data" /workspaces/cs624-tp/frontend/app/\(tabs\)/ProductCreateFormNew.js; then
        echo -e "${GREEN}✅ ProductCreateFormNew has proper callback${NC}"
    else
        echo -e "${YELLOW}⚠️ ProductCreateFormNew callback needs verification${NC}"
    fi
else
    echo -e "${RED}❌ ProductCreateFormNew.js not found${NC}"
fi

# Check ProductEditForm image upload integration
if grep -q "ImageUpload" /workspaces/cs624-tp/frontend/app/\(tabs\)/ProductEditForm.js; then
    echo -e "${GREEN}✅ ProductEditForm has ImageUpload integration${NC}"
else
    echo -e "${RED}❌ ProductEditForm missing ImageUpload${NC}"
fi

# Check ImageUpload component
if [ -f "/workspaces/cs624-tp/frontend/app/(tabs)/ImageUpload.js" ]; then
    echo -e "${GREEN}✅ ImageUpload component exists${NC}"
else
    echo -e "${RED}❌ ImageUpload component not found${NC}"
fi

# Check imageService
if [ -f "/workspaces/cs624-tp/frontend/app/(tabs)/imageService.js" ]; then
    echo -e "${GREEN}✅ imageService exists${NC}"
else
    echo -e "${RED}❌ imageService not found${NC}"
fi

echo ""
echo -e "${GREEN}🎉 TECHNICAL VALIDATION COMPLETE!${NC}"
echo ""
echo -e "${BLUE}📋 MANUAL TESTING WORKFLOW:${NC}"
cat << 'EOF'

Follow these steps to test the complete navigation and image upload functionality:

1. 🌐 OPEN FRONTEND:
   Open browser to: http://localhost:8082

2. 🔐 AUTHENTICATION:
   Register/login with the test credentials created above

3. ➕ CREATE PRODUCT (Navigation Test):
   → Navigate to Products tab
   → Click 'Add Product' button  
   → Fill in product details:
     - Name: 'Navigation Test Product'
     - Description: 'Testing navigation flow'
     - Price: 29.99
     - Stock: 100
   → Upload an image using the image picker
   → Click 'Create Product'

4. 🧭 VERIFY NAVIGATION:
   ✅ Success message should appear
   ✅ After clicking 'OK', should automatically navigate to ProductDetails
   ✅ Should see the newly created product
   ✅ Product information should be complete and accurate

5. 🖼️ TEST IMAGE UPLOAD IN EDIT MODE:
   → Click edit button (pencil icon) in ProductDetails
   → Scroll to find the image upload section
   → Try uploading new images using the image picker
   → Test manual URL entry
   → Save changes
   ✅ Images should update successfully
   ✅ Should see new images in the gallery

6. 🔄 PLATFORM COMPATIBILITY TEST:
   → Test on Web browser ✓
   → Test on Android device/emulator (if available)
   → Test on iOS device/simulator (if available)
   ✅ Image upload should work on all platforms

🎯 SUCCESS CRITERIA:
✅ Product creation works without errors
✅ Automatic navigation to ProductDetails after creation
✅ Image upload works in edit mode
✅ Both image picker and URL entry work
✅ Compatible with web, Android, iOS
✅ No console errors or API failures

🔧 TROUBLESHOOTING:
- Check browser console for JavaScript errors
- Verify backend logs for API issues
- Check network tab for failed requests  
- Ensure authentication tokens persist
- Verify image upload endpoints are accessible

EOF

echo ""
echo -e "${YELLOW}🔑 Test Credentials Created:${NC}"
echo "Username: $TEST_USERNAME"
echo "Email: $TEST_EMAIL"
echo "Password: $TEST_PASSWORD"
echo "Test Product ID: $PRODUCT_ID"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "Frontend: $FRONTEND_URL"
echo "Backend: $BACKEND_URL"
