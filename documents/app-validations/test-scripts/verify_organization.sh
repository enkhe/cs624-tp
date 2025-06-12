#!/bin/bash

# Script to verify test script organization and dependencies

echo "🔍 Verifying Test Script Organization"
echo "===================================="

TEST_SCRIPTS_DIR="/workspaces/cs624-tp/app-validations/test-scripts"

echo "📁 Checking test scripts directory: $TEST_SCRIPTS_DIR"

if [ ! -d "$TEST_SCRIPTS_DIR" ]; then
    echo "❌ Test scripts directory not found!"
    exit 1
fi

cd "$TEST_SCRIPTS_DIR"

echo ""
echo "📋 Shell Scripts (.sh):"
echo "------------------------"
for script in *.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✅ $script (executable)"
        else
            echo "⚠️  $script (not executable)"
            chmod +x "$script"
            echo "   → Made executable"
        fi
    fi
done

echo ""
echo "📋 JavaScript Tests (.js):"
echo "---------------------------"
for script in *.js; do
    if [ -f "$script" ]; then
        echo "✅ $script"
    fi
done

echo ""
echo "📋 Documentation:"
echo "-----------------"
if [ -f "README.md" ]; then
    echo "✅ README.md"
else
    echo "❌ README.md missing"
fi

echo ""
echo "🔧 Key Scripts Present:"
echo "-----------------------"

required_scripts=(
    "run_all_tests.sh"
    "test_complete_workflow.sh"
    "test_navigation_upload_complete.sh"
    "test_image_upload.sh"
    "test_product_creation.sh"
    "test_frontend_upload.js"
)

for script in "${required_scripts[@]}"; do
    if [ -f "$script" ]; then
        echo "✅ $script"
    else
        echo "❌ $script (missing)"
    fi
done

echo ""
echo "🌍 Backend Dependencies:"
echo "------------------------"
if curl -s http://localhost:3001/api/health > /dev/null 2>&1; then
    echo "✅ Backend running on port 3001"
else
    echo "⚠️  Backend not accessible on port 3001"
    echo "   💡 Start with: cd backend && npm start"
fi

echo ""
echo "📊 Organization Summary:"
echo "------------------------"
total_sh=$(ls -1 *.sh 2>/dev/null | wc -l)
total_js=$(ls -1 *.js 2>/dev/null | wc -l)
echo "Shell scripts: $total_sh"
echo "JavaScript tests: $total_js"
echo "Total test files: $((total_sh + total_js))"

echo ""
echo "🚀 Ready to run tests!"
echo "Usage: ./run_all_tests.sh"
