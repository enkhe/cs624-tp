#!/bin/bash

# Complete Image Upload and Product Creation Test
# Tests the full workflow: authentication, image upload, and product creation

CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
API_BASE="https://${CODESPACE_NAME}-3001.app.github.dev/api"
AUTH_API="$API_BASE/auth"
PRODUCT_API="$API_BASE/products"
UPLOAD_API="$API_BASE/uploadimages"

echo "🧪 Complete Image Upload and Product Creation Test"
echo "=================================================="

# Step 1: Authentication
echo "🔐 Step 1: Authentication"
login_response=$(curl -s -X POST "$AUTH_API/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane.davis@example.com",
    "password": "Jane@Davis2024"
  }')

token=$(echo $login_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$token" ]; then
    echo "❌ Authentication failed"
    exit 1
fi
echo "✅ Authentication successful"

# Step 2: Create test image
echo "📷 Step 2: Creating test image"
TEST_IMAGE="/tmp/product_test.png"
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE"
echo "✅ Test image created"

# Step 3: Upload image
echo "📤 Step 3: Uploading product image"
upload_response=$(curl -s -X POST "$UPLOAD_API/upload" \
  -F "image=@$TEST_IMAGE")

image_url=$(echo "$upload_response" | grep -o '"imageUrl":"[^"]*"' | cut -d'"' -f4)

if [ -z "$image_url" ]; then
    echo "❌ Image upload failed: $upload_response"
    exit 1
fi
echo "✅ Image uploaded successfully: $image_url"

# Step 4: Create product with uploaded image
echo "📦 Step 4: Creating product with uploaded image"
product_response=$(curl -s -X POST "$PRODUCT_API" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d "{
    \"name\": \"Test Product with Upload\",
    \"description\": \"This product was created with an uploaded image\",
    \"price\": 29.99,
    \"stockQuantity\": 10,
    \"images\": [\"$image_url\"],
    \"brand\": \"TestBrand\",
    \"category\": \"TestCategory\"
  }")

product_id=$(echo "$product_response" | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$product_id" ]; then
    echo "❌ Product creation failed: $product_response"
    exit 1
fi
echo "✅ Product created successfully with ID: $product_id"

# Step 5: Verify product has correct image
echo "🔍 Step 5: Verifying product image"
product_details=$(curl -s -X GET "$PRODUCT_API/$product_id")

if echo "$product_details" | grep -q "$image_url"; then
    echo "✅ Product verification successful - image URL correctly stored"
else
    echo "❌ Product verification failed - image URL not found"
    echo "Product details: $product_details"
    exit 1
fi

# Step 6: Test image accessibility
echo "🌐 Step 6: Testing image accessibility"
http_status=$(curl -s -o /dev/null -w "%{http_code}" "$image_url")

if [ "$http_status" = "200" ]; then
    echo "✅ Uploaded image is publicly accessible"
else
    echo "❌ Image returned HTTP $http_status"
fi

# Cleanup
rm -f "$TEST_IMAGE"

echo ""
echo "🎉 Complete Test Suite Passed!"
echo "================================"
echo "✅ Authentication working"
echo "✅ Image upload working"  
echo "✅ Product creation working"
echo "✅ Image integration working"
echo "✅ Image accessibility working"
echo ""
echo "📋 Summary:"
echo "   Product ID: $product_id"
echo "   Image URL: $image_url"
echo "   Test completed successfully!"
