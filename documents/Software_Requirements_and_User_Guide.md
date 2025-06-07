# Software Functional Requirements Document (SFRD)

## 1. Introduction
This document describes the functional requirements and architecture for the e-commerce mobile application, which includes a Node.js/Express backend and a React Native (Expo) frontend. The system supports product browsing, editing, image gallery, user authentication, shopping cart, checkout, and a streaming AI chat assistant (Gemma AI).

## 2. System Overview
- **Frontend:** React Native (Expo) mobile app for iOS/Android.
- **Backend:** Node.js/Express REST API with MongoDB.
- **AI Chat:** Integration with Gemma2:2b via Ollama for real-time chat.

---

## 3. Backend Architecture

```mermaid
flowchart TD
  subgraph Backend [Node.js/Express Backend]
    A[Express Server]
    B[Controllers]
    C[Routes]
    D[Services]
    E[Utils]
    F[MongoDB]
    G[Ollama (Gemma2:2b)]
    H[Azure Blob Storage]
    A --> C
    C --> B
    B --> D
    D --> F
    D --> G
    D --> H
    E --> B
    E --> D
    C -->|/api/products| B
    C -->|/api/chat| B
    C -->|/api/otp| B
    C -->|/api/auth| B
    C -->|/api/posts| B
    C -->|/api/recommendations| B
    C -->|/api/upload| B
    C -->|/api/images/:filename| B
    C -->|/api/routes| B
  end
```

---

## 4. Frontend Architecture

```mermaid
flowchart TD
  subgraph Frontend [React Native (Expo) App]
    A[App.js]
    B[HeaderBar: Home, Products, Chat, Cart, UserMenu]
    C[Product.js]
    D[ProductDetails.js]
    E[CartPage.js]
    F[PaymentPage.js]
    G[Chat.js]
    H[UserMenu.js]
    I[CartIcon.js]
    J[ImageGallery.js]
    K[api.js]
    L[constants/index.js]
    A --> B
    B --> C
    B --> G
    B --> E
    B --> H
    B --> I
    C --> D
    C --> E
    E --> F
    G --> K
    C --> K
    D --> K
    K --> L
  end
```

---

## 5. Functional Requirements
### 5.1 User Authentication
- Users can register and log in using OTP-based authentication.
- Users can log out and view their profile.

### 5.2 Product Management
- Users can browse a list of products.
- Users can view product details, including images and descriptions.
- Admins can add, edit, or delete products (name, price, image).
- Product images are served with fallback for missing/broken images.

### 5.3 Image Gallery
- Users can browse product images in a gallery view.
- Images load with error handling and fallback.

### 5.4 Shopping Cart
- Users can add products to the shopping cart from the product list or details page.
- Users can view the cart, remove items, and see a summary (subtotal, shipping, grand total).
- Users can proceed to checkout and pay the total amount.

### 5.5 AI Chat Assistant
- Users can access a chat interface to interact with Gemma AI.
- Chat supports streaming responses, markdown rendering, and typing indicators.
- Chat is accessible from the main navigation and banner page.

### 5.6 Navigation & UI
- Top header includes Home, Products, Chat, user dropdown, and shopping cart.
- Responsive, modern UI for all screens.

### 5.7 Error Handling
- All API and UI errors are handled gracefully with user feedback.
- Broken images and failed requests show appropriate messages or fallbacks.

## 6. Non-Functional Requirements
- The system must be robust for both Codespaces and local development.
- All sensitive data is managed via environment variables.
- The system must be responsive and performant on mobile devices.

## 7. External Integrations
- Ollama (for Gemma2:2b AI chat)
- Azure Blob Storage (for product images, if configured)

## 8. Security
- All API endpoints are protected as appropriate.
- User data is stored securely in MongoDB.

## 9. Deployment
- Backend and frontend can be started independently.
- Ollama and Gemma2:2b must be running for AI chat.

---

# User Guide

## Getting Started
1. **Clone the repository** and install dependencies for both backend and frontend.
2. **Start the backend**:
   - Ensure `.env` exists (auto-created by `start.sh` if missing).
   - Run `./start.sh` in the backend directory.
3. **Start the frontend**:
   - Run `npm install` and `expo start` in the frontend directory.
   - Use Expo Go or an emulator to preview.
4. **Set up AI chat**:
   - Install and run Ollama and Gemma2:2b as described in the main README.

## Main Features
### Navigation
- Use the top header to access Home, Products, and Chat.
- The user menu (☰) on the left provides profile and logout options.
- The shopping cart icon on the right shows the number of items in your cart.

### Product Browsing
- Browse products from the Products page.
- Click a product to view details, images, and add to cart.

### Shopping Cart
- Add products to your cart from the product list or details page.
- Click the cart icon to view your cart, remove items, and see totals.
- Proceed to checkout and pay the grand total (subtotal + shipping).

### AI Chat
- Access the chat from the header or banner page.
- Type your message and interact with Gemma AI.
- Streaming responses, markdown rendering, and typing indicators are supported.

### User Account
- Access the user menu for profile and logout.
- Authentication is OTP-based.

## Troubleshooting
- If the backend or frontend fails to start, check dependencies and environment variables.
- If chat does not work, ensure Ollama and Gemma2:2b are running.
- For image issues, check backend image serving and Azure Blob Storage configuration.

## Support
For further help, see the main README or contact the project maintainer.
