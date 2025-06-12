# Post API Testing

This guide contains curl commands for testing all post-related endpoints (social media functionality).

## Base URL and Authentication Setup
```bash
export API_BASE="http://localhost:3001/api"
export POSTS_API="$API_BASE/posts"

# Get authentication token
export TOKEN=$(curl -s -X POST $API_BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: ${TOKEN:0:50}..."
```

## Post CRUD Operations

### Create Post - Text Only
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "This is my first post! Testing the social media functionality.",
    "tags": ["test", "social", "first-post"]
  }' | jq '.'
```

### Create Post - With Image
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Check out this awesome product! 📱",
    "imageUrl": "https://example.com/product-image.jpg",
    "tags": ["product", "electronics", "awesome"]
  }' | jq '.'
```

### Create Post - With Location
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Shopping at the best electronics store in town!",
    "location": "Downtown Electronics Store",
    "tags": ["shopping", "electronics", "store"]
  }' | jq '.'
```

### Create Post - Complete Post
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Just bought amazing wireless headphones! The sound quality is incredible. Highly recommend for music lovers. 🎧🎵",
    "imageUrl": "https://example.com/headphones-review.jpg",
    "location": "Tech Store",
    "tags": ["headphones", "music", "review", "recommendation", "wireless"]
  }' | jq '.'
```

### Get All Posts
```bash
curl -X GET $POSTS_API | jq '.'
```

### Get All Posts - Count Only
```bash
curl -X GET $POSTS_API | jq '. | length'
```

### Get All Posts - Recent Posts Only
```bash
curl -X GET $POSTS_API | jq 'sort_by(.createdAt) | reverse | .[0:5]'
```

### Get Post by ID
```bash
# First create a post and get its ID
POST_ID=$(curl -s -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Post for ID testing",
    "tags": ["test"]
  }' | jq -r '._id')

echo "Created Post ID: $POST_ID"

# Get the post by ID
curl -X GET $POSTS_API/$POST_ID | jq '.'
```

### Get Non-existent Post
```bash
curl -X GET $POSTS_API/507f1f77bcf86cd799439011 | jq '.'
```

## Post Deletion

### Delete Post
```bash
# Create a post to delete
DELETE_POST_ID=$(curl -s -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "This post will be deleted",
    "tags": ["temporary"]
  }' | jq -r '._id')

echo "Created Post to Delete: $DELETE_POST_ID"

# Delete the post
curl -X DELETE $POSTS_API/remove/$DELETE_POST_ID \
  -H "Authorization: Bearer $TOKEN" | jq '.'

# Verify deletion
curl -X GET $POSTS_API/$DELETE_POST_ID | jq '.'
```

### Delete Non-existent Post
```bash
curl -X DELETE $POSTS_API/remove/507f1f77bcf86cd799439011 \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Delete Post - Unauthorized
```bash
# Try to delete without token
curl -X DELETE $POSTS_API/remove/$DELETE_POST_ID | jq '.'
```

## AI-Generated Posts

### Create AI Post
```bash
curl -X POST $POSTS_API/createAI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "prompt": "Create a post about the latest smartphone technology trends"
  }' | jq '.'
```

### Create AI Post - Product Related
```bash
curl -X POST $POSTS_API/createAI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "prompt": "Write a review post about wireless headphones focusing on sound quality and comfort"
  }' | jq '.'
```

### Create AI Post - Promotional
```bash
curl -X POST $POSTS_API/createAI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "prompt": "Create an engaging social media post about a summer electronics sale"
  }' | jq '.'
```

### Create AI Post - Technical
```bash
curl -X POST $POSTS_API/createAI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "prompt": "Explain the benefits of noise-canceling technology in headphones in a social media post format"
  }' | jq '.'
```

## Image Upload for Posts

### Upload Image for Post
```bash
# Create a test image file (1x1 pixel PNG)
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAGA3GQcOQAAAABJRU5ErkJggg==" | base64 -d > post-image.png

# Upload the image
curl -X POST $POSTS_API/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@post-image.png" | jq '.'

# Clean up test file
rm post-image.png
```

### Upload Image - No File
```bash
curl -X POST $POSTS_API/upload \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

### Upload Image - Invalid File Type
```bash
# Create a text file
echo "This is not an image" > invalid-file.txt

# Try to upload it
curl -X POST $POSTS_API/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@invalid-file.txt" | jq '.'

# Clean up
rm invalid-file.txt
```

## Data Validation Tests

### Create Post - Missing Text
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "tags": ["test"]
  }' | jq '.'
```

### Create Post - Empty Text
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "",
    "tags": ["test"]
  }' | jq '.'
```

### Create Post - Very Long Text
```bash
LONG_TEXT=$(printf 'This is a very long post text %.0s' {1..100})
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"text\": \"$LONG_TEXT\",
    \"tags\": [\"long-text\"]
  }" | jq '.'
```

### Create Post - Invalid Image URL
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Post with invalid image URL",
    "imageUrl": "not-a-valid-url",
    "tags": ["test"]
  }' | jq '.'
```

### Create Post - Too Many Tags
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Post with many tags",
    "tags": ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7", "tag8", "tag9", "tag10", "tag11", "tag12", "tag13", "tag14", "tag15"]
  }' | jq '.'
```

## Authorization Tests

### Create Post - No Token
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Unauthorized post attempt",
    "tags": ["unauthorized"]
  }' | jq '.'
```

### Create Post - Invalid Token
```bash
curl -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token_here" \
  -d '{
    "text": "Post with invalid token",
    "tags": ["invalid"]
  }' | jq '.'
```

### Create AI Post - No Token
```bash
curl -X POST $POSTS_API/createAI \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Unauthorized AI post"
  }' | jq '.'
```

## Post Filtering and Search

### Filter Posts by Tag
```bash
# Get all posts and filter by tag
curl -X GET $POSTS_API | jq '.[] | select(.tags[]? == "test")'
```

### Filter Posts by Author
```bash
# Get posts by specific user (you'll need to replace with actual user ID)
curl -X GET $POSTS_API | jq '.[] | select(.user == "6818972aa57d11c40e7ec830")'
```

### Filter Posts with Images
```bash
# Get only posts that have images
curl -X GET $POSTS_API | jq '.[] | select(.imageUrl != null and .imageUrl != "")'
```

### Filter Posts by Date Range
```bash
# Get posts from today (adjust date as needed)
TODAY=$(date -I)
curl -X GET $POSTS_API | jq ".[] | select(.createdAt | startswith(\"$TODAY\"))"
```

### Get Posts with Location
```bash
# Get posts that have location information
curl -X GET $POSTS_API | jq '.[] | select(.location != null and .location != "")'
```

## Post Analytics

### Get Post Statistics
```bash
echo "Post Analytics:"
echo "=============="

TOTAL_POSTS=$(curl -s -X GET $POSTS_API | jq '. | length')
echo "Total posts: $TOTAL_POSTS"

POSTS_WITH_IMAGES=$(curl -s -X GET $POSTS_API | jq '[.[] | select(.imageUrl != null and .imageUrl != "")] | length')
echo "Posts with images: $POSTS_WITH_IMAGES"

POSTS_WITH_LOCATION=$(curl -s -X GET $POSTS_API | jq '[.[] | select(.location != null and .location != "")] | length')
echo "Posts with location: $POSTS_WITH_LOCATION"

TOTAL_TAGS=$(curl -s -X GET $POSTS_API | jq '[.[].tags[]?] | length')
echo "Total tags used: $TOTAL_TAGS"

UNIQUE_TAGS=$(curl -s -X GET $POSTS_API | jq '[.[].tags[]?] | unique | length')
echo "Unique tags: $UNIQUE_TAGS"
```

### Get Most Popular Tags
```bash
echo "Most Popular Tags:"
curl -s -X GET $POSTS_API | jq '[.[].tags[]?] | group_by(.) | map({tag: .[0], count: length}) | sort_by(.count) | reverse | .[0:10]'
```

## Performance Tests

### Create Multiple Posts Performance
```bash
echo "Testing post creation performance..."
for i in {1..5}; do
    echo -n "Creating post $i... "
    START_TIME=$(date +%s.%N)
    curl -s -X POST $POSTS_API \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"text\": \"Performance test post number $i\",
        \"tags\": [\"performance\", \"test$i\"]
      }" > /dev/null
    END_TIME=$(date +%s.%N)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)
    echo "Done in ${DURATION}s"
done
```

### Bulk Post Retrieval Performance
```bash
echo "Testing bulk post retrieval performance..."
START_TIME=$(date +%s.%N)
POST_COUNT=$(curl -s -X GET $POSTS_API | jq '. | length')
END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)
echo "Retrieved $POST_COUNT posts in ${DURATION}s"
```

## Comprehensive Post Testing Script

### Create Post Test Suite
```bash
cat > /workspaces/cs624-tp/app-validations/backend/test-posts.sh << 'EOF'
#!/bin/bash

API_BASE="http://localhost:3001/api"
POSTS_API="$API_BASE/posts"

echo "📝 Post API Testing"
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

# Test 1: Create simple post
echo "1. Testing post creation..."
POST_ID=$(curl -s -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "text": "Test post from automated testing",
    "tags": ["automation", "test"]
  }' | jq -r '._id // empty')

if [ -n "$POST_ID" ]; then
    echo "✅ Post created successfully - ID: $POST_ID"
else
    echo "❌ Failed to create post"
fi

# Test 2: Get all posts
echo ""
echo "2. Testing post retrieval..."
POST_COUNT=$(curl -s -X GET $POSTS_API | jq '. | length')
echo "✅ Retrieved $POST_COUNT posts"

# Test 3: Get specific post
if [ -n "$POST_ID" ]; then
    echo ""
    echo "3. Testing specific post retrieval..."
    POST_TEXT=$(curl -s -X GET $POSTS_API/$POST_ID | jq -r '.text')
    if [ "$POST_TEXT" != "null" ]; then
        echo "✅ Retrieved specific post: ${POST_TEXT:0:50}..."
    else
        echo "❌ Failed to retrieve specific post"
    fi
fi

# Test 4: Test AI post creation
echo ""
echo "4. Testing AI post creation..."
AI_POST_ID=$(curl -s -X POST $POSTS_API/createAI \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"prompt": "Create a short post about technology"}' \
  | jq -r '._id // empty')

if [ -n "$AI_POST_ID" ]; then
    echo "✅ AI post created successfully"
else
    echo "❌ Failed to create AI post"
fi

# Test 5: Test unauthorized access
echo ""
echo "5. Testing unauthorized access..."
ERROR_MSG=$(curl -s -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -d '{"text": "Unauthorized post"}' \
  | jq -r '.error // empty')

if [ -n "$ERROR_MSG" ]; then
    echo "✅ Unauthorized access correctly blocked: $ERROR_MSG"
else
    echo "❌ Unauthorized access not properly blocked"
fi

# Test 6: Test post deletion
if [ -n "$POST_ID" ]; then
    echo ""
    echo "6. Testing post deletion..."
    DELETE_RESULT=$(curl -s -X DELETE $POSTS_API/remove/$POST_ID \
      -H "Authorization: Bearer $TOKEN" \
      | jq -r '.message // .error')
    echo "✅ Delete result: $DELETE_RESULT"
fi

# Test 7: Test empty post validation
echo ""
echo "7. Testing empty post validation..."
ERROR_MSG=$(curl -s -X POST $POSTS_API \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"text": ""}' \
  | jq -r '.error // empty')

if [ -n "$ERROR_MSG" ]; then
    echo "✅ Empty post correctly rejected: $ERROR_MSG"
else
    echo "❌ Empty post validation failed"
fi

echo ""
echo "📝 Post testing completed!"
EOF

chmod +x /workspaces/cs624-tp/app-validations/backend/test-posts.sh
```

### Run Post Test Suite
```bash
./test-posts.sh
```

## Environment Variables for Post Testing

```bash
# Set up post testing environment
export API_BASE="http://localhost:3001/api"
export POSTS_API="$API_BASE/posts"
export POST_TOKEN=$(curl -s -X POST $API_BASE/auth/login -H "Content-Type: application/json" -d '{"email":"john.doe@example.com","password":"SecurePass123!"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Test post data
export TEST_POST_TEXT="This is a test post from the API testing suite"
export TEST_POST_TAGS='["test", "api", "automation"]'
export TEST_AI_PROMPT="Create a post about the latest technology trends"

echo "Post testing environment ready!"
echo "Posts API: $POSTS_API"
echo "Token: ${POST_TOKEN:0:50}..."

# Quick post creation function
create_test_post() {
    local text="$1"
    local tags="$2"
    curl -s -X POST $POSTS_API \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $POST_TOKEN" \
      -d "{\"text\": \"$text\", \"tags\": $tags}" | jq '.'
}

echo ""
echo "Usage: create_test_post 'Your post text' '[\"tag1\", \"tag2\"]'"
```
