#!/bin/bash

# Product Creation Test Script
# Demonstrates how to authenticate and create a product

# Get dynamic codespace URL
CODESPACE_NAME=${CODESPACE_NAME:-"potential-dollop-rwp5x94j6v2pxw5"}
API_BASE="https://${CODESPACE_NAME}-3001.app.github.dev/api/products"
AUTH_API="https://${CODESPACE_NAME}-3001.app.github.dev/api/auth"

echo "🧪 Testing Product Creation with Authentication"
echo "=============================================="

# Step 1: Get authentication token
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
    echo "⚠️ Admin login failed, trying with regular user..."
    login_response=$(curl -s -X POST "$AUTH_API/login" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "john.doe@example.com",
        "password": "SecurePass123!"
      }')
    token=$(echo $login_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
fi

if [ -z "$token" ]; then
    echo "❌ Could not get authentication token. Login response: $login_response"
    exit 1
fi

echo "✅ Authentication successful. Token: ${token:0:20}..."
echo ""

# Step 2: Create product with authentication
echo "📦 Step 2: Creating product with authentication"
create_response=$(curl -s -X POST $API_BASE \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "name": "product 01",
    "description": "product desc",
    "price": 1000,
    "stockQuantity": 3,
    "images": ["https://via.placeholder.com/400x300?text=No+Image"],
    "brand": "sony",
    "category": "electronics"
  }')

echo "Create Response: $create_response"

# Check if product was created successfully
if echo $create_response | grep -q '"_id"'; then
    product_id=$(echo $create_response | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Product created successfully with ID: $product_id"
else
    echo "❌ Product creation failed"
fi

echo ""
echo "🎉 Product Creation Test Complete!"
