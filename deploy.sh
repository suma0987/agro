#!/bin/bash
# deploy.sh

echo "🚀 Starting AgroDetect AI Deployment"

# Pull latest code
echo "📦 Pulling latest code..."
git pull origin main

# Install dependencies
echo "📦 Installing backend dependencies..."
npm ci --only=production

# Build frontend
echo "🎨 Building frontend..."
cd frontend
npm ci
npm run build
cd ..

# Run database migrations
echo "🗄️ Running database migrations..."
npx sequelize-cli db:migrate

# Build and start Docker containers
echo "🐳 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

echo "🔄 Stopping old containers..."
docker-compose -f docker-compose.prod.yml down

echo "🚀 Starting new containers..."
docker-compose -f docker-compose.prod.yml up -d

# Clean up old images
echo "🧹 Cleaning up old images..."
docker image prune -f

# Check deployment status
echo "✅ Checking deployment status..."
sleep 10
curl -f http://localhost/health || exit 1

echo "✨ Deployment completed successfully!"