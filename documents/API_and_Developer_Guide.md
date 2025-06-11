# API Documentation

This document provides an overview of the main API endpoints for the e-commerce mobile app backend.

---

## Authentication
- `POST /api/otp/send` — Send OTP to user
- `POST /api/otp/verify` — Verify OTP and log in
- `POST /api/auth/login` — User login
- `POST /api/auth/register` — User registration

## Products
- `GET /api/products` — List all products
- `GET /api/products/:id` — Get product details
- `PUT /api/products/:id` — Update product
- `DELETE /api/products/:id` — Delete product

## Images
- `GET /api/images/:filename` — Get product image
- `POST /api/upload` — Upload product image

## Posts
- `GET /api/posts` — List blog posts
- `POST /api/posts` — Create a post
- `PUT /api/posts/:id` — Update a post
- `DELETE /api/posts/:id` — Delete a post

## Recommendations
- `GET /api/recommendations` — Get product recommendations

## AI Chat
- `POST /api/chat` — Send a message to Gemma AI (streaming supported)

## API Docs
- `GET /api/routes` — List all available API routes

---

# Developer Guide

## Project Structure
- `backend/` — Node.js/Express API
- `frontend/` — React Native (Expo) app
- `documents/` — Requirements, user guide, and API docs

## Adding a New Product
1. Use the admin UI or send a `POST /api/products` request with product details.
2. Upload an image using `POST /api/upload`.

## Running Locally
- See the main README for setup instructions.
- Use Codespaces or local dev environment.

## Testing
- Use Postman or curl to test API endpoints.
- Use Expo Go or an emulator for the frontend.

## Contributing
- Fork the repo, create a feature branch, and submit a pull request.
- Follow code style and add documentation/comments as needed.

---

For more details, see the main README and the Software Requirements and User Guide in the `documents/` directory.
