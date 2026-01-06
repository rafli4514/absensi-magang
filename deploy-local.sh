#!/bin/bash

# Deployment Script untuk Local Development
# Usage: ./deploy-local.sh

set -e

echo "🐳 Docker Local Deployment - Absensi Magang"
echo "=============================================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
  echo "⚠️  File .env tidak ditemukan!"
  echo "📝 Membuat .env dari .env.example..."
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "✅ File .env berhasil dibuat"
    echo "⚠️  Silakan edit file .env jika diperlukan"
  else
    echo "❌ Error: .env.example tidak ditemukan!"
    exit 1
  fi
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
  echo "❌ Docker tidak terinstall. Silakan install Docker terlebih dahulu."
  exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
  echo "❌ Docker Compose tidak terinstall. Silakan install Docker Compose terlebih dahulu."
  exit 1
fi

# Use docker compose (v2) if available, otherwise docker-compose (v1)
COMPOSE_CMD="docker-compose"
if docker compose version &> /dev/null; then
  COMPOSE_CMD="docker compose"
fi

echo "📦 Building Docker images..."
$COMPOSE_CMD build

echo ""
echo "🛑 Stopping existing containers..."
$COMPOSE_CMD down

echo ""
echo "🚀 Starting containers..."
$COMPOSE_CMD up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "📊 Checking service status..."
$COMPOSE_CMD ps

echo ""
echo "✅ Deployment selesai!"
echo ""
echo "📍 Akses aplikasi:"
echo "   Frontend: http://localhost"
echo "   Backend API: http://localhost:3000/api"
echo "   Health Check: http://localhost:3000/api/health"
echo ""
echo "📝 Useful commands:"
echo "   View logs: $COMPOSE_CMD logs -f"
echo "   Stop services: $COMPOSE_CMD down"
echo "   Restart: $COMPOSE_CMD restart"
echo ""

# Check health
echo "🏥 Checking backend health..."
sleep 5
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
  echo "✅ Backend is healthy!"
else
  echo "⚠️  Backend health check failed. Check logs: $COMPOSE_CMD logs backend"
fi

echo ""
echo "🎉 Selesai! Aplikasi siap digunakan."

