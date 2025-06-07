# cs624-tp - e-Commerce-Mobile-App

This repository contains a full-stack e-commerce mobile application with a Node.js/Express backend and a React Native (Expo) frontend. The app features product browsing, editing, image gallery, user authentication, and a streaming AI chat assistant (Gemma AI).

---

## Table of Contents
- [Project Structure](#project-structure)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [AI Setup (Ollama + Gemma2:2b)](#ai-setup-ollama--gemma22b)
- [Environment Variables](#environment-variables)
- [Key Features](#key-features)
- [Development Notes](#development-notes)
- [Troubleshooting](#troubleshooting)

---

## Project Structure

```
backend/      # Node.js/Express API server
frontend/     # React Native (Expo) mobile app
```

---

## Backend Setup (`backend/`)

### Prerequisites
- Node.js 18+
- npm

### Install Dependencies
```
cd backend
npm install
```

### Environment Variables
- The backend requires a `.env` file. On first run, `start.sh` will auto-create one if missing.
- Key variable: `GEMMA_API_URL` (set automatically for Codespaces/local dev)

### Running the Server
```
./start.sh
```
- This script ensures `.env` exists and starts the server.
- The server runs on port 3001 by default.

### Main Endpoints
- `POST /api/chat` — AI chat (streaming supported)
- `GET /api/products` — List products
- `PUT /api/products/:id` — Update product (name, price, image)
- `GET /api/images/:filename` — Serve product images
- ...and more (see `backend/routes/`)

---

## Frontend Setup (`frontend/`)

### Prerequisites
- Node.js 18+
- npm
- Expo CLI (`npm install -g expo-cli`)

### Install Dependencies
```
cd frontend
npm install
```

### Running the App
```
expo start
```
- Use the Expo Go app or an emulator to preview.
- The app auto-detects API base URL for Codespaces/local dev.

### Main Screens
- **Home**: Welcome banner, navigation, and quick access to chat
- **Product List**: Browse products
- **Product Details/Edit**: View and update product info/images
- **Image Gallery**: Browse product images
- **Chat**: Streamed AI chat with markdown support

---

## AI Setup (Ollama + Gemma2:2b)

To enable the AI chat functionality, you need to install and run Ollama with the Gemma2:2b model locally.

### Terminal 1: Install and Run Ollama

**Pull Ollama:**
```sh
curl -fsSL https://ollama.com/install.sh | sh
```

**Run Ollama:**
```sh
ollama serve
```

### Terminal 2: Pull and Run Gemma2:2b

**Pull Gemma2:2b:**
```sh
ollama pull gemma2:2b
```

**Run Gemma2:2b:**
```sh
ollama run gemma2:2b
```

> Make sure the backend `.env` is configured to point to your local Ollama server if not running in Codespaces.

---

## Environment Variables
- The frontend uses `API_BASE` from `frontend/constants/index.js`.
- No manual `.env` needed for frontend; API base is set dynamically.

---

## Key Features
- **Robust Product Management**: Edit product info and images with error handling and image preview/fallbacks
- **Image Gallery**: Simple, reliable image browsing
- **Streaming AI Chat**: Real-time chat with Gemma AI, markdown rendering, and detailed logging for debugging
- **User Authentication**: OTP-based login (see backend/controllers/authController.js)
- **Responsive UI**: Modern, mobile-friendly design

---

## Development Notes
- **Streaming Chat**: Uses `text/event-stream` for real-time AI responses. Frontend renders markdown and updates UI as chunks arrive.
- **Image Handling**: Broken/missing images show a Wikipedia placeholder.
- **Font Loading**: No custom font loading logic; uses system fonts for reliability.
- **Environment Handling**: Both backend and frontend are robust for Codespaces and local development.

---

## Troubleshooting
- **Backend fails to start**: Ensure Node.js is installed. `.env` is auto-created if missing.
- **Frontend can't connect to API**: Check that backend is running and accessible. API base URL is set dynamically.
- **Chat not streaming**: Ensure backend `/api/chat` supports `text/event-stream` and frontend is up to date.
- **Image issues**: Broken images will show a placeholder; check backend image serving if needed.
- **AI not responding**: Ensure Ollama and Gemma2:2b are running as described above.

---

## Credits
- Built with Node.js, Express, React Native, and Expo.
- AI chat powered by Gemma API via Ollama.

---

For more details, see the `README.md` files in each subdirectory.