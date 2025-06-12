# Backend API Testing Suite

This directory contains comprehensive testing guides for all backend API endpoints and service management.

## 📁 Directory Structure

```
app-validations/backend/
├── README.md                    # This file - overview and navigation
├── service-management.md        # Backend service start/stop/status commands
├── auth-api-tests.md           # Authentication endpoints testing
├── product-api-tests.md        # Product CRUD operations testing
├── user-api-tests.md           # User management and admin features testing
├── chat-api-tests.md           # AI chatbot functionality testing
├── post-api-tests.md           # Social media posts API testing
└── complete-test-suite.md      # All tests in one file with automation scripts
```

## 📋 Testing Categories

### Core API Testing
- **[Authentication](auth-api-tests.md)** - Login, register, token validation
- **[Products](product-api-tests.md)** - CRUD operations, validation, search
- **[Users](user-api-tests.md)** - User management, admin access control
- **[Chat](chat-api-tests.md)** - AI chatbot interactions
- **[Posts](post-api-tests.md)** - Social media functionality

### Service Management
- **[Service Management](service-management.md)** - Start/stop/status operations

### Complete Testing
- **[Complete Test Suite](complete-test-suite.md)** - All tests with automation scripts

## 🚀 Quick Start

### 1. Start Backend Service
```bash
cd /workspaces/cs624-tp/backend
npm start
```

### 2. Verify Service is Running
```bash
curl http://localhost:3000/api/docs
```

### 3. Get Authentication Token
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@admin.com","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
```

### 4. Test Protected Endpoint
```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/products
```

## 🔧 Common Variables

```bash
# Backend URL
BACKEND_URL="http://localhost:3000"

# Sample Admin Credentials
ADMIN_EMAIL="admin@admin.com"
ADMIN_PASSWORD="admin123"

# Sample User Credentials  
USER_EMAIL="testuser@example.com"
USER_PASSWORD="password123"
```

## Environment Setup

Make sure you have the following environment variables configured:

- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - JWT signing secret
- `AZURE_STORAGE_CONNECTION_STRING` - Azure Blob Storage connection
- `AZURE_STORAGE_CONTAINER_NAME` - Azure container name

## 🎯 Testing Priorities

1. **Critical Path**: Authentication → Product Creation → User Access
2. **Core Features**: Product CRUD, User Management, AI Chat
3. **Advanced Features**: Social Posts, Recommendations
4. **Service Management**: Health checks, status monitoring

## 📊 Expected Response Codes

- `200` - Success with data
- `201` - Created successfully
- `400` - Bad request / Validation error
- `401` - Unauthorized access
- `403` - Forbidden operation
- `404` - Resource not found
- `500` - Internal server error

## 🐛 Known Issues Fixed

✅ **Product Creation Error** - Category field validation added
✅ **Field Compatibility** - Both `stock` and `stockQuantity` supported
✅ **Error Messages** - Detailed validation error responses implemented

## Testing Tips

- All endpoints return JSON responses
- Use `-v` flag with curl for verbose output and debugging
- Save tokens in environment variables for easier testing
- Check server logs for detailed error information
- Tests include both positive and negative scenarios
- Authentication tokens are required for protected endpoints

## 🤖 Automated Testing Scripts

We've created executable scripts for automated testing:

### Quick Health Check
```bash
./quick-health-check.sh
```
- Fast health check of backend service
- Tests basic connectivity and authentication
- Shows database stats
- Perfect for quick verification

### Complete Test Suite
```bash
./run-all-tests.sh
```
- Comprehensive testing of all endpoints
- Automated positive and negative testing
- Color-coded output with detailed results
- Includes performance metrics

### Script Permissions
All scripts are executable with proper permissions:
```bash
-rwxrwxrwx quick-health-check.sh
-rwxrwxrwx run-all-tests.sh
```

## 📁 Complete Directory Structure

```
app-validations/backend/
├── README.md                    # This overview file
├── quick-health-check.sh        # ⚡ Quick health check script
├── run-all-tests.sh            # 🚀 Complete automated test suite
├── service-management.md        # Service start/stop commands
├── auth-api-tests.md           # Authentication testing guide
├── product-api-tests.md        # Product CRUD testing guide
├── user-api-tests.md           # User management testing guide
├── chat-api-tests.md           # AI chat testing guide
├── post-api-tests.md           # Social posts testing guide
└── complete-test-suite.md      # All tests consolidated
```

- [Start Here: Service Management](service-management.md)
- [Authentication Testing](auth-api-tests.md)
- [Product API Testing](product-api-tests.md)
- [Complete Test Suite](complete-test-suite.md)
