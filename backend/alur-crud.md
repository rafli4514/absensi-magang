# Alur Pembuatan CRUD - Sistem Absensi Magang

## 🎯 Overview
Dokumentasi ini menjelaskan langkah-langkah pembuatan CRUD (Create, Read, Update, Delete) secara sistematis dari setup database hingga implementasi API endpoints.

## 📋 Alur Pembuatan CRUD

### 1. 🗄️ Setup Database Schema dengan Prisma

#### Langkah 1.1: Install Prisma
```bash
npm ci prisma @prisma/client
npm ci -D prisma
```

#### Langkah 1.2: Initialize Prisma
```bash
npx prisma init
```

#### Langkah 1.3: Konfigurasi Database (schema.prisma)
```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  username  String   @unique
  password  String
  role      Role     @default(USER)
  isActive  Boolean  @default(true)
  avatar    String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  pesertaMagang PesertaMagang?
}

model PesertaMagang {
  id             String          @id @default(cuid())
  nama           String
  username       String          @unique
  divisi         String
  instansi       String
  id_instansi    String?
  nomorHp        String
  tanggalMulai   String
  tanggalSelesai String
  status         StatusPeserta   @default(AKTIF)
  avatar         String?
  createdAt      DateTime        @default(now())
  updatedAt      DateTime        @updatedAt
  
  userId         String?         @unique
  user           User?           @relation(fields: [userId], references: [id], onDelete: Cascade)
  absensi        Absensi[]
  pengajuanIzin  PengajuanIzin[]
}

// ... model lainnya
```

### 2. 🌱 Database Seeding

#### Langkah 2.1: Buat File Seed (src/database/seed.ts)
```typescript
import { PrismaClient, Role, StatusPeserta } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting database seeding...");

  // Create admin user
  const hashedPassword = await bcrypt.hash("admin123", 10);
  
  const adminUser = await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: {
      username: "admin",
      password: hashedPassword,
      role: Role.ADMIN,
      isActive: true,
    },
  });

  // Create sample peserta magang
  const pesertaMagang = await prisma.pesertaMagang.upsert({
    where: { username: "johndoe" },
    update: {},
    create: {
      nama: "John Doe",
      username: "johndoe",
      divisi: "IT Development",
      instansi: "PLN Icon Plus",
      nomorHp: "081234567890",
      tanggalMulai: "2024-01-01",
      tanggalSelesai: "2024-06-30",
      status: StatusPeserta.AKTIF,
    },
  });

  console.log("✅ Seeding completed!");
}

main()
  .catch((e) => {
    console.error("❌ Error during seeding:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

#### Langkah 2.2: Setup Script di package.json
```json
{
  "scripts": {
    "db:seed": "ts-node src/database/seed.ts",
    "db:migrate": "prisma migrate dev",
    "db:generate": "prisma generate"
  }
}
```

### 3. 🔧 Setup Prisma Client Library

#### Langkah 3.1: Buat Prisma Client (src/lib/prisma.ts)
```typescript
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: ['query', 'error', 'warn'],
});

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

**Penjelasan:**
- `globalForPrisma`: Mencegah multiple instance Prisma di development
- `log`: Mengaktifkan logging untuk debugging
- Singleton pattern untuk efisiensi koneksi

### 4. 🔌 Database Connection Management

#### Langkah 4.1: Buat Connection Handler (src/database/connection.ts)
```typescript
import { PrismaClient } from '@prisma/client';

// Global variable to store Prisma client instance
declare global {
  var __prisma: PrismaClient | undefined;
}

// Create Prisma client instance
const prisma = globalThis.__prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  errorFormat: 'pretty',
});

// In development, save the client to global variable to prevent multiple instances
if (process.env.NODE_ENV === 'development') {
  globalThis.__prisma = prisma;
}

export default prisma;

// Database connection helper
export const connectDatabase = async (): Promise<void> => {
  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    throw error;
  }
};

// Database disconnection helper
export const disconnectDatabase = async (): Promise<void> => {
  try {
    await prisma.$disconnect();
    console.log('📴 Database disconnected');
  } catch (error) {
    console.error('❌ Database disconnection failed:', error);
    throw error;
  }
};

// Health check for database
export const checkDatabaseHealth = async (): Promise<boolean> => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch (error) {
    console.error('❌ Database health check failed:', error);
    return false;
  }
};
```

**Penjelasan:**
- `connectDatabase()`: Membuka koneksi ke database
- `disconnectDatabase()`: Menutup koneksi database
- `checkDatabaseHealth()`: Mengecek status koneksi database
- Global variable untuk mencegah multiple instance

### 5. 📦 Database Module Index

#### Langkah 5.1: Buat Database Index (src/database/index.ts)
```typescript
// Database module exports
export { default as prisma, connectDatabase, disconnectDatabase, checkDatabaseHealth } from './connection';
export { default as DatabaseMigrations } from './migrations';

// Re-export Prisma types for convenience
export type { PrismaClient } from '@prisma/client';
export type { 
  User, 
  PesertaMagang, 
  Absensi, 
  PengajuanIzin,
  Role,
  StatusPeserta,
  TipeAbsensi,
  StatusAbsensi,
  TipeIzin,
  StatusPengajuan
} from '@prisma/client';
```

**Penjelasan:**
- Centralized export untuk semua database utilities
- Re-export Prisma types untuk kemudahan import
- Single source of truth untuk database operations

### 6. 🛠️ Utility Functions

#### Langkah 6.1: Response Utilities (src/utils/response.ts)
```typescript
import { type Response } from 'express';
import { ApiResponse, PaginatedResponse } from '../types';

export const sendSuccess = <T>(
  res: Response<ApiResponse<T>>,
  message: string,
  data?: T,
  statusCode = 200
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

export const sendError = (
  res: Response<ApiResponse>,
  message: string,
  statusCode = 500,
  error?: string
) => {
  return res.status(statusCode).json({
    success: false,
    message,
    error,
  });
};

export const sendPaginatedSuccess = <T>(
  res: Response<PaginatedResponse<T>>,
  message: string,
  data: T[],
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  },
  statusCode = 200
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    pagination,
  });
};
```

### 7. 🎮 Controller Implementation

#### Langkah 7.1: CRUD Controller (src/controllers/pesertaMagangController.ts)

**CREATE - Tambah Data**
```typescript
export const createPesertaMagang = async (req: Request, res: Response) => {
  try {
    const {
      nama,
      username,
      divisi,
      instansi,
      id_instansi,
      nomorHp,
      tanggalMulai,
      tanggalSelesai,
      status = "AKTIF"
    } = req.body;

    // Validasi input
    if (!nama || !username || !divisi || !nomorHp || !tanggalMulai || !tanggalSelesai) {
      return sendError(res, "Semua field wajib diisi", 400);
    }

    // Cek apakah username sudah ada
    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { username }
    });

    if (existingPeserta) {
      return sendError(res, "Username sudah digunakan", 400);
    }

    // Buat peserta magang baru
    const pesertaMagang = await prisma.pesertaMagang.create({
      data: {
        nama,
        username,
        divisi,
        instansi,
        id_instansi,
        nomorHp,
        tanggalMulai,
        tanggalSelesai,
        status: status as StatusPeserta,
      },
      include: {
        user: true,
        absensi: true,
        pengajuanIzin: true,
      },
    });

    sendSuccess(res, "Peserta magang berhasil dibuat", pesertaMagang, 201);
  } catch (error) {
    console.error("Create peserta magang error:", error);
    sendError(res, "Gagal membuat peserta magang", 500);
  }
};
```

**READ - Baca Data**
```typescript
// Get All dengan Pagination
export const getAllPesertaMagang = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const skip = (page - 1) * limit;
    const status = req.query.status as string;

    // Build where clause
    const where: any = {};
    if (status && status !== "Semua") {
      where.status = status.toUpperCase();
    }

    // Parallel queries untuk performa
    const [pesertaMagang, total] = await Promise.all([
      prisma.pesertaMagang.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          user: {
            select: {
              id: true,
              username: true,
              role: true,
              isActive: true,
            },
          },
        },
      }),
      prisma.pesertaMagang.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    sendPaginatedSuccess(
      res,
      "Peserta magang berhasil diambil",
      pesertaMagang,
      { page, limit, total, totalPages }
    );
  } catch (error) {
    console.error("Get all peserta magang error:", error);
    sendError(res, "Gagal mengambil data peserta magang");
  }
};

// Get By ID
export const getPesertaMagangById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const pesertaMagang = await prisma.pesertaMagang.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            role: true,
            isActive: true,
          },
        },
        absensi: {
          orderBy: { createdAt: "desc" },
          take: 10,
        },
        pengajuanIzin: {
          orderBy: { createdAt: "desc" },
          take: 5,
        },
      },
    });

    if (!pesertaMagang) {
      return sendError(res, "Peserta magang tidak ditemukan", 404);
    }

    sendSuccess(res, "Peserta magang berhasil diambil", pesertaMagang);
  } catch (error) {
    console.error("Get peserta magang by ID error:", error);
    sendError(res, "Gagal mengambil data peserta magang");
  }
};
```

**UPDATE - Update Data**
```typescript
export const updatePesertaMagang = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const {
      nama,
      username,
      divisi,
      instansi,
      id_instansi,
      nomorHp,
      tanggalMulai,
      tanggalSelesai,
      status
    } = req.body;

    // Cek apakah peserta magang ada
    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { id }
    });

    if (!existingPeserta) {
      return sendError(res, "Peserta magang tidak ditemukan", 404);
    }

    // Cek username unik (kecuali untuk user yang sama)
    if (username && username !== existingPeserta.username) {
      const usernameExists = await prisma.pesertaMagang.findFirst({
        where: {
          username,
          id: { not: id }
        }
      });

      if (usernameExists) {
        return sendError(res, "Username sudah digunakan", 400);
      }
    }

    // Update data
    const updatedPeserta = await prisma.pesertaMagang.update({
      where: { id },
      data: {
        ...(nama && { nama }),
        ...(username && { username }),
        ...(divisi && { divisi }),
        ...(instansi && { instansi }),
        ...(id_instansi !== undefined && { id_instansi }),
        ...(nomorHp && { nomorHp }),
        ...(tanggalMulai && { tanggalMulai }),
        ...(tanggalSelesai && { tanggalSelesai }),
        ...(status && { status: status as StatusPeserta }),
      },
      include: {
        user: true,
        absensi: true,
        pengajuanIzin: true,
      },
    });

    sendSuccess(res, "Peserta magang berhasil diupdate", updatedPeserta);
  } catch (error) {
    console.error("Update peserta magang error:", error);
    sendError(res, "Gagal mengupdate peserta magang", 500);
  }
};
```

**DELETE - Hapus Data**
```typescript
export const deletePesertaMagang = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Cek apakah peserta magang ada
    const existingPeserta = await prisma.pesertaMagang.findUnique({
      where: { id }
    });

    if (!existingPeserta) {
      return sendError(res, "Peserta magang tidak ditemukan", 404);
    }

    // Hapus avatar file jika ada
    if (existingPeserta.avatar) {
      try {
        const filename = path.basename(existingPeserta.avatar);
        const filePath = path.join(__dirname, "..", "uploads", filename);
        
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
          console.log(`Avatar file deleted: ${filename}`);
        }
      } catch (fileError) {
        console.error("Error deleting avatar file:", fileError);
      }
    }

    // Hapus peserta magang (akan cascade delete relasi)
    await prisma.pesertaMagang.delete({
      where: { id }
    });

    sendSuccess(res, "Peserta magang berhasil dihapus");
  } catch (error) {
    console.error("Delete peserta magang error:", error);
    sendError(res, "Gagal menghapus peserta magang", 500);
  }
};
```

### 8. 🛣️ Route Configuration

#### Langkah 8.1: Route Definition (src/routes/pesertaMagangRoutes.ts)
```typescript
import { Router } from 'express';
import {
  getAllPesertaMagang,
  getPesertaMagangById,
  createPesertaMagang,
  updatePesertaMagang,
  deletePesertaMagang,
  getAbsensiByPeserta,
  getPengajuanIzinByPeserta,
} from '../controllers/pesertaMagangController';
import { authenticateToken, requireAdmin } from '../middleware/auth';
import { upload } from '../middleware/upload';

const router = Router();

// Public routes (jika ada)
// router.get('/public', getPublicData);

// Protected routes
router.get('/', authenticateToken, getAllPesertaMagang);
router.get('/:id', authenticateToken, getPesertaMagangById);
router.post('/', authenticateToken, requireAdmin, createPesertaMagang);
router.put('/:id', authenticateToken, requireAdmin, updatePesertaMagang);
router.delete('/:id', authenticateToken, requireAdmin, deletePesertaMagang);

// Related data routes
router.get('/:id/absensi', authenticateToken, getAbsensiByPeserta);
router.get('/:id/pengajuan-izin', authenticateToken, getPengajuanIzinByPeserta);

export default router;
```

#### Langkah 8.2: Main Routes (src/routes/index.ts)
```typescript
import { Router } from 'express';
import pesertaMagangRoutes from './pesertaMagangRoutes';
import absensiRoutes from './absensiRoutes';
import userRoutes from './userRoutes';
import authRoutes from './authRoutes';

const router = Router();

// Health check
router.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API Routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/peserta-magang', pesertaMagangRoutes);
router.use('/absensi', absensiRoutes);

export default router;
```

### 9. 🔐 Middleware Implementation

#### Langkah 9.1: Authentication Middleware (src/middleware/auth.ts)
```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required',
    });
  }

  try {
    const secret = process.env.JWT_SECRET || 'your-secret-key';
    const decoded = jwt.verify(token, secret) as any;

    req.user = {
      id: decoded.id,
      username: decoded.username,
      role: decoded.role,
    };

    next();
  } catch (error) {
    return res.status(403).json({
      success: false,
      message: 'Invalid or expired token',
    });
  }
};

export const requireAdmin = (req: Request, res: Response, next: NextFunction) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({
      success: false,
      message: 'Admin access required',
    });
  }
  next();
};
```

### 10. 🚀 Server Integration

#### Langkah 10.1: Main Server (src/index.ts)
```typescript
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';

// Load environment variables
dotenv.config();

// Import routes
import routes from './routes';
import { connectDatabase } from './database/connection';

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api', routes);

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
  });
});

// Start server
const startServer = async () => {
  try {
    await connectDatabase();
    
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
```

## 🔄 Alur Eksekusi CRUD

### 1. **Database Setup**
```
Prisma Schema → Migration → Generate Client → Seed Data
```

### 2. **Request Flow**
```
Client Request → Middleware → Route → Controller → Prisma → Database
```

### 3. **Response Flow**
```
Database → Prisma → Controller → Response Utils → Client
```

## 📊 Best Practices

### 1. **Error Handling**
- Try-catch di setiap controller
- Consistent error response format
- Logging untuk debugging

### 2. **Validation**
- Input validation di controller
- Database constraints di schema
- Business logic validation

### 3. **Performance**
- Pagination untuk large datasets
- Parallel queries dengan Promise.all
- Selective field loading dengan include/select

### 4. **Security**
- Authentication middleware
- Authorization checks
- Input sanitization
- File upload validation

## 🎯 Testing CRUD

### 1. **Manual Testing**
```bash
# Create
curl -X POST http://localhost:3000/api/peserta-magang \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"nama":"John Doe","username":"johndoe","divisi":"IT"}'

# Read
curl -X GET http://localhost:3000/api/peserta-magang \
  -H "Authorization: Bearer <token>"

# Update
curl -X PUT http://localhost:3000/api/peserta-magang/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"nama":"John Updated"}'

# Delete
curl -X DELETE http://localhost:3000/api/peserta-magang/1 \
  -H "Authorization: Bearer <token>"
```

### 2. **Database Verification**
```sql
-- Check data
SELECT * FROM peserta_magang;
SELECT * FROM users;
SELECT * FROM absensi;
```

## 🎉 Kesimpulan

Alur pembuatan CRUD meliputi:
1. **Database Schema** dengan Prisma
2. **Seeding** untuk data awal
3. **Prisma Client** setup
4. **Connection Management**
5. **Controller Implementation** (CRUD operations)
6. **Route Configuration**
7. **Middleware Integration**
8. **Server Setup**

Setiap langkah saling terhubung dan membentuk sistem yang robust untuk operasi database dan API endpoints.

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0
