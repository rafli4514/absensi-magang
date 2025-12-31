# 🧪 Testing Guide - Quick Start

Panduan cepat untuk menjalankan test sebelum deployment.

## 📋 Prerequisites

1. **Install Dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Setup Test Database** (Opsional, untuk integration tests):
   ```bash
   # Buat test database
   createdb -U postgres absensi_test_db
   
   # Atau via psql
   psql -U postgres
   CREATE DATABASE absensi_test_db;
   ```

## 🚀 Quick Testing (Tanpa Setup Database)

### 1. Manual API Testing dengan cURL

**Test Health Check:**
```bash
curl http://localhost:3000/api/health
```

**Test Login (dengan data real):**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your_password"}'
```

### 2. Quick Test Script

```bash
cd backend/tests/scripts
chmod +x quick-test.sh
./quick-test.sh http://localhost:3000/api
```

### 3. API Test Script (Lebih Lengkap)

```bash
cd backend/tests/scripts
chmod +x test-api.sh
./test-api.sh http://localhost:3000/api
```

## 🧪 Automated Testing (Jest)

### Setup Test Environment

1. **Install Dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Setup Test Database** (Recommended):
   ```env
   # .env.test
   DATABASE_URL=postgresql://user:pass@localhost:5432/absensi_test_db?schema=public
   JWT_SECRET=test-secret-key
   NODE_ENV=test
   ```

3. **Run Migrations:**
   ```bash
   # Set test database URL
   export DATABASE_URL="postgresql://user:pass@localhost:5432/absensi_test_db?schema=public"
   npx prisma migrate deploy
   ```

### Run Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run with coverage
npm run test:coverage

# Run specific test file
npm test -- health.test.ts
npm test -- auth.test.ts
```

## 📝 Test Files yang Tersedia

1. **`tests/api/health.test.ts`** - Health check endpoint
2. **`tests/api/auth.test.ts`** - Authentication endpoints
3. **`tests/api/absensi.test.ts`** - Absensi endpoints
4. **`tests/api/dashboard.test.ts`** - Dashboard endpoints
5. **`tests/api/users.test.ts`** - User management endpoints

## ✅ Pre-Deployment Checklist

Sebelum deploy, test minimal ini:

### Critical Tests (Must Pass)

- [ ] **Health Check**
  ```bash
  curl http://localhost:3000/api/health
  # Expected: {"status":"OK",...}
  ```

- [ ] **Login Admin**
  ```bash
  curl -X POST http://localhost:3000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"your_password"}'
  # Expected: 200 dengan token
  ```

- [ ] **Login Peserta**
  ```bash
  curl -X POST http://localhost:3000/api/auth/login-peserta \
    -H "Content-Type: application/json" \
    -d '{"username":"peserta_username","password":"password"}'
  # Expected: 200 dengan token
  ```

- [ ] **Protected Endpoints (tanpa auth harus 401)**
  ```bash
  curl http://localhost:3000/api/users
  # Expected: 401 Unauthorized
  
  curl http://localhost:3000/api/absensi
  # Expected: 401 Unauthorized
  ```

- [ ] **Dashboard Statistics**
  ```bash
  TOKEN="your_admin_token"
  curl http://localhost:3000/api/dashboard/statistics \
    -H "Authorization: Bearer $TOKEN"
  # Expected: 200 dengan statistics data
  ```

### Functional Tests

- [ ] Clock in via API bekerja
- [ ] Clock out via API bekerja
- [ ] Create user (admin only) bekerja
- [ ] Get absensi list bekerja
- [ ] Settings bisa di-update

## 🔍 Troubleshooting

### Test Fails: Database Connection

```bash
# Check if database is running
pg_isready -h localhost -p 5432

# Check if test database exists
psql -U postgres -l | grep absensi_test
```

### Test Fails: Port Already in Use

```bash
# Check what's using port 3000
lsof -i :3000
# or
netstat -ano | findstr :3000  # Windows

# Kill the process or change PORT
```

### Jest Not Found

```bash
# Install dependencies
npm install

# Check if jest is installed
npx jest --version
```

## 📚 More Information

Lihat `backend/tests/README.md` untuk dokumentasi lengkap tentang testing.

---

**Happy Testing! 🧪**

