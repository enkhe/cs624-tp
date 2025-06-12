# Service Management Commands

This guide contains commands for managing the backend services locally.

## Starting Services

### Start Backend Server
```bash
# Navigate to backend directory
cd /workspaces/cs624-tp/backend

# Install dependencies (first time only)
npm install

# Start the server
npm start
```

### Start Backend in Development Mode
```bash
cd /workspaces/cs624-tp/backend

# Start with nodemon for auto-restart on file changes
npm run dev
```

### Background Service Start
```bash
# Start server in background
cd /workspaces/cs624-tp/backend && npm start &

# Get the process ID
echo $!
```

## Stopping Services

### Stop Backend Server
```bash
# Find and kill process on port 3001
kill $(lsof -t -i:3001)

# Alternative: Force kill if needed
kill -9 $(lsof -t -i:3001)
```

### Stop All Node Processes
```bash
# Kill all node processes (use with caution)
pkill -f node

# Or more specific to your app
pkill -f "node.*server.js"
```

## Service Status Checks

### Check if Backend is Running
```bash
# Check if port 3001 is in use
lsof -i :3001

# Test API health endpoint
curl http://localhost:3001/api/health || echo "Backend not responding"
```

### Check Process Status
```bash
# List all node processes
ps aux | grep node

# Check specific backend process
ps aux | grep "node.*server.js"
```

## Database Services

### MongoDB (if running locally)
```bash
# Start MongoDB service (Ubuntu/Debian)
sudo systemctl start mongod

# Stop MongoDB service
sudo systemctl stop mongod

# Check MongoDB status
sudo systemctl status mongod

# Connect to MongoDB shell
mongosh
```

### MongoDB Docker (Alternative)
```bash
# Start MongoDB in Docker container
docker run -d --name mongodb -p 27017:27017 mongo:latest

# Stop MongoDB container
docker stop mongodb

# Remove MongoDB container
docker rm mongodb
```

## Logs and Debugging

### View Backend Logs
```bash
# If running in foreground, logs appear in terminal
# If running in background, redirect logs to file:
cd /workspaces/cs624-tp/backend && npm start > backend.log 2>&1 &

# View logs in real-time
tail -f backend.log
```

### Debug Mode
```bash
# Start with debug logging
DEBUG=* npm start

# Or with specific debug namespace
DEBUG=app:* npm start
```

## Environment Variables

### Set Required Environment Variables
```bash
# Set MongoDB connection
export MONGODB_URI="mongodb://localhost:27017/cs624tp"

# Set JWT secret
export JWT_SECRET="your-super-secret-jwt-key"

# Set Azure storage (if using Azure Blob Storage)
export AZURE_STORAGE_CONNECTION_STRING="your-azure-connection-string"
export AZURE_STORAGE_CONTAINER_NAME="your-container-name"

# Verify environment variables are set
echo "MongoDB URI: $MONGODB_URI"
echo "JWT Secret: $JWT_SECRET"
```

### Environment File (.env)
```bash
# Create .env file in backend directory
cat > /workspaces/cs624-tp/backend/.env << EOF
MONGODB_URI=mongodb://localhost:27017/cs624tp
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
AZURE_STORAGE_CONNECTION_STRING=your-azure-connection-string
AZURE_STORAGE_CONTAINER_NAME=post-images
PORT=3001
EOF
```

## Health Checks

### Basic Health Check
```bash
# Check if API is responding
curl -f http://localhost:3001/ && echo "✅ Backend is healthy" || echo "❌ Backend is down"
```

### Detailed Health Check
```bash
# Check database connection and API health
curl -s http://localhost:3001/api/health | jq '.' || echo "Health check failed"
```

### Automated Health Monitoring
```bash
# Create a simple health monitoring script
cat > /workspaces/cs624-tp/backend/health-check.sh << 'EOF'
#!/bin/bash
while true; do
    if curl -f http://localhost:3001/ > /dev/null 2>&1; then
        echo "$(date): ✅ Backend healthy"
    else
        echo "$(date): ❌ Backend down"
    fi
    sleep 30
done
EOF

# Make it executable
chmod +x /workspaces/cs624-tp/backend/health-check.sh

# Run health monitoring
./health-check.sh
```

## Troubleshooting

### Port Already in Use
```bash
# Find what's using port 3001
lsof -i :3001

# Kill the process using the port
kill $(lsof -t -i:3001)

# Wait a moment and try starting again
sleep 2 && npm start
```

### Permission Issues
```bash
# Make start script executable
chmod +x /workspaces/cs624-tp/backend/start.sh

# Fix node_modules permissions if needed
sudo chown -R $(whoami) /workspaces/cs624-tp/backend/node_modules
```

### Module Not Found Errors
```bash
# Clean install dependencies
cd /workspaces/cs624-tp/backend
rm -rf node_modules package-lock.json
npm install
```

## Quick Service Management Script

```bash
# Create a service management script
cat > /workspaces/cs624-tp/backend/manage-service.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Starting backend service..."
        cd /workspaces/cs624-tp/backend && npm start
        ;;
    stop)
        echo "Stopping backend service..."
        kill $(lsof -t -i:3001) 2>/dev/null || echo "No process found on port 3001"
        ;;
    restart)
        echo "Restarting backend service..."
        kill $(lsof -t -i:3001) 2>/dev/null
        sleep 2
        cd /workspaces/cs624-tp/backend && npm start
        ;;
    status)
        if lsof -i :3001 > /dev/null 2>&1; then
            echo "✅ Backend is running on port 3001"
            curl -f http://localhost:3001/ > /dev/null 2>&1 && echo "✅ API is responding" || echo "❌ API not responding"
        else
            echo "❌ Backend is not running"
        fi
        ;;
    logs)
        echo "Viewing backend logs..."
        tail -f /workspaces/cs624-tp/backend/backend.log 2>/dev/null || echo "No log file found"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF

# Make it executable
chmod +x /workspaces/cs624-tp/backend/manage-service.sh
```

## Usage Examples

```bash
# Start service
./manage-service.sh start

# Check status
./manage-service.sh status

# Restart service
./manage-service.sh restart

# Stop service
./manage-service.sh stop

# View logs
./manage-service.sh logs
```
