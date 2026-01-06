# Dokumentasi Pengerjaan Backend - Sistem Absensi Magang

## 📋 Overview
Backend sistem absensi magang yang dibangun menggunakan Node.js, Express.js, TypeScript, dan Prisma ORM dengan database PostgreSQL. Sistem ini menyediakan API untuk manajemen peserta magang, absensi, pengajuan izin, dan dashboard.

## 🏗️ Arsitektur Sistem

### Tech Stack
- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript
- **ORM**: Prisma
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Token)
- **File Upload**: Multer
- **Security**: Helmet, CORS
- **Password Hashing**: bcryptjs

### Struktur Folder
```
backend/
├── src/
│   ├── controllers/     # Business logic controllers
│   ├── routes/         # API route definitions
│   ├── middleware/     # Custom middleware
│   ├── database/       # Database utilities & seeding
│   ├── lib/           # Prisma client configuration
│   ├── types/         # TypeScript type definitions
│   ├── utils/         # Utility functions
│   └── uploads/       # File upload storage
├── prisma/            # Database schema & migrations
├── scripts/           # Database scripts
└── package.json       # Dependencies & scripts
```

## 🗄️ Database Schema

### Models Utama

#### 1. User Model
```prisma
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
```

#### 2. PesertaMagang Model
```prisma
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
```

#### 3. Absensi Model
```prisma
model Absensi {
  id              String        @id @default(cuid())
  pesertaMagangId String
  tipe            TipeAbsensi
  timestamp       String
  lokasi          Json?
  selfieUrl       String?
  qrCodeData      String?
  status          StatusAbsensi @default(VALID)
  catatan         String?
  ipAddress       String?
  device          String?
  createdAt       DateTime      @default(now())
  updatedAt       DateTime      @updatedAt
  pesertaMagang   PesertaMagang @relation(fields: [pesertaMagangId], references: [id], onDelete: Cascade)
}
```

#### 4. PengajuanIzin Model
```prisma
model PengajuanIzin {
  id               String          @id @default(cuid())
  pesertaMagangId  String
  tipe             TipeIzin
  tanggalMulai     String
  tanggalSelesai   String
  alasan           String
  status           StatusPengajuan @default(PENDING)
  dokumenPendukung String?
  disetujuiOleh    String?
  disetujuiPada    String?
  catatan          String?
  createdAt        DateTime        @default(now())
  updatedAt        DateTime        @updatedAt
  pesertaMagang    PesertaMagang   @relation(fields: [pesertaMagangId], references: [id], onDelete: Cascade)
}
```

#### 5. Settings Model
```prisma
model Settings {
  id        String   @id @default(cuid())
  key       String   @unique
  value     Json
  category  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

### Enums
- **Role**: ADMIN, USER
- **StatusPeserta**: AKTIF, NONAKTIF, SELESAI
- **TipeAbsensi**: MASUK, KELUAR, IZIN, SAKIT, CUTI
- **StatusAbsensi**: VALID, INVALID, TERLAMBAT
- **TipeIzin**: SAKIT, IZIN, CUTI
- **StatusPengajuan**: PENDING, DISETUJUI, DITOLAK

## 🔧 Setup & Installation

### 1. Prerequisites
```bash
# Install Node.js (v18+)
# Install PostgreSQL
# Install npm atau yarn
```

### 2. Environment Setup
```bash
# Clone repository
git clone <repository-url>
cd backend

# Install dependencies
npm ci

# Setup environment variables
cp .env.example .env
```

### 3. Environment Variables
```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/absensi_db"

# JWT
JWT_SECRET="your-super-secret-jwt-key"

# Server
PORT=3000
NODE_ENV=development
```

### 4. Database Setup
```bash
# Generate Prisma client
npm run db:generate

# Run database migrations
npm run db:migrate

# Seed database with sample data
npm run db:seed
```

### 5. Development Server
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## 🚀 API Endpoints

### Authentication Routes (`/api/auth`)
- `POST /login` - Admin login
- `POST /login-peserta` - Peserta magang login
- `POST /register` - Register new user
- `GET /profile` - Get user profile
- `PUT /profile` - Update profile
- `POST /upload-avatar` - Upload avatar
- `DELETE /avatar` - Remove avatar
- `POST /refresh-token` - Refresh JWT token

### User Management (`/api/users`)
- `GET /` - Get all users (Admin only)
- `GET /:id` - Get user by ID
- `PUT /:id` - Update user
- `DELETE /:id` - Delete user
- `PUT /:id/activate` - Activate user
- `PUT /:id/deactivate` - Deactivate user

### Peserta Magang (`/api/peserta-magang`)
- `GET /` - Get all peserta magang
- `GET /:id` - Get peserta by ID
- `POST /` - Create new peserta
- `PUT /:id` - Update peserta
- `DELETE /:id` - Delete peserta
- `GET /:id/absensi` - Get absensi history
- `GET /:id/pengajuan-izin` - Get pengajuan izin history

### Absensi (`/api/absensi`)
- `GET /` - Get all absensi records
- `GET /:id` - Get absensi by ID
- `POST /` - Create new absensi
- `PUT /:id` - Update absensi
- `DELETE /:id` - Delete absensi
- `GET /peserta/:id` - Get absensi by peserta
- `GET /statistics` - Get absensi statistics

### Pengajuan Izin (`/api/pengajuan-izin`)
- `GET /` - Get all pengajuan izin
- `GET /:id` - Get pengajuan by ID
- `POST /` - Create new pengajuan
- `PUT /:id` - Update pengajuan
- `PUT /:id/approve` - Approve pengajuan
- `PUT /:id/reject` - Reject pengajuan
- `DELETE /:id` - Delete pengajuan

### Dashboard (`/api/dashboard`)
- `GET /statistics` - Get dashboard statistics
- `GET /recent-absensi` - Get recent absensi
- `GET /pending-izin` - Get pending izin requests

### Settings (`/api/settings`)
- `GET /` - Get all settings
- `GET /:key` - Get setting by key
- `POST /` - Create/update setting
- `PUT /:id` - Update setting
- `DELETE /:id` - Delete setting

## 🔐 Authentication & Authorization

### JWT Implementation
```typescript
// Token generation
const token = generateToken({
  id: user.id,
  username: user.username,
  role: user.role,
});

// Token verification middleware
export const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required',
    });
  }
  
  // Verify token and set user info
  // ...
};
```

### Role-based Access Control
- **ADMIN**: Full access to all endpoints
- **USER**: Limited access to own data
- **STUDENT**: Access to absensi and pengajuan izin

## 📁 File Upload System

### Multer Configuration
```typescript
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'src/uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});
```

### Supported File Types
- **Avatar**: PNG, JPG, JPEG, WEBP
- **Documents**: PDF, DOC, DOCX
- **Images**: PNG, JPG, JPEG, WEBP

## 🛡️ Security Features

### 1. Helmet Security Headers
```typescript
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "http://localhost:3000"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
    },
  },
}));
```

### 2. CORS Configuration
```typescript
const corsOptions = {
  origin: ['http://localhost:3000', 'http://localhost:5173'],
  credentials: true,
  optionsSuccessStatus: 200
};
```

### 3. Password Security
- bcryptjs hashing with salt rounds: 12
- Password validation requirements
- Secure password reset flow

### 4. Input Validation
- Request body validation
- File type validation
- SQL injection prevention via Prisma

## 📊 Database Operations

### 1. Prisma Client Setup
```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});

export { prisma };
```

### 2. Database Migrations
```bash
# Create new migration
npx prisma migrate dev --name migration_name

# Apply migrations
npx prisma migrate deploy

# Reset database
npx prisma migrate reset
```

### 3. Database Seeding
```typescript
// Seed admin user
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
```

## 🔄 Error Handling

### Global Error Handler
```typescript
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err);
  
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
};
```

### Response Utilities
```typescript
export const sendSuccess = (res, message, data, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

export const sendError = (res, message, statusCode = 500, error) => {
  return res.status(statusCode).json({
    success: false,
    message,
    error,
  });
};
```

## 📈 Performance Optimizations

### 1. Database Queries
- Prisma query optimization
- Pagination for large datasets
- Selective field loading
- Relationship eager loading

### 2. Caching Strategy
- Static file caching
- Database query result caching
- Session-based caching

### 3. File Management
- Image compression
- File size limits
- Automatic cleanup of old files

## 🧪 Testing & Development

### Development Scripts
```json
{
  "dev": "nodemon --exec ts-node src/index.ts",
  "build": "prisma generate && tsc",
  "start": "node dist/index.js",
  "db:migrate": "prisma migrate dev",
  "db:generate": "prisma generate",
  "db:studio": "prisma studio",
  "db:seed": "ts-node src/database/seed.ts"
}
```

### Database Management
```bash
# View database in Prisma Studio
npm run db:studio

# Reset and reseed database
npm run db:reset && npm run db:seed

# Backup database
npm run db:backup
```

## 🚀 Deployment

### Production Build
```bash
# Install dependencies
npm ci --only=production

# Generate Prisma client
npm run db:generate

# Build TypeScript
npm run build

# Start production server
npm start
```

### Environment Configuration
- Set `NODE_ENV=production`
- Configure production database URL
- Set secure JWT secret
- Configure CORS for production domains

## 📝 API Documentation

### Request/Response Format
```typescript
// Success Response
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}

// Error Response
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error info"
}

// Paginated Response
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10
  }
}
```

### Authentication Headers
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## 🔧 Maintenance & Monitoring

### Logging
- Morgan HTTP request logging
- Console error logging
- Database query logging

### Health Checks
- Database connection status
- Server uptime monitoring
- API endpoint health checks

### Backup Strategy
- Database backup scripts
- File upload backup
- Configuration backup

## 📚 Dependencies

### Production Dependencies
- `@prisma/client`: Database ORM
- `express`: Web framework
- `bcryptjs`: Password hashing
- `jsonwebtoken`: JWT authentication
- `cors`: Cross-origin resource sharing
- `helmet`: Security headers
- `morgan`: HTTP request logger
- `multer`: File upload handling
- `qrcode`: QR code generation

### Development Dependencies
- `typescript`: TypeScript compiler
- `ts-node`: TypeScript execution
- `nodemon`: Development server
- `@types/*`: TypeScript type definitions
- `prisma`: Database toolkit

## 🎯 Key Features Implemented

1. **User Management**: Complete CRUD operations for users
2. **Peserta Magang Management**: Student/intern management system
3. **Absensi System**: Check-in/check-out with location tracking
4. **Pengajuan Izin**: Leave request system with approval workflow
5. **Dashboard**: Statistics and analytics
6. **File Upload**: Avatar and document upload system
7. **Authentication**: JWT-based secure authentication
8. **Authorization**: Role-based access control
9. **Database**: PostgreSQL with Prisma ORM
10. **Security**: Comprehensive security measures

## 🔄 Future Enhancements

1. **Real-time Notifications**: WebSocket integration
2. **Email Notifications**: SMTP integration
3. **Advanced Reporting**: PDF report generation
4. **Mobile API**: Optimized endpoints for mobile
5. **Audit Logging**: Comprehensive activity tracking
6. **API Rate Limiting**: Request throttling
7. **Database Optimization**: Query performance tuning
8. **Microservices**: Service decomposition

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 2.0.0
