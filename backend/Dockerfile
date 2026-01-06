FROM node:22-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++ openssl

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# Install dev dependencies for build
RUN npm install --include=dev

# Copy source code
COPY . .

# Generate Prisma client and build
RUN npx prisma generate && \
    npm run build

# Keep ts-node and types for seeding (needed for db:seed)
RUN npm prune --production && \
    npm install --save-prod ts-node typescript && \
    npm install --save-dev @types/node

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]