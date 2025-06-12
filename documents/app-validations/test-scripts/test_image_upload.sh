#!/bin/bash

# Image Upload Test Script
# Tests the Azure Blob Storage image upload functionality

# Get dynamic codespace URL
CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
UPLOAD_API="https://${CODESPACE_NAME}-3001.app.github.dev/api/products/upload-image"
UPLOAD_IMAGES_API="https://${CODESPACE_NAME}-3001.app.github.dev/api/uploadimages/upload"
AUTH_API="https://${CODESPACE_NAME}-3001.app.github.dev/api/auth"

echo "🧪 Testing Image Upload to Azure Blob Storage"
echo "============================================="

# Step 1: Get authentication token (required for product upload endpoint)
echo "🔐 Step 1: Getting authentication token"
login_response=$(curl -s -X POST "$AUTH_API/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane.davis@example.com",
    "password": "Jane@Davis2024"
  }')

echo "Login response: $login_response"
token=$(echo $login_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$token" ]; then
    echo "❌ Could not get authentication token. Login response: $login_response"
    exit 1
fi

echo "✅ Authentication successful. Token: ${token:0:20}..."
echo ""

# Step 2: Create a test image file
echo "📷 Step 2: Creating test image file"
TEST_IMAGE="/tmp/test_image.png"

# Create a simple 100x100 PNG image using ImageMagick (if available) or base64
if command -v convert >/dev/null 2>&1; then
    convert -size 100x100 xc:lightblue -pointsize 20 -draw "text 10,50 'TEST'" "$TEST_IMAGE"
    echo "✅ Test image created using ImageMagick"
elif command -v base64 >/dev/null 2>&1; then
    # Create a minimal PNG file using base64 (1x1 transparent pixel)
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE"
    echo "✅ Minimal test image created using base64"
else
    echo "❌ Cannot create test image. ImageMagick or base64 not available."
    exit 1
fi

# Step 3: Test product upload endpoint (authenticated)
echo "📦 Step 3: Testing authenticated product upload endpoint"
product_upload_response=$(curl -s -X POST "$UPLOAD_API" \
  -H "Authorization: Bearer $token" \
  -F "image=@$TEST_IMAGE")

echo "Product upload response: $product_upload_response"

if echo "$product_upload_response" | grep -q '"imageUrl"'; then
    image_url=$(echo "$product_upload_response" | grep -o '"imageUrl":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Product upload successful! Image URL: $image_url"
else
    echo "❌ Product upload failed"
fi
echo ""

# Step 4: Test general upload images endpoint (no auth required)
echo "📸 Step 4: Testing general upload images endpoint"
general_upload_response=$(curl -s -X POST "$UPLOAD_IMAGES_API" \
  -F "image=@$TEST_IMAGE")

echo "General upload response: $general_upload_response"

if echo "$general_upload_response" | grep -q '"imageUrl"'; then
    image_url2=$(echo "$general_upload_response" | grep -o '"imageUrl":"[^"]*"' | cut -d'"' -f4)
    echo "✅ General upload successful! Image URL: $image_url2"
else
    echo "❌ General upload failed"
fi
echo ""

# Step 5: Test image accessibility
echo "🌐 Step 5: Testing image accessibility"
if [ ! -z "$image_url" ]; then
    echo "Testing product upload image accessibility..."
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "$image_url")
    if [ "$http_status" = "200" ]; then
        echo "✅ Product uploaded image is publicly accessible"
    else
        echo "❌ Product uploaded image returned HTTP $http_status"
    fi
fi

if [ ! -z "$image_url2" ]; then
    echo "Testing general upload image accessibility..."
    http_status2=$(curl -s -o /dev/null -w "%{http_code}" "$image_url2")
    if [ "$http_status2" = "200" ]; then
        echo "✅ General uploaded image is publicly accessible"
    else
        echo "❌ General uploaded image returned HTTP $http_status2"
    fi
fi

# Cleanup
rm -f "$TEST_IMAGE"

echo ""
echo "🎉 Image Upload Testing Complete!"
echo "================================="
