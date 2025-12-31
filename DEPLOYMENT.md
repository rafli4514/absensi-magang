# 🚀 Panduan Deployment dengan Docker

Dokumentasi lengkap untuk deployment aplikasi Absensi Magang menggunakan Docker.

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git (untuk clone repository)
- Domain name (opsional, untuk production)

---

## 🏗️ Struktur File Docker

```
.
├── docker-compose.yml          # Docker Compose untuk development
├── docker-compose.prod.yml     # Docker Compose untuk production
├── .env.example                # Template environment variables
├── nginx/
│   ├── nginx.conf             # Main nginx config
│   └── conf.d/
│       └── default.conf       # Server configuration
├── backend/
│   ├── Dockerfile             # Backend Dockerfile
│   └── .dockerignore          # Files to exclude from build
└── frontend/
    ├── Dockerfile             # Frontend Dockerfile
    ├── nginx.conf             # Frontend nginx config
    └── .dockerignore          # Files to exclude from build
```

---

## 🚀 Quick Start (Development)

### 1. Clone Repository

```bash
git clone <repository-url>
cd Absensi
```

### 2. Setup Environment Variables

```bash
# Copy example file
cp .env.example .env

# Edit .env file
nano .env
```

**Minimal .env untuk development:**
```env
POSTGRES_DB=absensi_db
POSTGRES_USER=absensi_user
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_PORT=5432

JWT_SECRET=your_jwt_secret_min_32_chars
BACKEND_PORT=3000
FRONTEND_PORT=80

VITE_API_URL=http://localhost:3000/api
FRONTEND_URL=http://localhost
```

**Generate JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 3. Build dan Start Services

```bash
# Build semua images
docker-compose build

# Start semua services
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 4. Setup Database (First Time)

```bash
# Run migrations (otomatis saat container start)
# Atau manual:
docker-compose exec backend npx prisma migrate deploy

# (Optional) Seed database
docker-compose exec backend npm run db:seed
```

### 5. Akses Aplikasi

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api
- **Health Check**: http://localhost/api/health

---

## 🏭 Production Deployment

### 1. Setup Environment Variables untuk Production

```bash
# Buat file .env.production
cp .env.example .env.production
nano .env.production
```

**Production .env:**
```env
POSTGRES_DB=absensi_db
POSTGRES_USER=absensi_user
POSTGRES_PASSWORD=VERY_SECURE_PASSWORD_HERE
POSTGRES_PORT=5432

JWT_SECRET=VERY_SECURE_JWT_SECRET_32_CHARS_MIN
BACKEND_PORT=3000

# Ganti dengan domain kamu
FRONTEND_URL=https://yourdomain.com
VITE_API_URL=https://api.yourdomain.com/api
# atau jika API di subpath:
# VITE_API_URL=https://yourdomain.com/api

NODE_ENV=production
```

### 2. Build Production Images

```bash
# Build dengan production config
docker-compose -f docker-compose.prod.yml --env-file .env.production build

# Start services
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

### 3. Setup SSL Certificate (Let's Encrypt)

#### Option A: Manual SSL Certificate

```bash
# Install Certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Copy certificates to nginx/ssl
sudo mkdir -p nginx/ssl
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem nginx/ssl/
sudo chmod 644 nginx/ssl/*.pem
```

#### Option B: Menggunakan Nginx dengan Certbot di Container (Recommended)

Tambahkan service certbot di docker-compose.prod.yml dan uncomment HTTPS configuration di nginx/conf.d/default.conf

### 4. Konfigurasi Nginx untuk HTTPS

Edit `nginx/conf.d/default.conf` dan uncomment bagian HTTPS server, lalu sesuaikan:

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    # ... rest of config
}
```

### 5. Restart Services

```bash
docker-compose -f docker-compose.prod.yml restart nginx
```

---

## 📱 Update Mobile App

Setelah backend deployed, update API URL di mobile app:

**File: `mobile/lib/utils/constants.dart`**

```dart
static const String baseUrl = 'https://api.yourdomain.com/api';
// atau jika API di subpath:
static const String baseUrl = 'https://yourdomain.com/api';
```

Rebuild APK/IPA dengan URL baru.

---

## 🔧 Maintenance Commands

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
docker-compose logs -f nginx

# Last 100 lines
docker-compose logs --tail=100 backend
```

### Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart backend
docker-compose restart frontend
```

### Stop Services

```bash
# Stop (keep containers)
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes (⚠️ WARNING: deletes data)
docker-compose down -v
```

### Database Backup

```bash
# Backup database
docker-compose exec postgres pg_dump -U absensi_user absensi_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
docker-compose exec -T postgres psql -U absensi_user -d absensi_db < backup.sql
```

### Database Migration

```bash
# Run migrations
docker-compose exec backend npx prisma migrate deploy

# Generate Prisma Client
docker-compose exec backend npx prisma generate
```

### Access Container Shell

```bash
# Backend container
docker-compose exec backend sh

# Database container
docker-compose exec postgres psql -U absensi_user -d absensi_db

# Frontend container
docker-compose exec frontend sh
```

---

## 🔍 Troubleshooting

### Port Already in Use

```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :3000
sudo lsof -i :5432

# Stop conflicting service atau change port di .env
```

### Database Connection Error

```bash
# Check if postgres is running
docker-compose ps postgres

# Check postgres logs
docker-compose logs postgres

# Verify DATABASE_URL di backend container
docker-compose exec backend env | grep DATABASE_URL
```

### Build Fails

```bash
# Clean build (no cache)
docker-compose build --no-cache

# Remove old images
docker system prune -a
```

### Frontend Not Loading

```bash
# Check frontend logs
docker-compose logs frontend

# Check nginx logs (if using nginx)
docker-compose logs nginx

# Verify VITE_API_URL
docker-compose exec frontend env | grep VITE_API_URL
```

### Permission Denied on Uploads

```bash
# Fix uploads directory permissions
docker-compose exec backend chmod -R 755 /app/uploads
```

---

## 📊 Monitoring

### Health Checks

Semua services memiliki health checks:
- Backend: `http://localhost:3000/api/health`
- Frontend: `http://localhost/` (nginx default page)
- Postgres: Internal health check

### Resource Usage

```bash
# View resource usage
docker stats

# View specific container
docker stats absensi-backend
```

---

## 🔐 Security Best Practices

1. **Environment Variables**
   - Jangan commit `.env` ke git
   - Gunakan password yang kuat untuk database
   - Generate JWT_SECRET yang unik dan random

2. **SSL/TLS**
   - Selalu gunakan HTTPS di production
   - Setup Let's Encrypt untuk SSL certificate
   - Enable HSTS headers

3. **Database**
   - Jangan expose PostgreSQL port ke public (5432)
   - Gunakan strong password
   - Regular backups

4. **Firewall**
   - Hanya buka port 80 dan 443 di production
   - SSH (22) hanya untuk trusted IPs
   - Block port 3000 dan 5432 dari public

5. **Updates**
   - Regularly update Docker images
   - Update dependencies
   - Monitor security advisories

---

## 🚀 Deployment Checklist

- [ ] Environment variables configured
- [ ] Strong passwords set
- [ ] JWT_SECRET generated
- [ ] Database created and migrated
- [ ] SSL certificate installed (production)
- [ ] Nginx configured for HTTPS (production)
- [ ] Firewall configured
- [ ] Domain DNS configured
- [ ] Mobile app API URL updated
- [ ] Backup strategy implemented
- [ ] Monitoring setup
- [ ] Health checks working

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

---

**Need Help?** Check logs dengan `docker-compose logs -f` atau create issue di repository.

