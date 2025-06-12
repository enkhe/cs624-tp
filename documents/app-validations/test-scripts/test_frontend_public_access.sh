#!/bin/bash

# Test Frontend Public Access Configuration
# This script validates that the frontend is properly configured for Codespaces

echo "🧪 Testing Frontend Public Access Configuration"
echo "=============================================="

cd /workspaces/cs624-tp/frontend

# Check if we're in Codespaces
if [ -n "$CODESPACE_NAME" ]; then
    echo "✅ Running in GitHub Codespaces: $CODESPACE_NAME"
    
    # Expected URL
    EXPECTED_URL="https://${CODESPACE_NAME}-8081.app.github.dev"
    echo "🎯 Expected URL: $EXPECTED_URL"
    
    # Check if configuration files exist
    echo ""
    echo "📋 Checking Configuration Files:"
    
    if [ -f "scripts/start-public.sh" ]; then
        echo "✅ start-public.sh exists"
        if [ -x "scripts/start-public.sh" ]; then
            echo "✅ start-public.sh is executable"
        else
            echo "❌ start-public.sh is not executable"
        fi
    else
        echo "❌ start-public.sh missing"
    fi
    
    if [ -f "scripts/setup-codespaces.sh" ]; then
        echo "✅ setup-codespaces.sh exists"
    else
        echo "❌ setup-codespaces.sh missing"
    fi
    
    if [ -f "metro.config.js" ]; then
        echo "✅ metro.config.js exists"
    else
        echo "❌ metro.config.js missing"
    fi
    
    if [ -f ".env.local" ]; then
        echo "✅ .env.local exists"
        echo "📄 .env.local contents:"
        cat .env.local | sed 's/^/   /'
    else
        echo "❌ .env.local missing"
    fi
    
    # Check package.json scripts
    echo ""
    echo "📋 Checking package.json Scripts:"
    if grep -q "start-public" package.json; then
        echo "✅ start-public script found"
    else
        echo "❌ start-public script missing"
    fi
    
    if grep -q "setup-codespaces" package.json; then
        echo "✅ setup-codespaces script found"
    else
        echo "❌ setup-codespaces script missing"
    fi
    
    # Check dependencies
    echo ""
    echo "📋 Checking Dependencies:"
    if [ -d "node_modules" ]; then
        echo "✅ node_modules exists"
    else
        echo "⚠️  node_modules missing - run 'npm install'"
    fi
    
    if command -v expo >/dev/null 2>&1; then
        echo "✅ Expo CLI available"
    else
        echo "⚠️  Expo CLI not found - may need 'npm install -g @expo/cli'"
    fi
    
    echo ""
    echo "🚀 Ready to Start Commands:"
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│ npm start                 - Start with public access    │"
    echo "│ npm run start-public      - Same as above               │"
    echo "│ npm run start-local       - Local development only      │"
    echo "│ npm run setup-codespaces  - Reconfigure environment     │"
    echo "└─────────────────────────────────────────────────────────┘"
    echo ""
    echo "🌐 Your app will be accessible at:"
    echo "   $EXPECTED_URL"
    
else
    echo "⚠️  Not running in GitHub Codespaces"
    echo "🏠 This configuration is optimized for Codespaces"
    echo ""
    echo "For local development:"
    echo "   npm run start-local"
fi

echo ""
echo "✅ Configuration test complete!"
