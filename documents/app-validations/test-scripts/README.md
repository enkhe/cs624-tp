# Test Scripts Directory

This directory contains all validation and testing scripts for the React Native app with image upload functionality.

## Script Organization

### Core Workflow Tests
- **`test_complete_workflow.sh`** - Comprehensive end-to-end test including registration, login, product creation, and navigation
- **`test_navigation_upload_complete.sh`** - Complete navigation and image upload validation with authentication
- **`test_navigation_and_upload.sh`** - Tests navigation flow and image upload integration

### Individual Feature Tests
- **`test_product_creation.sh`** - Tests product creation functionality and API endpoints
- **`test_image_upload.sh`** - Validates Azure Blob Storage image upload functionality
- **`test_post_crud.sh`** - Tests CRUD operations for products
- **`test_react_native_formdata.sh`** - Validates FormData handling for React Native
- **`test_frontend_upload.js`** - Frontend-specific upload functionality tests

### Configuration and Debugging
- **`test_frontend_config.sh`** - Validates frontend configuration and dependencies
- **`test_frontend_public_access.sh`** - Tests frontend public access configuration for Codespaces
- **`debug_image_upload.sh`** - Debug script for troubleshooting image upload issues

### Utility Scripts
- **`run_all_tests.sh`** - Master test runner for all validation scripts
- **`verify_organization.sh`** - Verifies test script organization and dependencies

## Usage

### Run Individual Tests
```bash
cd /workspaces/cs624-tp/app-validations/test-scripts
chmod +x *.sh
./test_complete_workflow.sh
```

### Run All Tests
```bash
./run_all_tests.sh
```

## Prerequisites

1. Backend server running on port 3001
2. Frontend development server accessible
3. Azure Blob Storage configured
4. Valid test credentials in environment

## Test Flow

1. **Authentication** - Register/Login user
2. **Product Creation** - Create product with image upload
3. **Navigation** - Verify navigation to product details
4. **Image Upload** - Test image upload from product details page
5. **Validation** - Verify complete workflow end-to-end

## Platform Coverage

- Web (React)
- Android (React Native)
- iOS (React Native)

## Notes

- All scripts are designed to be run from the test-scripts directory
- Backend must be running before executing frontend tests
- Check console output for detailed validation results
