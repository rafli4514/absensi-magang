#!/bin/bash

# Deployment Script untuk Absensi Magang
# Usage: ./deploy.sh [dev|prod]

set -e

ENV=${1:-dev}
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

if [ "$ENV" = "prod" ]; then
  COMPOSE_FILE="docker-compose.prod.yml"
  ENV_FILE=".env.production"
  echo "🚀 Deploying to PRODUCTION..."
else
  echo "🚀 Deploying to DEVELOPMENT..."
fi

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Error: $ENV_FILE not found!"
  echo "📝 Please copy .env.example to $ENV_FILE and configure it."
  exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "❌ Docker is not installed. Please install Docker first."
  exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
  echo "❌ Docker Compose is not installed. Please install Docker Compose first."
  exit 1
fi

echo "📦 Building Docker images..."
docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE build

echo "🛑 Stopping existing containers..."
docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE down

echo "🚀 Starting containers..."
docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "📊 Checking service status..."
docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE ps

echo "✅ Deployment completed!"
echo ""
echo "📝 View logs: docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE logs -f"
echo "🛑 Stop services: docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE down"
echo ""

# Check health
echo "🏥 Checking health..."
sleep 5
if curl -f http://localhost/api/health > /dev/null 2>&1; then
  echo "✅ Backend is healthy!"
else
  echo "⚠️  Backend health check failed. Check logs for details."
fi

