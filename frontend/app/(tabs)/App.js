import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  SafeAreaView,
  Platform,
  Dimensions,
  Modal, // Import Modal for custom alert
  ActivityIndicator, // For loading state in modal
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage'; // Import AsyncStorage

// Import all your components
import Login from './Login';
import Category from './Category';
import Shopbot from './Shopbot';
import Product from './Product';
import ProductDetails from './ProductDetails';
import User from './User';
import Home from './Home';
import Chat from './Chat';
import CartIcon from './CartIcon';
import UserMenu from './UserMenu';
import CartPage from './CartPage';
import PaymentPage from './PaymentPage';

const { width } = Dimensions.get('window');

export default function App() {
  const [activeTab, setActiveTab] = useState('Home');
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [cart, setCart] = useState([]);
  const [showCart, setShowCart] = useState(false);
  const [showPayment, setShowPayment] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false); // Consider managing auth state with Firebase or similar
  const [modalVisible, setModalVisible] = useState(false);
  const [modalMessage, setModalMessage] = useState('');
  const [modalTitle, setModalTitle] = useState('');
  const [modalType, setModalType] = useState('alert'); // 'alert' or 'confirm'
  const [modalCallback, setModalCallback] = useState(null);

  // Custom function to show alerts
  const showAlert = useCallback((title, message, type = 'alert', callback = null) => {
    setModalTitle(title);
    setModalMessage(message);
    setModalType(type);
    setModalCallback(() => callback); // Use a functional update for callback
    setModalVisible(true);
  }, []);

  // Custom function to hide alerts
  const hideAlert = useCallback(() => {
    setModalVisible(false);
    setModalTitle('');
    setModalMessage('');
    setModalType('alert');
    setModalCallback(null);
  }, []);

  // Load cart from AsyncStorage on mount
  useEffect(() => {
    const loadCartFromStorage = async () => {
      try {
        const savedCart = await AsyncStorage.getItem('cart');
        if (savedCart) {
          setCart(JSON.parse(savedCart));
        }
      } catch (error) {
        console.error('Failed to load cart from storage', error);
        showAlert('Error', 'Failed to load your cart. Please try again.', 'alert');
      }
    };
    loadCartFromStorage();
  }, [showAlert]);

  // Save cart to AsyncStorage whenever it changes
  useEffect(() => {
    const saveCartToStorage = async () => {
      try {
        await AsyncStorage.setItem('cart', JSON.stringify(cart));
      } catch (error) {
        console.error('Failed to save cart to storage', error);
        showAlert('Error', 'Failed to save your cart. Data might be lost.', 'alert');
      }
    };
    saveCartToStorage();
  }, [cart, showAlert]);

  // Add product to cart with quantity management
  const handleAddToCart = useCallback((product) => {
    setCart(prev => {
      const existingItem = prev.find(item => item.id === product.id);
      let newCart;

      if (existingItem) {
        // Increment quantity if item already exists
        newCart = prev.map(item =>
          item.id === product.id
            ? { ...item, quantity: (item.quantity || 0) + 1 } // Ensure quantity starts at 0 if undefined
            : item
        );
      } else {
        // Add new item with quantity 1
        newCart = [...prev, { ...product, quantity: 1 }];
      }
      return newCart;
    });
    showAlert('Item Added!', `${product.name} has been added to your cart.`, 'alert');
  }, [showAlert]);

  // Update quantity in cart
  const handleUpdateQuantity = useCallback((id, quantity) => {
    setCart(prev => {
      const updatedCart = prev.map(item => item.id === id ? { ...item, quantity } : item);
      return updatedCart.filter(item => item.quantity > 0); // Remove if quantity drops to 0
    });
  }, []);

  // Remove product from cart
  const handleRemoveFromCart = useCallback((id) => {
    showAlert('Remove Item?', 'Are you sure you want to remove this item from your cart?', 'confirm', () => {
      setCart(prev => prev.filter(item => item.id !== id));
      showAlert('Removed!', 'Item has been removed from your cart.', 'alert');
    });
  }, [showAlert]);

  // Clear cart
  const handleClearCart = useCallback(() => {
    showAlert('Clear Cart?', 'Are you sure you want to clear your entire cart?', 'confirm', () => {
      setCart([]);
      showAlert('Cart Cleared!', 'Your cart has been emptied.', 'alert');
    });
  }, [showAlert]);

  // Handle checkout
  const handleCheckout = useCallback(() => {
    if (cart.length === 0) {
      showAlert('Cart Empty', 'Your cart is empty! Add some items before checking out.', 'alert');
      return;
    }
    setShowCart(false);
    setShowPayment(true);
  }, [cart.length, showAlert]);

  // Handle payment
  const handlePay = useCallback(() => {
    showAlert('Confirm Payment', 'Do you want to proceed with the payment?', 'confirm', () => {
      handleClearCart(); // This will show another alert, consider combining or changing flow
      setShowPayment(false);
      setActiveTab('Home');
      showAlert('Payment Successful!', 'Thank you for your order! Your payment has been processed.', 'alert');
    });
  }, [handleClearCart, showAlert]);

  // Handle navigation back from product details
  const handleBackToProducts = useCallback(() => {
    setSelectedProduct(null);
    setActiveTab('Product');
  }, []);

  // Handle user menu actions
  const handleProfile = useCallback(() => {
    showAlert('Profile', 'Profile page features coming soon!', 'alert');
  }, [showAlert]);

  const handleLogout = useCallback(() => {
    showAlert('Logout', 'Are you sure you want to log out?', 'confirm', () => {
      setIsAuthenticated(false);
      handleClearCart(); // This will show another alert, consider combining or changing flow
      showAlert('Logged Out', 'You have been logged out successfully!', 'alert');
    });
  }, [handleClearCart, showAlert]);

  // Calculate cart total
  const getCartTotal = useCallback(() => {
    return cart.reduce((sum, item) => sum + (item.price * (item.quantity || 0)), 0);
  }, [cart]);

  // Get total items count
  const getCartItemsCount = useCallback(() => {
    return cart.reduce((sum, item) => sum + (item.quantity || 0), 0);
  }, [cart]);

  // Render main content based on active state
  const renderContent = () => {
    if (showCart) {
      return (
        <CartPage
          cart={cart}
          onRemove={handleRemoveFromCart}
          onUpdateQuantity={handleUpdateQuantity}
          onCheckout={handleCheckout}
          onBack={() => setShowCart(false)}
        />
      );
    }

    if (showPayment) {
      const subtotal = getCartTotal();
      const shipping = cart.length > 0 ? 7.99 : 0; // Shipping only if items are in cart
      const tax = subtotal * 0.08; // 8% tax
      const grandTotal = subtotal + shipping + tax;

      return (
        <PaymentPage
          subtotal={subtotal}
          shipping={shipping}
          tax={tax}
          total={grandTotal}
          onPay={handlePay}
          onBack={() => {
            setShowPayment(false);
            setShowCart(true); // Go back to cart page
          }}
        />
      );
    }

    if (activeTab === 'ProductDetails' && selectedProduct) {
      return (
        <ProductDetails
          route={{
            params: {
              product: selectedProduct,
              onProductUpdate: (updatedProduct) => {
                // This callback should ideally update the specific product in the main products list
                // For now, it's a placeholder if ProductDetails modifies product properties.
                console.log('Product updated from details:', updatedProduct);
              },
              onAddToCart: handleAddToCart
            }
          }}
          navigation={{ goBack: handleBackToProducts }}
        />
      );
    }

    switch (activeTab) {
      case 'Home':
        return (
          <Home
            onGetStarted={() => setActiveTab('Product')}
            onChat={() => setActiveTab('Chat')}
          />
        );
      case 'Product':
        return (
          <Product
            onProductSelect={(product) => {
              setSelectedProduct(product);
              setActiveTab('ProductDetails');
            }}
            onAddToCart={handleAddToCart}
          />
        );
      case 'Chat':
        return <Chat />;
      // Removed 'Category', 'Login', 'Shopbot', 'User' as they are not explicitly rendered in the switch
      default:
        return (
          <Home
            onGetStarted={() => setActiveTab('Product')}
            onChat={() => setActiveTab('Chat')}
          />
        );
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.headerBar}>
        {/* User Menu */}
        <UserMenu
          onProfile={handleProfile}
          onLogout={handleLogout}
          isAuthenticated={isAuthenticated} // Pass authentication status
        />

        {/* Navigation Links */}
        <View style={styles.navLinks}>
          <TouchableOpacity
            onPress={() => {
              setActiveTab('Home');
              setShowCart(false);
              setShowPayment(false);
            }}
            style={[styles.headerLink, activeTab === 'Home' && styles.activeLink]}
          >
            <Text style={[styles.headerLinkText, activeTab === 'Home' && styles.activeLinkText]}>
              Home
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => {
              setActiveTab('Product');
              setShowCart(false);
              setShowPayment(false);
            }}
            style={[styles.headerLink, activeTab === 'Product' && styles.activeLink]}
          >
            <Text style={[styles.headerLinkText, activeTab === 'Product' && styles.activeLinkText]}>
              Products
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => {
              setActiveTab('Chat');
              setShowCart(false);
              setShowPayment(false);
            }}
            style={[styles.headerLink, activeTab === 'Chat' && styles.activeLink]}
          >
            <Text style={[styles.headerLinkText, activeTab === 'Chat' && styles.activeLinkText]}>
              Chat
            </Text>
          </TouchableOpacity>
        </View>

        <View style={{ flex: 1 }} /> {/* Spacer */}

        {/* Cart Icon */}
        <CartIcon
          count={getCartItemsCount()}
          onPress={() => {
            setShowCart(true);
            setShowPayment(false);
          }}
        />
      </View>

      {/* Main Content Area */}
      <View style={styles.content}>
        {renderContent()}
      </View>

      {/* Custom Alert/Confirm Modal */}
      <Modal
        animationType="fade"
        transparent={true}
        visible={modalVisible}
        onRequestClose={hideAlert}
      >
        <TouchableOpacity
          style={modalStyles.overlay}
          activeOpacity={1}
          onPressOut={hideAlert} // Allows dismissing by tapping outside for alerts
        >
          <View style={modalStyles.modalContainer}>
            <View style={modalStyles.modalContent}>
              <Text style={modalStyles.modalTitle}>{modalTitle}</Text>
              <Text style={modalStyles.modalMessage}>{modalMessage}</Text>
              <View style={modalStyles.modalButtons}>
                {modalType === 'confirm' && (
                  <TouchableOpacity
                    style={[modalStyles.button, modalStyles.cancelButton]}
                    onPress={hideAlert}
                  >
                    <Text style={modalStyles.buttonText}>Cancel</Text>
                  </TouchableOpacity>
                )}
                <TouchableOpacity
                  style={[modalStyles.button, modalStyles.okButton]}
                  onPress={() => {
                    hideAlert();
                    if (modalCallback) {
                      modalCallback();
                    }
                  }}
                >
                  <Text style={modalStyles.buttonText}>{modalType === 'confirm' ? 'Confirm' : 'OK'}</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </TouchableOpacity>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  headerBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingTop: Platform.OS === 'ios' ? 0 : 10,
    paddingBottom: 10,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e2e8f0',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    minHeight: 60,
  },
  navLinks: {
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: 20,
  },
  headerLink: {
    marginHorizontal: 8,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 6,
    backgroundColor: 'transparent',
  },
  activeLink: {
    backgroundColor: '#eff6ff',
  },
  headerLinkText: {
    fontSize: 16,
    color: '#64748b',
    fontWeight: '600',
  },
  activeLinkText: {
    color: '#3b82f6',
  },
  content: {
    flex: 1,
  },
});

const modalStyles = StyleSheet.create({
  overlay: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContainer: {
    width: '80%',
    maxWidth: 350,
    backgroundColor: '#fff',
    borderRadius: 12,
    overflow: 'hidden',
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
  },
  modalContent: {
    padding: 20,
    alignItems: 'center',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 10,
    textAlign: 'center',
  },
  modalMessage: {
    fontSize: 16,
    color: '#475569',
    textAlign: 'center',
    marginBottom: 20,
  },
  modalButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
  },
  button: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    marginHorizontal: 5,
    alignItems: 'center',
    justifyContent: 'center',
  },
  okButton: {
    backgroundColor: '#3b82f6',
  },
  cancelButton: {
    backgroundColor: '#cbd5e1',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
