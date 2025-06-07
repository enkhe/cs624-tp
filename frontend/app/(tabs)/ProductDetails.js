import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  Share,
  Platform,
  KeyboardAvoidingView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import ImageGallery from './ImageGallery';
import ProductEditForm from './ProductEditForm';
import StarRating from './StarRating';
import { ProductAPIService, ProductDataManager, CONFIG } from './api';
import styles from './ProductDetails.styles';

const ProductDetails = ({ route, navigation }) => {
  const { product } = route.params;
  const scrollViewRef = useRef(null);

  // State Management
  const [quantity, setQuantity] = useState(1);
  const [loading, setLoading] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [enhancedProduct, setEnhancedProduct] = useState(null);
  const [editProduct, setEditProduct] = useState(null);
  const [updateInProgress, setUpdateInProgress] = useState(false);

  // Initialize enhanced product data
  useEffect(() => {
    const enhanced = ProductDataManager.enhanceProduct(product);
    setEnhancedProduct(enhanced);
    setEditProduct({
      name: enhanced.name,
      description: enhanced.description,
      price: enhanced.price.toString(),
      imageUrls: enhanced.images.filter(img => img !== CONFIG.DEFAULT_IMAGE),
    });
  }, [product]);

  // Computed values
  const isOnSale = enhancedProduct?.salePrice && enhancedProduct.salePrice < enhancedProduct.price;
  const displayPrice = enhancedProduct?.salePrice || enhancedProduct?.price || 0;
  const discount = isOnSale ? Math.round(((enhancedProduct.price - enhancedProduct.salePrice) / enhancedProduct.price) * 100) : 0;

  // Event Handlers
  const handleQuantityChange = useCallback((change) => {
    const newQuantity = quantity + change;
    if (newQuantity >= 1 && newQuantity <= (enhancedProduct?.stockQuantity || 10)) {
      setQuantity(newQuantity);
    }
  }, [quantity, enhancedProduct?.stockQuantity]);

  const handleAddToCart = useCallback(async () => {
    setLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      Alert.alert(
        'Success',
        `${quantity} ${enhancedProduct?.name || 'Product'}(s) added to cart!`,
        [{ text: 'OK' }]
      );
    } catch (error) {
      Alert.alert('Error', 'Failed to add item to cart');
    } finally {
      setLoading(false);
    }
  }, [quantity, enhancedProduct?.name]);

  const handleBuyNow = useCallback(() => {
    Alert.alert(
      'Buy Now',
      `Proceed to checkout with ${quantity} item(s)?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Continue', onPress: () => console.log('Checkout') }
      ]
    );
  }, [quantity]);

  const handleShare = useCallback(async () => {
    try {
      await Share.share({
        message: `Check out ${enhancedProduct?.name} - $${displayPrice}`,
        title: enhancedProduct?.name,
      });
    } catch (error) {
      console.error('Share error:', error);
    }
  }, [enhancedProduct?.name, displayPrice]);

  const handleToggleEditMode = useCallback(() => {
    if (updateInProgress) return;
    
    setEditMode(prev => !prev);
    if (!editMode && enhancedProduct) {
      setEditProduct({
        name: enhancedProduct.name,
        description: enhancedProduct.description,
        price: enhancedProduct.price.toString(),
        imageUrls: enhancedProduct.images.filter(img => img !== CONFIG.DEFAULT_IMAGE),
      });
      
      // Scroll to top when entering edit mode
      setTimeout(() => {
        scrollViewRef.current?.scrollTo({ y: 0, animated: true });
      }, 100);
    }
  }, [editMode, enhancedProduct, updateInProgress]);

  const handleProductChange = useCallback((newProductData) => {
    setEditProduct(newProductData);
  }, []);

  const handleImageUrlsChange = useCallback((newImageUrls) => {
    setEditProduct(prev => ({ ...prev, imageUrls: newImageUrls }));
  }, []);

  const handleUpdateProduct = useCallback(async () => {
    if (updateInProgress) return;
    
    setUpdateInProgress(true);
    try {
      const updateData = ProductDataManager.prepareUpdateData(editProduct);
      const result = await ProductAPIService.updateProduct(
        enhancedProduct?.id || product?.id || product?._id, 
        updateData
      );
      
      if (result.success) {
        // Update local state with new data
        const updatedEnhanced = ProductDataManager.enhanceProduct(result.data);
        setEnhancedProduct(updatedEnhanced);
        
        // Update parent component if callback exists
        if (route.params?.onProductUpdate) {
          route.params.onProductUpdate(result.data);
        }
        
        Alert.alert('Success', 'Product updated successfully!', [
          { text: 'OK', onPress: () => setEditMode(false) }
        ]);
      } else {
        Alert.alert('Error', result.error || 'Failed to update product');
      }
    } catch (error) {
      Alert.alert('Error', 'An unexpected error occurred');
    } finally {
      setUpdateInProgress(false);
    }
  }, [editProduct, enhancedProduct?.id, product, route.params]);

  // Loading state
  if (!enhancedProduct) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#3B82F6" />
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea} edges={['top', 'left', 'right']}>
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 24}
      >
        <View style={styles.container}>
          {/* Header */}
          <View style={styles.header}>
            <TouchableOpacity
              style={styles.backButton}
              onPress={() => navigation?.goBack()}
            >
              <Ionicons name="arrow-back" size={24} color="#3B82F6" />
            </TouchableOpacity>
            <View style={styles.headerActions}>
              <TouchableOpacity style={styles.actionButton} onPress={handleShare}>
                <Ionicons name="share-outline" size={24} color="#3B82F6" />
              </TouchableOpacity>
            </View>
          </View>

          <ScrollView
            ref={scrollViewRef}
            style={styles.scrollContainer}
            contentContainerStyle={{ paddingBottom: editMode ? 40 : 160 }}
            showsVerticalScrollIndicator={false}
            keyboardShouldPersistTaps="handled"
          >
            {/* Image Gallery */}
            <ImageGallery images={enhancedProduct?.images || []} />

            {/* Product Information */}
            <View style={styles.productInfo}>
              {/* Discount Badge */}
              {isOnSale && (
                <View style={styles.discountBadge}>
                  <Text style={styles.discountText}>{discount}% OFF</Text>
                </View>
              )}

              {/* Brand and Category */}
              <View style={styles.brandContainer}>
                <Text style={styles.brand}>{enhancedProduct?.brand}</Text>
                <Text style={styles.category}>{enhancedProduct?.category}</Text>
              </View>

              {/* Product Name */}
              <Text style={styles.productName}>{enhancedProduct?.name}</Text>

              {/* Rating */}
              <View style={styles.ratingContainer}>
                <StarRating rating={enhancedProduct?.rating} />
                <Text style={styles.ratingText}>
                  {enhancedProduct?.rating} ({enhancedProduct?.reviewCount} reviews)
                </Text>
              </View>

              {/* Price */}
              <View style={styles.priceContainer}>
                <Text style={styles.currentPrice}>${displayPrice.toFixed(2)}</Text>
                {isOnSale && (
                  <Text style={styles.originalPrice}>${enhancedProduct?.price.toFixed(2)}</Text>
                )}
              </View>

              {/* Stock Status */}
              <View style={styles.stockContainer}>
                <Ionicons
                  name={enhancedProduct?.inStock ? 'checkmark-circle' : 'close-circle'}
                  size={20}
                  color={enhancedProduct?.inStock ? '#10B981' : '#EF4444'}
                />
                <Text style={[
                  styles.stockText,
                  { color: enhancedProduct?.inStock ? '#10B981' : '#EF4444' },
                ]}>
                  {enhancedProduct?.inStock
                    ? `In Stock (${enhancedProduct?.stockQuantity})`
                    : 'Out of Stock'}
                </Text>
              </View>

              {/* Quantity Selector */}
              {enhancedProduct?.inStock && !editMode && (
                <View style={styles.quantityContainer}>
                  <Text style={styles.quantityLabel}>Quantity:</Text>
                  <View style={styles.quantitySelector}>
                    <TouchableOpacity
                      style={[styles.quantityButton, quantity <= 1 && styles.disabledButton]}
                      onPress={() => handleQuantityChange(-1)}
                      disabled={quantity <= 1}
                    >
                      <Ionicons name="remove" size={20} color={quantity <= 1 ? '#D1D5DB' : '#333'} />
                    </TouchableOpacity>
                    <Text style={styles.quantityText}>{quantity}</Text>
                    <TouchableOpacity
                      style={[styles.quantityButton, quantity >= enhancedProduct.stockQuantity && styles.disabledButton]}
                      onPress={() => handleQuantityChange(1)}
                      disabled={quantity >= enhancedProduct.stockQuantity}
                    >
                      <Ionicons name="add" size={20} color={quantity >= enhancedProduct.stockQuantity ? '#D1D5DB' : '#333'} />
                    </TouchableOpacity>
                  </View>
                </View>
              )}

              {/* Description */}
              {!editMode && (
                <View style={styles.section}>
                  <Text style={styles.sectionTitle}>Description</Text>
                  <Text style={styles.description}>{enhancedProduct?.description}</Text>
                </View>
              )}

              {/* Update Button */}
              {!editMode && (
                <TouchableOpacity
                  style={styles.updateButton}
                  onPress={handleToggleEditMode}
                  disabled={updateInProgress}
                >
                  <Ionicons name="create-outline" size={20} color="#FFFFFF" />
                  <Text style={styles.updateButtonText}>Update Product</Text>
                </TouchableOpacity>
              )}

              {/* Edit Form */}
              {editMode && (
                <ProductEditForm
                  editProduct={editProduct}
                  onProductChange={handleProductChange}
                  onImageUrlsChange={handleImageUrlsChange}
                  onSave={handleUpdateProduct}
                  onCancel={handleToggleEditMode}
                  loading={updateInProgress}
                />
              )}
            </View>
          </ScrollView>

          {/* Bottom Action Buttons */}
          {!editMode && (
            <View style={styles.bottomContainer}>
              <View style={styles.totalContainer}>
                <Text style={styles.totalLabel}>Total:</Text>
                <Text style={styles.totalPrice}>${(displayPrice * quantity).toFixed(2)}</Text>
              </View>
              <View style={styles.buttonContainer}>
                <TouchableOpacity
                  style={[styles.addToCartButton, !enhancedProduct?.inStock && styles.disabledButton]}
                  onPress={handleAddToCart}
                  disabled={!enhancedProduct?.inStock || loading}
                >
                  {loading ? (
                    <ActivityIndicator color="#FFFFFF" />
                  ) : (
                    <>
                      <Ionicons name="cart-outline" size={20} color="#FFFFFF" />
                      <Text style={styles.buttonText}>Add to Cart</Text>
                    </>
                  )}
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.buyNowButton, !enhancedProduct?.inStock && styles.disabledButton]}
                  onPress={handleBuyNow}
                  disabled={!enhancedProduct?.inStock}
                >
                  <Ionicons name="flash" size={20} color="#FFFFFF" />
                  <Text style={styles.buttonText}>Buy Now</Text>
                </TouchableOpacity>
              </View>
            </View>
          )}
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

export default ProductDetails;