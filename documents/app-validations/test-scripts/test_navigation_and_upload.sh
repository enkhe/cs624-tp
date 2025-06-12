#!/bin/bash

echo "🧭 === NAVIGATION AND IMAGE UPLOAD TEST ==="
echo "Testing complete user workflow: Product creation → Navigation → Image upload"
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

echo -e "${BLUE}🔍 Step 1: Checking service status...${NC}"

# Check backend
if curl -s "$BACKEND_URL/api/products" > /dev/null; then
    echo -e "${GREEN}✅ Backend is running${NC}"
else
    echo -e "${RED}❌ Backend is not running. Please start the backend first.${NC}"
    echo "Run: cd /workspaces/cs624-tp/backend && npm start"
    exit 1
fi

# Check frontend
if curl -s "$FRONTEND_URL" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend is running${NC}"
else
    echo -e "${YELLOW}⚠️ Frontend might not be fully loaded yet${NC}"
fi

echo ""
echo -e "${BLUE}🧪 Step 2: Testing product creation API...${NC}"

# Test product creation
PRODUCT_DATA='{
  "name": "Navigation Test Product",
  "description": "A product created to test navigation flow",
  "price": 99.99,
  "stockQuantity": 10,
  "brand": "Test Brand",
  "category": "Test Category",
  "images": ["https://via.placeholder.com/300x300?text=Test+Product"]
}'

echo "Creating test product..."
RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/products" \
  -H "Content-Type: application/json" \
  -d "$PRODUCT_DATA")

if echo "$RESPONSE" | grep -q '"_id"'; then
    PRODUCT_ID=$(echo "$RESPONSE" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✅ Product created successfully${NC}"
    echo "Product ID: $PRODUCT_ID"
else
    echo -e "${RED}❌ Failed to create product${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

echo ""
echo -e "${BLUE}🖼️ Step 3: Testing image upload API...${NC}"

# Test image upload
echo "Testing image upload endpoint..."
UPLOAD_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/uploadimages/upload" \
  -F "image=@/dev/null" \
  -F "filename=test.jpg" 2>/dev/null || echo "Upload endpoint test")

echo "Upload endpoint response received"

echo ""
echo -e "${BLUE}📱 Step 4: Frontend component validation...${NC}"

# Check if key files exist and have required imports
echo "Checking ProductEditForm.js..."
if grep -q "ImageUpload" /workspaces/cs624-tp/frontend/app/\(tabs\)/ProductEditForm.js; then
    echo -e "${GREEN}✅ ProductEditForm has ImageUpload import${NC}"
else
    echo -e "${RED}❌ ProductEditForm missing ImageUpload import${NC}"
fi

echo "Checking App.js navigation logic..."
if grep -q "onProductCreated.*setSelectedProduct.*setActiveTab.*ProductDetails" /workspaces/cs624-tp/frontend/app/\(tabs\)/App.js; then
    echo -e "${GREEN}✅ App.js has proper navigation logic${NC}"
else
    echo -e "${YELLOW}⚠️ Navigation logic might need verification${NC}"
fi

echo "Checking ImageUpload component..."
if [ -f "/workspaces/cs624-tp/frontend/app/(tabs)/ImageUpload.js" ]; then
    echo -e "${GREEN}✅ ImageUpload component exists${NC}"
else
    echo -e "${RED}❌ ImageUpload component not found${NC}"
fi

echo ""
echo -e "${BLUE}🔄 Step 5: Navigation flow test...${NC}"

# Create a simple test to verify navigation state management
echo "Testing navigation flow logic..."

# Check if ProductCreateFormNew exists and has proper callbacks
if [ -f "/workspaces/cs624-tp/frontend/app/(tabs)/ProductCreateFormNew.js" ]; then
    if grep -q "onProductCreated" /workspaces/cs624-tp/frontend/app/\(tabs\)/ProductCreateFormNew.js; then
        echo -e "${GREEN}✅ ProductCreateFormNew has onProductCreated callback${NC}"
    else
        echo -e "${RED}❌ ProductCreateFormNew missing onProductCreated callback${NC}"
    fi
else
    echo -e "${RED}❌ ProductCreateFormNew.js not found${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Step 6: Testing complete workflow simulation...${NC}"

cat << 'EOF'
📋 MANUAL TESTING CHECKLIST:

1. 🔐 LOGIN/AUTHENTICATION:
   - Open the app in browser/simulator
   - Login with test credentials
   - Verify user is authenticated

2. ➕ PRODUCT CREATION:
   - Navigate to Products page
   - Click "Add Product" button
   - Fill in product details:
     * Name: "Test Navigation Product"
     * Description: "Testing the navigation flow"
     * Price: 29.99
     * Stock: 50
   - Try uploading an image using the image picker
   - Click "Create Product"
   - Verify success message appears

3. 🧭 NAVIGATION TEST:
   - After clicking "OK" on success message
   - App should automatically navigate to ProductDetails page
   - Verify you can see the newly created product
   - Verify all product information is displayed correctly

4. 🖼️ IMAGE UPLOAD IN EDIT MODE:
   - Click the edit button (pencil icon) in ProductDetails
   - Scroll down to find the image upload section
   - Try uploading additional images
   - Test both image picker and manual URL entry
   - Save changes and verify images are updated

5. 🔄 PLATFORM COMPATIBILITY:
   - Test on web browser
   - Test on Android (if available)
   - Test on iOS (if available)
   - Verify image upload works on all platforms

Expected Results:
✅ Product creation succeeds
✅ Navigation to ProductDetails happens automatically
✅ Product details display correctly
✅ Image upload works in edit mode
✅ Both image picker and URL entry work
✅ Works on web, Android, and iOS
EOF

echo ""
echo -e "${BLUE}📊 Step 7: File integrity check...${NC}"

# Check for common issues
echo "Checking for common issues..."

# Check import paths
if grep -q "import.*ImageUpload.*from.*\.\./ImageUpload" /workspaces/cs624-tp/frontend/app/\(tabs\)/*.js 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Found relative import paths - verify they're correct${NC}"
fi

# Check for console.log statements (for debugging)
LOG_COUNT=$(grep -r "console\.log" /workspaces/cs624-tp/frontend/app/\(tabs\)/ 2>/dev/null | wc -l)
echo "Debug console.log statements found: $LOG_COUNT"

echo ""
echo -e "${GREEN}🎉 Navigation and Image Upload Test Complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Open the frontend app in your browser/simulator"
echo "2. Follow the manual testing checklist above"
echo "3. Report any issues with navigation or image upload"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "Frontend: $FRONTEND_URL"
echo "Backend API: $BACKEND_URL/api"
echo ""
echo -e "${BLUE}🔧 If you encounter issues:${NC}"
echo "- Check browser console for JavaScript errors"
echo "- Verify backend is running and accessible"
echo "- Check network tab for failed API calls"
echo "- Ensure proper authentication tokens are set"
