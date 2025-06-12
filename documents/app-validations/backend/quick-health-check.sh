#!/bin/bash

# Quick Backend Health Check Script
# This script performs a fast health check of the backend service

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKEND_URL="http://localhost:3000"

echo -e "${BLUE}🔍 Backend Health Check${NC}"
echo "=================================="

# Check if backend is running
echo -n "Checking backend service... "
if curl -s "$BACKEND_URL/api/docs" > /dev/null; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not running${NC}"
    echo -e "${YELLOW}To start the backend:${NC}"
    echo "cd /workspaces/cs624-tp/backend && npm start"
    exit 1
fi

# Check port status
echo -n "Checking port 3000... "
if netstat -tulpn 2>/dev/null | grep -q ":3000 "; then
    echo -e "${GREEN}✅ Port in use${NC}"
else
    echo -e "${RED}❌ Port not in use${NC}"
fi

# Quick API test
echo -n "Testing API response... "
RESPONSE=$(curl -s "$BACKEND_URL/api/docs")
if echo "$RESPONSE" | grep -q "CS624-TP\|Backend\|API"; then
    echo -e "${GREEN}✅ API responding${NC}"
else
    echo -e "${RED}❌ API not responding properly${NC}"
fi

# Test admin login
echo -n "Testing admin authentication... "
TOKEN=$(curl -s -X POST "$BACKEND_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@admin.com","password":"admin123"}' \
    | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo -e "${GREEN}✅ Admin login working${NC}"
else
    echo -e "${RED}❌ Admin login failed${NC}"
fi

# Test products endpoint
echo -n "Testing products endpoint... "
PRODUCTS=$(curl -s "$BACKEND_URL/api/products")
if echo "$PRODUCTS" | grep -q "products\|\\["; then
    echo -e "${GREEN}✅ Products endpoint working${NC}"
else
    echo -e "${RED}❌ Products endpoint failed${NC}"
fi

echo ""
echo -e "${BLUE}Health check complete!${NC}"

# Show quick stats
if [ ! -z "$TOKEN" ]; then
    echo ""
    echo -e "${YELLOW}Quick Stats:${NC}"
    
    # Count products
    PRODUCT_COUNT=$(curl -s "$BACKEND_URL/api/products" | grep -o '"_id"' | wc -l)
    echo "Products in database: $PRODUCT_COUNT"
    
    # Count users (admin only)
    USER_COUNT=$(curl -s -H "Authorization: Bearer $TOKEN" "$BACKEND_URL/api/users" | grep -o '"_id"' | wc -l)
    echo "Users in database: $USER_COUNT"
fi

echo ""
echo -e "${YELLOW}For comprehensive testing, run:${NC}"
echo "./run-all-tests.sh"
