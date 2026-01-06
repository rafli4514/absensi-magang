#!/bin/sh
set -e

echo "🚀 Starting backend container..."

# Generate Prisma Client
echo "📦 Generating Prisma Client..."
npx prisma generate

# Run migrations
echo "🗄️  Running database migrations..."
npx prisma migrate deploy

# Run seed (will skip if already exists due to upsert)
echo "🌱 Seeding database..."
TS_NODE_COMPILER_OPTIONS='{"module":"commonjs","target":"ES2020","lib":["ES2020"],"types":["node"]}' npx ts-node src/database/seed.ts || echo "⚠️  Seed skipped or failed (this is OK if data already exists)"

# Start the application
echo "✅ Starting application..."
exec npm start

