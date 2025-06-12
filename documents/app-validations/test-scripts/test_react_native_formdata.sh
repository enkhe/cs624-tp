#!/bin/bash

# Test script to simulate React Native FormData [Object object] issue

CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
API_BASE="https://${CODESPACE_NAME}-3001.app.github.dev/api"

echo "🧪 React Native FormData [Object object] Debug Test"
echo "=================================================="
echo "🌐 API_BASE: $API_BASE"
echo ""

# Create test image
TEST_IMAGE="/tmp/rn_test.png"
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE"

echo "📤 Test 1: Standard multipart/form-data (should work)"
echo "----------------------------------------------------"
standard_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
  -F "image=@$TEST_IMAGE" \
  -w "\nHTTP_CODE:%{http_code}\n")

echo "Standard upload response:"
echo "$standard_response"
echo ""

echo "📤 Test 2: Malformed FormData simulation ([Object object] issue)"
echo "---------------------------------------------------------------"
# Try to simulate what might be happening when React Native sends [Object object]
malformed_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
  -H "Content-Type: multipart/form-data; boundary=----formdata-react-native" \
  -d $'------formdata-react-native\r\nContent-Disposition: form-data; name="image"\r\n\r\n[object Object]\r\n------formdata-react-native--\r\n' \
  -w "\nHTTP_CODE:%{http_code}\n")

echo "Malformed upload response:"
echo "$malformed_response"
echo ""

echo "📤 Test 3: Empty file field simulation"
echo "-------------------------------------"
empty_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
  -F "image=" \
  -w "\nHTTP_CODE:%{http_code}\n")

echo "Empty field response:"
echo "$empty_response"
echo ""

echo "📤 Test 4: Text instead of file simulation"
echo "-----------------------------------------"
text_response=$(curl -s -X POST "$API_BASE/uploadimages/upload" \
  -F "image=[object Object]" \
  -w "\nHTTP_CODE:%{http_code}\n")

echo "Text field response:"
echo "$text_response"
echo ""

# Cleanup
rm -f "$TEST_IMAGE"

echo "🎯 ANALYSIS:"
echo "============"
echo "If Test 1 works but your React Native app doesn't:"
echo "• The issue is in the FormData object creation in React Native"
echo "• Check the asset object properties (uri, type, name)"
echo "• Verify the FormData.append() call format"
echo ""
echo "Look for these patterns in backend logs:"
echo "• 'No file object found in request' = FormData not properly formatted"
echo "• 'req.file exists: false' = Image not being sent as file"
echo "• '[object Object]' in body = Object being converted to string"
