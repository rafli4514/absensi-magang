# Frontend Dockerfile
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

# --- PERUBAHAN DI SINI ---
# 1. Hapus package-lock.json (agar tidak ada konflik checksum)
# 2. Bersihkan cache npm
# 3. Install fresh
RUN rm -f package-lock.json && \
    npm cache clean --force && \
    npm install
# -------------------------

COPY . .

ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
RUN npm run build

# Production stage
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
CMD ["nginx", "-g", "daemon off;"]