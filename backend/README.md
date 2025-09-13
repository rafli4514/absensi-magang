# Backend - Absensi System API

Backend server untuk sistem absensi menggunakan Node.js, Express, dan TypeScript dengan struktur folder yang terorganisir.

## 📁 Struktur Proyek

```
backend/
├── src/
│   ├── config/           # Konfigurasi aplikasi (database, environment)
│   │   ├── database.ts   # Konfigurasi database (SQLite)
│   │   └── index.ts      # Konfigurasi umum aplikasi
│   ├── controllers/      # Logic untuk menangani request/response
│   │   ├── pesertaMagangController.ts
│   │   └── absensiController.ts
│   ├── models/           # Model database dengan Sequelize
│   │   ├── User.ts
│   │   ├── PesertaMagang.ts
│   │   ├── Absensi.ts
│   │   └── index.ts      # Database connection & sync
│   ├── routes/           # Definisi API routes
│   │   ├── pesertaMagangRoutes.ts
│   │   ├── absensiRoutes.ts
│   │   └── index.ts      # Main routes aggregator
│   ├── middleware/       # Custom middleware
│   │   ├── auth.ts       # JWT authentication
│   │   ├── cors.ts       # CORS configuration
│   │   ├── errorHandler.ts # Global error handling
│   │   └── upload.ts     # File upload configuration
│   ├── services/         # Business logic layer
│   │   └── authService.ts # Authentication services
│   ├── utils/            # Utility functions
│   │   ├── jwt.ts        # JWT token utilities
│   │   └── response.ts   # Response helper functions
│   ├── types/            # TypeScript type definitions
│   │   └── index.ts      # Shared types
│   └── index.ts          # Entry point aplikasi
├── uploads/              # Directory untuk file uploads
├── dist/                 # Compiled JavaScript (generated)
├── package.json
├── tsconfig.json
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v18 atau lebih baru)
- npm atau yarn

### Installation
```bash
npm install
```

### Development
```bash
npm run dev
```
Server akan berjalan di `http://localhost:3000` dengan hot reload.

### Production Build
```bash
npm run build
npm start
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/login` - Login user
- `POST /api/auth/register` - Register new user

### Peserta Magang
- `GET /api/peserta-magang` - Get all peserta magang (paginated)
- `GET /api/peserta-magang/:id` - Get peserta magang by ID
- `POST /api/peserta-magang` - Create new peserta magang (admin only)
- `PUT /api/peserta-magang/:id` - Update peserta magang (admin only)
- `DELETE /api/peserta-magang/:id` - Delete peserta magang (admin only)

### Absensi
- `GET /api/absensi` - Get all absensi records (paginated)
- `GET /api/absensi/:id` - Get absensi by ID
- `POST /api/absensi` - Create new absensi record (admin only)
- `PUT /api/absensi/:id` - Update absensi record (admin only)
- `DELETE /api/absensi/:id` - Delete absensi record (admin only)

### System
- `GET /` - API info
- `GET /api/health` - Health check

## 🔧 Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** SQLite dengan Sequelize ORM
- **Authentication:** JWT (JSON Web Tokens)
- **Security:** Helmet, CORS
- **File Upload:** Multer
- **Development:** nodemon, ts-node

## 🗃️ Database Models

### User
- id (UUID, Primary Key)
- username (String, Unique)
- email (String, Unique)
- password (String, Hashed)
- role (Enum: 'admin', 'user')
- isActive (Boolean)
- timestamps

### PesertaMagang
- id (UUID, Primary Key)
- nama (String)
- username (String, Unique)
- divisi (String)
- universitas (String)
- nomorHp (String)
- tanggalMulai (Date)
- tanggalSelesai (Date)
- status (Enum: 'Aktif', 'Nonaktif', 'Selesai')
- avatar (String, Optional)
- timestamps

### Absensi
- id (UUID, Primary Key)
- pesertaMagangId (UUID, Foreign Key)
- tipe (Enum: 'Masuk', 'Keluar', 'Izin', 'Sakit', 'Cuti')
- timestamp (Date)
- lokasi (Text, JSON, Optional)
- selfieUrl (String, Optional)
- qrCodeData (String, Optional)
- status (Enum: 'valid', 'Terlambat', 'invalid')
- timestamps

## 🔐 Authentication

API menggunakan JWT (JSON Web Token) untuk authentication. Sertakan token di header:

```
Authorization: Bearer <your-jwt-token>
```

## 📝 Environment Variables

Buat file `.env` di root directory:

```env
# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your-super-secret-key-here
JWT_EXPIRE=24h

# Database
DATABASE_URL=sqlite:./database.sqlite

# CORS
CORS_ORIGIN=http://localhost:5173

# Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
```

## 🛠️ Scripts

- `npm run dev` - Development server dengan hot reload
- `npm run build` - Compile TypeScript ke JavaScript
- `npm start` - Jalankan production server
- `npm test` - Run tests (belum diimplementasikan)

## 🔒 Security Features

- Helmet untuk HTTP headers security
- CORS configuration
- JWT authentication
- Password hashing dengan bcrypt
- Input validation
- File upload restrictions (images only, size limit)

## 📦 Dependencies

### Production
- express - Web framework
- sequelize - ORM untuk database
- sqlite3 - SQLite database driver
- bcrypt - Password hashing
- jsonwebtoken - JWT handling
- cors - CORS middleware
- helmet - Security headers
- morgan - HTTP request logger
- multer - File upload handling
- dotenv - Environment variables

### Development
- typescript - TypeScript compiler
- ts-node - TypeScript execution
- nodemon - Development auto-restart
- @types/* - TypeScript definitions

## 🔄 Development Workflow

1. **Development**: Gunakan `npm run dev` untuk development dengan hot reload
2. **Testing**: Pastikan TypeScript compilation berhasil dengan `npx tsc --noEmit`
3. **Build**: Compile ke JavaScript dengan `npm run build`
4. **Production**: Jalankan dengan `npm start`

## 📈 API Response Format

Semua API responses menggunakan format konsisten:

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "pagination": { ... } // untuk paginated responses
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error (development only)"
}
```

## 🚨 Error Handling

Aplikasi menggunakan global error handler yang menangani:
- Validation errors
- Authentication errors
- Database errors
- File upload errors
- General server errors

## 📝 Notes

- Database menggunakan SQLite untuk development (mudah setup)
- File uploads disimpan di folder `uploads/`
- JWT tokens expire dalam 24 jam (configurable)
- Admin routes memerlukan role 'admin'
- Password di-hash menggunakan bcrypt dengan salt rounds 10

## 🔮 Future Enhancements

- [ ] Unit tests dengan Jest
- [ ] API documentation dengan Swagger
- [ ] Rate limiting
- [ ] Database migrations
- [ ] Email notifications
- [ ] Role-based permissions yang lebih detail
- [ ] API versioning
- [ ] Database connection pooling
- [ ] Caching layer (Redis)
- [ ] Docker containerization
