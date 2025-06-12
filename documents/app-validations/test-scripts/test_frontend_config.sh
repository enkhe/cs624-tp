#!/bin/bash

# Simple frontend image upload test from React Native perspective

CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
API_BASE="https://${CODESPACE_NAME}-3001.app.github.dev/api"

echo "🧪 Testing Frontend Image Upload Configuration"
echo "============================================="
echo "API_BASE: $API_BASE"
echo ""

# Test if the API is reachable
echo "🌐 Step 1: Testing API connectivity"
api_response=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/../")
if [ "$api_response" = "200" ]; then
    echo "✅ API server is reachable"
else
    echo "❌ API server returned HTTP $api_response"
fi
echo ""

# Test CORS headers
echo "🔗 Step 2: Testing CORS headers"
cors_response=$(curl -s -I -H "Origin: http://localhost:8081" "$API_BASE/uploadimages/upload")
if echo "$cors_response" | grep -i "access-control-allow-origin"; then
    echo "✅ CORS headers present"
else
    echo "❌ CORS headers missing"
fi
echo ""

# Test uploadimages endpoint directly
echo "📤 Step 3: Testing uploadimages endpoint"
# Create a simple test image
TEST_IMAGE="/tmp/frontend_test.png"
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE"

upload_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
  -F "image=@$TEST_IMAGE")

echo "Upload response: $upload_response"

if echo "$upload_response" | grep -q '"imageUrl"'; then
    echo "✅ Direct upload test successful"
else
    echo "❌ Direct upload test failed"
fi

# Cleanup
rm -f "$TEST_IMAGE"

echo ""
echo "🎉 Frontend Configuration Test Complete!"
