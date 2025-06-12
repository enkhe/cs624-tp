#!/bin/bash

# Comprehensive Frontend Image Upload Debug Test
# This script tests every component of the image upload pipeline

CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
API_BASE="https://${CODESPACE_NAME}-3001.app.github.dev/api"

echo "🔍 === COMPREHENSIVE IMAGE UPLOAD DEBUG TEST ==="
echo "============================================="
echo "🌐 API_BASE: $API_BASE"
echo "⏰ Test started at: $(date)"
echo ""

# Test 1: Basic connectivity
echo "🌐 TEST 1: Basic API Connectivity"
echo "--------------------------------"
echo "Testing: GET $API_BASE/../"
api_response=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/../")
echo "Status code: $api_response"
if [ "$api_response" = "200" ]; then
    echo "✅ PASS: API server is reachable"
else
    echo "❌ FAIL: API server returned HTTP $api_response"
    echo "🚨 This suggests the backend is not running or not accessible"
fi
echo ""

# Test 2: Upload endpoint availability
echo "🔌 TEST 2: Upload Endpoint Availability"
echo "---------------------------------------"
echo "Testing: OPTIONS $API_BASE/uploadimages/upload"
options_response=$(curl -s -X OPTIONS -o /dev/null -w "%{http_code}" "$API_BASE/uploadimages/upload")
echo "Status code: $options_response"
if [ "$options_response" = "200" ] || [ "$options_response" = "404" ]; then
    echo "✅ PASS: Upload endpoint is reachable"
else
    echo "❌ FAIL: Upload endpoint returned HTTP $options_response"
fi
echo ""

# Test 3: CORS headers
echo "🔗 TEST 3: CORS Configuration"
echo "-----------------------------"
echo "Testing CORS headers for React Native origin..."
cors_response=$(curl -s -I -H "Origin: http://localhost:8081" "$API_BASE/uploadimages/upload")
echo "CORS Response Headers:"
echo "$cors_response" | grep -i "access-control"
if echo "$cors_response" | grep -qi "access-control-allow-origin"; then
    echo "✅ PASS: CORS headers are present"
else
    echo "❌ FAIL: CORS headers missing"
    echo "🚨 This could block React Native requests"
fi
echo ""

# Test 4: Create test images
echo "📸 TEST 4: Creating Test Images"
echo "-------------------------------"
TEST_IMAGE_SMALL="/tmp/test_small.png"
TEST_IMAGE_LARGE="/tmp/test_large.png"

# Create a small 1x1 PNG (minimal valid image)
echo "Creating small test image..."
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE_SMALL"

# Create a larger test image if ImageMagick is available
if command -v convert >/dev/null 2>&1; then
    echo "Creating larger test image with ImageMagick..."
    convert -size 500x500 xc:lightblue -pointsize 30 -draw "text 50,250 'UPLOAD TEST'" "$TEST_IMAGE_LARGE"
    echo "✅ Both test images created"
else
    echo "⚠️ ImageMagick not available, using small image only"
    cp "$TEST_IMAGE_SMALL" "$TEST_IMAGE_LARGE"
fi

echo "Test image details:"
ls -la /tmp/test_*.png
echo ""

# Test 5: Direct file upload (small image)
echo "📤 TEST 5: Direct File Upload (Small Image)"
echo "-------------------------------------------"
echo "Testing: POST $API_BASE/uploadimages/upload (small image)"
upload_response_small=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
    -H "Accept: application/json" \
    -F "image=@$TEST_IMAGE_SMALL" \
    -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n")

echo "Upload Response (Small):"
echo "$upload_response_small"

if echo "$upload_response_small" | grep -q '"imageUrl"'; then
    echo "✅ PASS: Small image upload successful"
    small_url=$(echo "$upload_response_small" | grep -o '"imageUrl":"[^"]*"' | cut -d'"' -f4)
    echo "🔗 URL: $small_url"
else
    echo "❌ FAIL: Small image upload failed"
    echo "🚨 This suggests a server-side issue"
fi
echo ""

# Test 6: Direct file upload (larger image)
echo "📤 TEST 6: Direct File Upload (Larger Image)"
echo "--------------------------------------------"
echo "Testing: POST $API_BASE/uploadimages/upload (larger image)"
upload_response_large=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
    -H "Accept: application/json" \
    -F "image=@$TEST_IMAGE_LARGE" \
    -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n")

echo "Upload Response (Large):"
echo "$upload_response_large"

if echo "$upload_response_large" | grep -q '"imageUrl"'; then
    echo "✅ PASS: Large image upload successful"
    large_url=$(echo "$upload_response_large" | grep -o '"imageUrl":"[^"]*"' | cut -d'"' -f4)
    echo "🔗 URL: $large_url"
else
    echo "❌ FAIL: Large image upload failed"
    echo "🚨 This might indicate size or processing issues"
fi
echo ""

# Test 7: Invalid file type
echo "🚫 TEST 7: Invalid File Type Handling"
echo "-------------------------------------"
echo "Testing upload with text file..."
echo "This is not an image" > /tmp/test_invalid.txt
invalid_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
    -F "image=@/tmp/test_invalid.txt")

echo "Invalid file response:"
echo "$invalid_response"

if echo "$invalid_response" | grep -qi "error\|invalid"; then
    echo "✅ PASS: Invalid file type properly rejected"
else
    echo "❌ FAIL: Invalid file type not properly handled"
fi
rm -f /tmp/test_invalid.txt
echo ""

# Test 8: Missing file parameter
echo "🚫 TEST 8: Missing File Parameter"
echo "---------------------------------"
echo "Testing upload without file parameter..."
no_file_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
    -H "Content-Type: multipart/form-data")

echo "No file response:"
echo "$no_file_response"

if echo "$no_file_response" | grep -qi "error\|file"; then
    echo "✅ PASS: Missing file properly handled"
else
    echo "❌ FAIL: Missing file not properly handled"
fi
echo ""

# Test 9: Image accessibility
echo "🌐 TEST 9: Uploaded Image Accessibility"
echo "---------------------------------------"
if [ ! -z "$small_url" ]; then
    echo "Testing accessibility of uploaded image..."
    accessibility_status=$(curl -s -o /dev/null -w "%{http_code}" "$small_url")
    echo "Image accessibility status: $accessibility_status"
    
    if [ "$accessibility_status" = "200" ]; then
        echo "✅ PASS: Uploaded image is publicly accessible"
    else
        echo "❌ FAIL: Uploaded image returned HTTP $accessibility_status"
        echo "🚨 This suggests Azure storage configuration issues"
    fi
else
    echo "⚠️ SKIP: No valid image URL to test"
fi
echo ""

# Test 10: React Native simulation
echo "📱 TEST 10: React Native Request Simulation"
echo "-------------------------------------------"
echo "Simulating React Native FormData request..."
rn_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
    -H "Accept: application/json" \
    -H "User-Agent: React Native" \
    -F "image=@$TEST_IMAGE_SMALL;type=image/png" \
    -w "\nHTTP_CODE:%{http_code}\n")

echo "React Native simulation response:"
echo "$rn_response"

if echo "$rn_response" | grep -q '"imageUrl"'; then
    echo "✅ PASS: React Native style request successful"
else
    echo "❌ FAIL: React Native style request failed"
    echo "🚨 This suggests React Native specific issues"
fi
echo ""

# Cleanup
rm -f "$TEST_IMAGE_SMALL" "$TEST_IMAGE_LARGE"

# Summary
echo "📊 === TEST SUMMARY ==="
echo "======================"
echo "⏰ Test completed at: $(date)"
echo ""
echo "🔍 DEBUGGING RECOMMENDATIONS:"
echo "-----------------------------"
echo "1. Check backend logs for detailed error messages"
echo "2. Verify Azure Blob Storage configuration"
echo "3. Test with React Native debugger/console"
echo "4. Check network connectivity from device/simulator"
echo "5. Verify file picker is returning proper asset format"
echo ""
echo "🎯 NEXT STEPS:"
echo "-------------"
echo "• If all tests pass: Issue is in React Native app code"
echo "• If upload tests fail: Issue is in backend/Azure config"
echo "• If CORS tests fail: Issue is in server CORS setup"
echo "• If connectivity fails: Issue is in network/server setup"
