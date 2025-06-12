# Chat API Testing

This guide contains curl commands for testing the AI chat functionality.

## Base URL and Authentication Setup
```bash
export API_BASE="http://localhost:3001/api"
export CHAT_API="$API_BASE/chat"

# Get authentication token
export TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: ${TOKEN:0:50}..."
```

## Basic Chat Operations

### Simple Chat Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Hello, can you help me with product information?"
  }' | jq '.'
```

### Product-Related Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What electronics products do you have available?"
  }' | jq '.'
```

### Specific Product Search
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Do you have any headphones or audio equipment?"
  }' | jq '.'
```

### Price Range Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Show me products under $100"
  }' | jq '.'
```

### Brand-Specific Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What Sony products are available?"
  }' | jq '.'
```

## Advanced Chat Queries

### Multi-Parameter Search
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "I need wireless headphones under $200 from a good brand"
  }' | jq '.'
```

### Feature-Based Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Show me products with noise cancellation feature"
  }' | jq '.'
```

### Comparison Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Compare wireless headphones vs wired headphones"
  }' | jq '.'
```

### Recommendation Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Recommend me a good laptop for programming"
  }' | jq '.'
```

### Category-Based Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What categories of products do you have?"
  }' | jq '.'
```

## Error Handling Tests

### Empty Message
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": ""
  }' | jq '.'
```

### Missing Message Field
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}' | jq '.'
```

### Very Long Message
```bash
LONG_MESSAGE=$(printf 'This is a very long message %.0s' {1..100})
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"message\": \"$LONG_MESSAGE\"
  }" | jq '.'
```

### Special Characters in Message
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Hello! @#$%^&*()_+ Can you help with products? 中文 العربية"
  }' | jq '.'
```

### Malformed JSON
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "test message",
    "invalid": 
  }' | jq '.'
```

## Authorization Tests

### Unauthorized Chat Request
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello without token"
  }' | jq '.'
```

### Invalid Token
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token_here" \
  -d '{
    "message": "Hello with invalid token"
  }' | jq '.'
```

### Expired Token Test
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.expired.token" \
  -d '{
    "message": "Hello with expired token"
  }' | jq '.'
```

## Streaming Chat Tests (if supported)

### Test Streaming Response
```bash
# Note: Streaming might require different handling
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: text/event-stream" \
  -d '{
    "message": "Give me a detailed explanation of your product catalog",
    "stream": true
  }'
```

### Test Non-Streaming Response
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Give me a quick product overview",
    "stream": false
  }' | jq '.'
```

## Performance Tests

### Response Time Test
```bash
echo "Testing chat response time:"
time curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What products do you have?"
  }' > /dev/null
```

### Concurrent Chat Requests
```bash
echo "Testing concurrent chat requests:"
for i in {1..5}; do
    curl -X POST $CHAT_API \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"message\": \"Concurrent test message $i\"
      }" &
done
wait
echo "All concurrent requests completed"
```

### Large Query Test
```bash
# Test with a complex, detailed query
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "I am looking for a comprehensive analysis of all your electronic products, including detailed specifications, pricing information, availability status, brand comparisons, feature analysis, and recommendations based on different use cases such as gaming, professional work, casual use, and budget considerations. Please provide detailed information about each category."
  }' | jq '.'
```

## Content and Context Tests

### Follow-up Questions
```bash
# First message
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Show me headphones"
  }' | jq '.'

echo "Waiting 2 seconds for follow-up..."
sleep 2

# Follow-up message
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What about wireless ones?"
  }' | jq '.'
```

### Technical Questions
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What are the technical specifications of your most expensive product?"
  }' | jq '.'
```

### Shopping Assistant Queries
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "I have a budget of $500. What complete setup can you recommend for a home office?"
  }' | jq '.'
```

### Inventory Questions
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "What items are currently in stock?"
  }' | jq '.'
```

## RAG (Retrieval-Augmented Generation) Tests

### Product Database Query
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Tell me about the most popular products in your database"
  }' | jq '.'
```

### Specific Product Lookup
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Find products with ID or name containing test"
  }' | jq '.'
```

### Vector Search Test
```bash
curl -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "Find similar products to wireless bluetooth headphones"
  }' | jq '.'
```

## Comprehensive Chat Testing Script

### Create Chat Test Suite
```bash
cat > /workspaces/cs624-tp/app-validations/backend/test-chat.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api"
CHAT_API="$API_BASE/chat"

echo "🤖 Chat API Testing"
echo "==================="

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

# Test 1: Basic chat functionality
echo "1. Testing basic chat functionality..."
RESPONSE=$(curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"message": "Hello, can you help me?"}')

if echo "$RESPONSE" | jq -e '.response' > /dev/null 2>&1; then
    echo "✅ Basic chat working"
    echo "Response preview: $(echo "$RESPONSE" | jq -r '.response' | cut -c1-100)..."
else
    echo "❌ Basic chat failed"
    echo "Error: $(echo "$RESPONSE" | jq -r '.error // "Unknown error"')"
fi

# Test 2: Product-related query
echo ""
echo "2. Testing product-related query..."
RESPONSE=$(curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"message": "What products do you have?"}')

if echo "$RESPONSE" | jq -e '.response' > /dev/null 2>&1; then
    echo "✅ Product query working"
else
    echo "❌ Product query failed"
fi

# Test 3: Empty message handling
echo ""
echo "3. Testing empty message handling..."
RESPONSE=$(curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"message": ""}')

ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // empty')
if [ -n "$ERROR_MSG" ]; then
    echo "✅ Empty message correctly rejected: $ERROR_MSG"
else
    echo "❌ Empty message not properly handled"
fi

# Test 4: Unauthorized access
echo ""
echo "4. Testing unauthorized access..."
RESPONSE=$(curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello without token"}')

ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // empty')
if [ -n "$ERROR_MSG" ]; then
    echo "✅ Unauthorized access correctly blocked: $ERROR_MSG"
else
    echo "❌ Unauthorized access not properly blocked"
fi

# Test 5: Response time
echo ""
echo "5. Testing response time..."
START_TIME=$(date +%s.%N)
curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"message": "Quick test"}' > /dev/null
END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)
echo "✅ Response time: ${DURATION}s"

# Test 6: Special characters handling
echo ""
echo "6. Testing special characters..."
RESPONSE=$(curl -s -X POST $CHAT_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"message": "Test with special chars: @#$%^&*()"}')

if echo "$RESPONSE" | jq -e '.response' > /dev/null 2>&1; then
    echo "✅ Special characters handled correctly"
else
    echo "❌ Special characters caused issues"
fi

echo ""
echo "🤖 Chat testing completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/test-chat.sh
```

### Run Chat Test Suite
```bash
./test-chat.sh
```

## Chat Conversation Simulation

### Simulate Shopping Conversation
```bash
cat > /workspaces/cs624-tp/app-validations/backend/simulate-shopping-chat.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api"
CHAT_API="$API_BASE/chat"

# Get token
TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "🛒 Simulating Shopping Conversation"
echo "==================================="

# Conversation flow
messages=(
    "Hello, I'm looking for electronics"
    "Do you have any headphones?"
    "What's the price range for your headphones?"
    "Show me wireless headphones under $200"
    "What brands do you carry?"
    "Can you recommend something for gaming?"
    "What about the warranty on these products?"
    "Are these items in stock?"
    "Thank you for your help!"
)

for i in "${!messages[@]}"; do
    echo ""
    echo "Message $((i+1)): ${messages[i]}"
    echo "Response:"
    curl -s -X POST $CHAT_API \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{\"message\": \"${messages[i]}\"}" | jq -r '.response // .error'
    
    # Small delay between messages
    sleep 1
done

echo ""
echo "🛒 Shopping conversation simulation completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/simulate-shopping-chat.sh
```

## Environment Variables for Chat Testing

```bash
# Set up chat testing environment
export API_BASE="http://localhost:3001/api"
export CHAT_API="$API_BASE/chat"
export CHAT_TOKEN=$(curl -s -X POST $API_BASE/auth/login -H "Content-Type: application/json" -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Test messages
export SIMPLE_MESSAGE="Hello, can you help me?"
export PRODUCT_MESSAGE="What products do you have available?"
export COMPLEX_MESSAGE="I need a wireless headphone under 200 dollars for gaming"

echo "Chat testing environment ready!"
echo "Chat API: $CHAT_API"
echo "Token: ${CHAT_TOKEN:0:50}..."

# Quick test function
test_chat() {
    local message="$1"
    curl -s -X POST $CHAT_API \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $CHAT_TOKEN" \
      -d "{\"message\": \"$message\"}" | jq -r '.response // .error'
}

echo ""
echo "Usage: test_chat 'Your message here'"
```
