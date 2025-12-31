# 🐳 Docker Deployment - Quick Start

Panduan cepat untuk deploy aplikasi Absensi Magang menggunakan Docker.

## ⚡ Quick Start

### 1. Setup Environment

```bash
# Copy example file
cp .env.example .env

# Edit .env dengan konfigurasi kamu
nano .env
```

**Generate JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2. Build & Run

```bash
# Development
docker-compose up -d

# Production (dengan nginx reverse proxy)
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

### 3. Setup Database (First Time)

```bash
# Migrations run automatically, tapi kalau perlu manual:
docker-compose exec backend npx prisma migrate deploy

# Seed database (optional)
docker-compose exec backend npm run db:seed
```

### 4. Akses Aplikasi

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api
- **Health Check**: http://localhost/api/health

---

## 📁 File Structure

```
.
├── docker-compose.yml          # Development setup
├── docker-compose.prod.yml     # Production setup (dengan nginx)
├── .env.example                # Template environment variables
├── deploy.sh                   # Deployment script
├── backup-db.sh                # Database backup script
├── backend/
│   ├── Dockerfile
│   └── .dockerignore
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .dockerignore
└── nginx/
    ├── nginx.conf
    └── conf.d/
        └── default.conf
```

---

## 🔧 Environment Variables

### Development (.env)

```env
POSTGRES_DB=absensi_db
POSTGRES_USER=absensi_user
POSTGRES_PASSWORD=your_password
JWT_SECRET=your_jwt_secret_32_chars_min
VITE_API_URL=http://localhost:3000/api
FRONTEND_URL=http://localhost
```

### Production (.env.production)

```env
POSTGRES_DB=absensi_db
POSTGRES_USER=absensi_user
POSTGRES_PASSWORD=VERY_SECURE_PASSWORD
JWT_SECRET=VERY_SECURE_JWT_SECRET
VITE_API_URL=https://api.yourdomain.com/api
FRONTEND_URL=https://yourdomain.com
```

---

## 📝 Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart service
docker-compose restart backend

# Execute command in container
docker-compose exec backend sh
docker-compose exec postgres psql -U absensi_user -d absensi_db

# Backup database
./backup-db.sh

# View resource usage
docker stats
```

---

## 🔍 Troubleshooting

### Port Already in Use
```bash
# Change port di .env atau stop service yang conflict
```

### Database Connection Error
```bash
# Check postgres container
docker-compose logs postgres

# Check DATABASE_URL
docker-compose exec backend env | grep DATABASE_URL
```

### Build Fails
```bash
# Clean build
docker-compose build --no-cache
```

---

## 📚 Dokumentasi Lengkap

Lihat [DEPLOYMENT.md](./DEPLOYMENT.md) untuk dokumentasi lengkap.

---

**Selamat Deploy! 🚀**

