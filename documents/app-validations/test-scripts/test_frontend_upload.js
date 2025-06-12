// Test script to simulate frontend image upload
const { uploadImage } = require('./frontend/app/(tabs)/imageService');

// Mock React Native dependencies
global.AsyncStorage = {
  getItem: async (key) => {
    if (key === 'userToken') {
      return 'mock-token'; // This shouldn't be needed anymore
    }
    return null;
  }
};

// Mock a simple image asset
const mockAsset = {
  uri: 'file:///tmp/test_image.png',
  type: 'image/png',
  fileName: 'test_image.png',
  fileSize: 1024
};

// Test the upload
async function testUpload() {
  console.log('Testing frontend image upload...');
  try {
    const result = await uploadImage(mockAsset);
    console.log('Upload result:', result);
  } catch (error) {
    console.error('Upload failed:', error);
  }
}

testUpload();
