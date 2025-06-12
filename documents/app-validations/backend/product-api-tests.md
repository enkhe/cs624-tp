# Product API Testing

This guide contains curl commands for testing all product-related endpoints.

## Base URL and Authentication Setup
```bash
export API_BASE="http://localhost:3001/api"
export PRODUCTS_API="$API_BASE/products"

# Get authentication token
export TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: $TOKEN"
```

## Product CRUD Operations

### Create Product - Success Case
```bash
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Wireless Bluetooth Headphones",
    "description": "High-quality wireless headphones with noise cancellation",
    "price": 199.99,
    "stockQuantity": 50,
    "category": "Electronics",
    "brand": "TechBrand",
    "images": [
      "https://example.com/headphones1.jpg",
      "https://example.com/headphones2.jpg"
    ],
    "dimensions": {
      "length": 20,
      "width": 15,
      "height": 8
    },
    "weight": 0.3,
    "barcodes": ["1234567890123"],
    "isFeatured": true,
    "tags": ["wireless", "bluetooth", "noise-cancellation"]
  }' | jq '.'
```

### Create Product - Missing Required Fields
```bash
# Missing category (required field)
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Test Product",
    "description": "A test product",
    "price": 99.99,
    "stockQuantity": 10
  }' | jq '.'
```

### Create Product - Missing Name
```bash
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "description": "A product without name",
    "price": 99.99,
    "category": "Electronics"
  }' | jq '.'
```

### Create Product - Missing Price
```bash
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Product Without Price",
    "description": "A product without price",
    "category": "Electronics"
  }' | jq '.'
```

### Create Product - Field Name Compatibility Test (stockQuantity vs stock)
```bash
# Using stockQuantity (frontend format)
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Product with stockQuantity",
    "price": 99.99,
    "category": "Electronics",
    "stockQuantity": 25
  }' | jq '.'

# Using stock (backend format)
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Product with stock",
    "price": 99.99,
    "category": "Electronics",
    "stock": 30
  }' | jq '.'
```

### Get All Products
```bash
curl -X GET $PRODUCTS_API | jq '.'
```

### Get All Products with Count
```bash
curl -X GET $PRODUCTS_API | jq '. | length'
```

### Get Product by ID
```bash
# First create a product and get its ID
PRODUCT_ID=$(curl -s -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Product for ID Test",
    "price": 99.99,
    "category": "Test Category"
  }' | jq -r '._id')

echo "Created Product ID: $PRODUCT_ID"

# Get the product by ID
curl -X GET $PRODUCTS_API/$PRODUCT_ID | jq '.'
```

### Get Non-existent Product
```bash
# Try to get a product with invalid ID
curl -X GET $PRODUCTS_API/507f1f77bcf86cd799439011 | jq '.'
```

### Update Product - Full Update
```bash
# First create a product to update
PRODUCT_ID=$(curl -s -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Product to Update",
    "price": 50.00,
    "category": "Electronics"
  }' | jq -r '._id')

# Update the product
curl -X PUT $PRODUCTS_API/$PRODUCT_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Updated Product Name",
    "description": "Updated description with more details",
    "price": 75.00,
    "stock": 100,
    "category": "Updated Electronics",
    "brand": "Updated Brand",
    "images": [
      "https://example.com/updated1.jpg",
      "https://example.com/updated2.jpg"
    ],
    "isFeatured": true,
    "tags": ["updated", "new-features"]
  }' | jq '.'
```

### Update Product - Partial Update
```bash
# Update only specific fields
curl -X PUT $PRODUCTS_API/$PRODUCT_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "price": 85.00,
    "stock": 75
  }' | jq '.'
```

### Update Product Images Only
```bash
curl -X PUT $PRODUCTS_API/$PRODUCT_ID/images \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "images": [
      "https://example.com/newimage1.jpg",
      "https://example.com/newimage2.jpg",
      "https://example.com/newimage3.jpg"
    ]
  }' | jq '.'
```

### Delete Product
```bash
# Create a product to delete
DELETE_PRODUCT_ID=$(curl -s -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Product to Delete",
    "price": 25.00,
    "category": "Test"
  }' | jq -r '._id')

echo "Created Product to Delete: $DELETE_PRODUCT_ID"

# Delete the product
curl -X DELETE $PRODUCTS_API/$DELETE_PRODUCT_ID \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Verify deletion
curl -X GET $PRODUCTS_API/$DELETE_PRODUCT_ID | jq '.'
```

## Image Upload Testing

### Upload Image to Azure Blob Storage
```bash
# Create a test image file (1x1 pixel PNG)
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAGA3GQcOQAAAABJRU5ErkJggg==" | base64 -d > test-image.png

# Upload the image
curl -X POST $PRODUCTS_API/upload-image \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test-image.png" | jq '.'

# Clean up test file
rm test-image.png
```

### Test Image Upload without File
```bash
curl -X POST $PRODUCTS_API/upload-image \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Test Image Upload with Invalid File Type
```bash
# Create a text file
echo "This is not an image" > test-file.txt

# Try to upload it as an image
curl -X POST $PRODUCTS_API/upload-image \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test-file.txt" | jq '.'

# Clean up
rm test-file.txt
```

## Authorization Testing

### Test Unauthorized Product Creation
```bash
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Unauthorized Product",
    "price": 99.99,
    "category": "Electronics"
  }' | jq '.'
```

### Test Invalid Token
```bash
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token_here" \
  -d '{
    "name": "Product with Invalid Token",
    "price": 99.99,
    "category": "Electronics"
  }' | jq '.'
```

### Test Expired Token
```bash
# Use an expired token (you'll need to replace with an actual expired token)
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.expired.token" \
  -d '{
    "name": "Product with Expired Token",
    "price": 99.99,
    "category": "Electronics"
  }' | jq '.'
```

## Data Validation Testing

### Test Invalid Price Formats
```bash
# Negative price
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Negative Price Product",
    "price": -50.00,
    "category": "Electronics"
  }' | jq '.'

# String price
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "String Price Product",
    "price": "not-a-number",
    "category": "Electronics"
  }' | jq '.'

# Zero price
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Zero Price Product",
    "price": 0,
    "category": "Electronics"
  }' | jq '.'
```

### Test Invalid Stock Values
```bash
# Negative stock
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Negative Stock Product",
    "price": 99.99,
    "category": "Electronics",
    "stock": -10
  }' | jq '.'

# String stock
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "String Stock Product",
    "price": 99.99,
    "category": "Electronics",
    "stock": "not-a-number"
  }' | jq '.'
```

### Test Very Long Fields
```bash
# Very long name
LONG_NAME=$(printf 'A%.0s' {1..300})
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"$LONG_NAME\",
    \"price\": 99.99,
    \"category\": \"Electronics\"
  }" | jq '.'

# Very long description
LONG_DESC=$(printf 'This is a very long description %.0s' {1..100})
curl -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"name\": \"Long Description Product\",
    \"description\": \"$LONG_DESC\",
    \"price\": 99.99,
    \"category\": \"Electronics\"
  }" | jq '.'
```

## Comprehensive Product Testing Script

### Create Product Test Suite
```bash
cat > /workspaces/cs624-tp/app-validations/backend/test-products.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api"
PRODUCTS_API="$API_BASE/products"

echo "🛍️  Product API Testing"
echo "========================="

# Get authentication token
echo "Getting authentication token..."
TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to get authentication token"
    exit 1
fi

echo "✅ Token obtained"
echo ""

# Test 1: Create product with all required fields
echo "1. Testing product creation..."
echo "✅ Valid product creation:"
PRODUCT_ID=$(curl -s -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Test Product",
    "description": "A comprehensive test product",
    "price": 99.99,
    "stockQuantity": 50,
    "category": "Electronics",
    "brand": "TestBrand"
  }' | jq -r '._id // empty')

if [ -n "$PRODUCT_ID" ]; then
    echo "Product created successfully - ID: $PRODUCT_ID"
else
    echo "Failed to create product"
fi

echo ""
echo "❌ Missing required field (category):"
curl -s -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Incomplete Product",
    "price": 99.99
  }' | jq '.error'

# Test 2: Get all products
echo ""
echo "2. Testing product retrieval..."
PRODUCT_COUNT=$(curl -s -X GET $PRODUCTS_API | jq '. | length')
echo "✅ Retrieved $PRODUCT_COUNT products"

# Test 3: Get specific product
if [ -n "$PRODUCT_ID" ]; then
    echo ""
    echo "3. Testing specific product retrieval..."
    PRODUCT_NAME=$(curl -s -X GET $PRODUCTS_API/$PRODUCT_ID | jq -r '.name')
    echo "✅ Retrieved product: $PRODUCT_NAME"
fi

# Test 4: Update product
if [ -n "$PRODUCT_ID" ]; then
    echo ""
    echo "4. Testing product update..."
    curl -s -X PUT $PRODUCTS_API/$PRODUCT_ID \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "name": "Updated Test Product",
        "price": 149.99
      }' | jq '.name, .price'
fi

# Test 5: Test unauthorized access
echo ""
echo "5. Testing unauthorized access..."
echo "❌ No token:"
curl -s -X POST $PRODUCTS_API \
  -H "Content-Type: application/json" \
  -d '{"name":"Unauthorized Product","price":99.99,"category":"Electronics"}' \
  | jq '.error'

# Test 6: Delete product
if [ -n "$PRODUCT_ID" ]; then
    echo ""
    echo "6. Testing product deletion..."
    DELETE_RESULT=$(curl -s -X DELETE $PRODUCTS_API/$PRODUCT_ID \
      -H "Authorization: Bearer $TOKEN" | jq -r '.message')
    echo "✅ $DELETE_RESULT"
fi

echo ""
echo "🛍️  Product testing completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/test-products.sh
```

### Run Product Test Suite
```bash
./test-products.sh
```

## Performance Testing

### Test Multiple Product Creation
```bash
cat > /workspaces/cs624-tp/app-validations/backend/test-product-performance.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api"
PRODUCTS_API="$API_BASE/products"

# Get token
TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Creating 10 products for performance testing..."

for i in {1..10}; do
    echo -n "Creating product $i... "
    RESULT=$(curl -s -X POST $PRODUCTS_API \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"name\": \"Performance Test Product $i\",
        \"description\": \"Product $i for performance testing\",
        \"price\": $((50 + i * 10)),
        \"stockQuantity\": $((10 + i * 5)),
        \"category\": \"Performance Test\",
        \"brand\": \"TestBrand\"
      }")
    
    if echo "$RESULT" | jq -e '._id' > /dev/null; then
        echo "✅ Success"
    else
        echo "❌ Failed"
    fi
done

echo ""
echo "Performance test completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/test-product-performance.sh
```

## Environment Variables for Product Testing

```bash
# Set up product testing environment
export API_BASE="http://localhost:3001/api"
export PRODUCTS_API="$API_BASE/products"
export USER_TOKEN=$(curl -s -X POST $API_BASE/auth/login -H "Content-Type: application/json" -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Test product data
export TEST_PRODUCT_NAME="API Test Product"
export TEST_PRODUCT_PRICE="99.99"
export TEST_PRODUCT_CATEGORY="Electronics"

echo "Product testing environment ready!"
echo "API Base: $API_BASE"
echo "Products API: $PRODUCTS_API"
echo "Token: ${USER_TOKEN:0:50}..."
```
