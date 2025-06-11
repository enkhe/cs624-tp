import { API_BASE } from '../../constants/index.js';

// API Service and Data Manager for ProductDetails

const CONFIG = {
  API_URL: API_BASE + '/products',
  DEFAULT_IMAGE: 'https://via.placeholder.com/400x300?text=No+Image',
  MAX_IMAGE_URLS: 10,
};

export class ProductAPIService {
  static async fetchProducts() {
    try {
      const response = await fetch(CONFIG.API_URL, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return { success: true, data };
    } catch (error) {
      console.error('Fetch products error:', error);
      return { success: false, error: error.message };
    }
  }

  static async updateProduct(productId, productData) {
    try {
      const response = await fetch(`${CONFIG.API_URL}/${productId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(productData),
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return { success: true, data };
    } catch (error) {
      console.error('Update product error:', error);
      return { success: false, error: error.message };
    }
  }
}

export class ProductDataManager {
  static parsePrice(val) {
    if (typeof val === 'number') return Math.max(0, val);
    if (typeof val === 'string') {
      const parsed = parseFloat(val.replace(/[^0-9.]/g, ''));
      return isNaN(parsed) ? 0 : Math.max(0, parsed);
    }
    return 0;
  }

  static getProductImages(product) {
    // Priority: images array > imageUrls array > imageUrl > default
    if (product.images && Array.isArray(product.images) && product.images.length > 0) {
      return product.images.filter(url => url && url.trim() !== '');
    }
    
    if (product.imageUrls && Array.isArray(product.imageUrls) && product.imageUrls.length > 0) {
      return product.imageUrls.filter(url => url && url.trim() !== '');
    }
    
    if (product.imageUrl && product.imageUrl.trim() !== '') {
      return [product.imageUrl];
    }
    
    return [CONFIG.DEFAULT_IMAGE];
  }

  static validateImageUrl(url) {
    if (!url || typeof url !== 'string') return false;
    const urlPattern = /^https?:\/\/.+\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i;
    return urlPattern.test(url.trim());
  }

  static sanitizeImageUrls(urls) {
    if (!Array.isArray(urls)) return [];
    return urls
      .map(url => (typeof url === 'string' ? url.trim() : ''))
      .filter(url => url !== '')
      .slice(0, CONFIG.MAX_IMAGE_URLS);
  }

  static enhanceProduct(product) {
    return {
      id: product.id || product._id || '1',
      name: product.name || product.description || 'Unnamed Product',
      description: product.description || '',
      price: this.parsePrice(product.price),
      salePrice: product.salePrice ? this.parsePrice(product.salePrice) : null,
      images: this.getProductImages(product),
      brand: product.brand || 'Brand Name',
      category: product.category || 'Electronics',
      rating: product.rating || 4.5,
      reviewCount: product.reviewCount || 128,
      inStock: product.inStock !== false && (product.stock || 0) > 0,
      stockQuantity: product.stock || product.stockQuantity || 10,
      specifications: product.specifications || {
        'Model': 'Latest Model',
        'Warranty': '1 Year',
        'Color': 'Multiple Colors Available',
        'Weight': 'Lightweight Design',
      },
    };
  }

  static prepareUpdateData(editProduct) {
    const sanitizedUrls = this.sanitizeImageUrls(editProduct.imageUrls);
    return {
      name: editProduct.name.trim(),
      description: editProduct.description.trim(),
      price: parseFloat(editProduct.price) || 0,
      images: sanitizedUrls,
      imageUrls: sanitizedUrls, // Support both field names
      imageUrl: sanitizedUrls.length > 0 ? sanitizedUrls[0] : null, // Backward compatibility
    };
  }
}

export { CONFIG };