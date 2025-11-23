# Sequence Diagram
## Sistem Absensi Magang

## 📊 Overview
Dokumen ini menjelaskan sequence diagram untuk interaksi antar komponen dalam sistem absensi magang.

## 🔄 Sequence Diagrams

### 1. Sequence Diagram: Login Process

```mermaid
sequenceDiagram
    participant Client
    participant AuthController
    participant AuthService
    participant Prisma
    participant Database
    participant JWT

    Client->>AuthController: POST /api/auth/login (username, password)
    AuthController->>AuthService: validateCredentials(username, password)
    AuthService->>Prisma: user.findUnique({username})
    Prisma->>Database: SELECT * FROM users WHERE username = ?
    Database-->>Prisma: User data
    Prisma-->>AuthService: User object
    
    alt User not found
        AuthService-->>AuthController: Error: Invalid credentials
        AuthController-->>Client: 401 Unauthorized
    else User found
        AuthService->>AuthService: bcrypt.compare(password, user.password)
        alt Password incorrect
            AuthService-->>AuthController: Error: Invalid credentials
            AuthController-->>Client: 401 Unauthorized
        else Password correct
            alt User not active
                AuthService-->>AuthController: Error: Account inactive
                AuthController-->>Client: 403 Forbidden
            else User active
                AuthService->>JWT: sign({id, username, role})
                JWT-->>AuthService: Token
                AuthService-->>AuthController: {user, token}
                AuthController-->>Client: 200 OK {success, data: {user, token}}
            end
        end
    end
```

### 2. Sequence Diagram: Absensi Masuk Process

```mermaid
sequenceDiagram
    participant MobileApp
    participant AbsensiController
    participant AbsensiService
    participant SettingsService
    participant LocationService
    participant Prisma
    participant Database

    MobileApp->>AbsensiController: POST /api/absensi (data)
    AbsensiController->>AbsensiService: createAbsensi(data)
    
    AbsensiService->>Prisma: pesertaMagang.findUnique({id})
    Prisma->>Database: SELECT * FROM peserta_magang WHERE id = ?
    Database-->>Prisma: PesertaMagang data
    Prisma-->>AbsensiService: PesertaMagang object
    
    alt Peserta not found or not active
        AbsensiService-->>AbsensiController: Error: Peserta tidak aktif
        AbsensiController-->>MobileApp: 400 Bad Request
    else Peserta active
        AbsensiService->>SettingsService: loadAppSettings()
        SettingsService->>Prisma: settings.findMany()
        Prisma->>Database: SELECT * FROM settings
        Database-->>Prisma: Settings array
        Prisma-->>SettingsService: Settings
        SettingsService-->>AbsensiService: AppSettings
        
        AbsensiService->>AbsensiService: validateWorkDay(settings)
        AbsensiService->>AbsensiService: validateWorkHours(settings)
        
        alt Not work day or outside work hours
            AbsensiService-->>AbsensiController: Error: Outside work schedule
            AbsensiController-->>MobileApp: 400 Bad Request
        else Valid schedule
            AbsensiService->>LocationService: validateLocation(gps, settings)
            LocationService-->>AbsensiService: Location valid/invalid
            
            alt Location invalid
                AbsensiService-->>AbsensiController: Error: Location invalid
                AbsensiController-->>MobileApp: 400 Bad Request
            else Location valid
                AbsensiService->>AbsensiService: checkLateStatus(timestamp, settings)
                AbsensiService->>AbsensiService: determineStatus()
                
                AbsensiService->>Prisma: absensi.create({data})
                Prisma->>Database: INSERT INTO absensi VALUES (...)
                Database-->>Prisma: New Absensi record
                Prisma-->>AbsensiService: Absensi object
                
                AbsensiService-->>AbsensiController: Absensi created
                AbsensiController-->>MobileApp: 201 Created {success, data}
            end
        end
    end
```

### 3. Sequence Diagram: Create Pengajuan Izin Process

```mermaid
sequenceDiagram
    participant Client
    participant PengajuanIzinController
    participant PengajuanIzinService
    participant FileService
    participant Prisma
    participant Database

    Client->>PengajuanIzinController: POST /api/pengajuan-izin (data, file)
    PengajuanIzinController->>PengajuanIzinService: createPengajuanIzin(data)
    
    PengajuanIzinService->>Prisma: pesertaMagang.findUnique({id})
    Prisma->>Database: SELECT * FROM peserta_magang WHERE id = ?
    Database-->>Prisma: PesertaMagang data
    Prisma-->>PengajuanIzinService: PesertaMagang object
    
    alt Peserta not found
        PengajuanIzinService-->>PengajuanIzinController: Error: Peserta tidak ditemukan
        PengajuanIzinController-->>Client: 404 Not Found
    else Peserta found
        PengajuanIzinService->>PengajuanIzinService: validateDates(tanggalMulai, tanggalSelesai)
        
        alt Invalid dates
            PengajuanIzinService-->>PengajuanIzinController: Error: Tanggal tidak valid
            PengajuanIzinController-->>Client: 400 Bad Request
        else Valid dates
            alt File uploaded
                PengajuanIzinService->>FileService: uploadDocument(file)
                FileService-->>PengajuanIzinService: documentUrl
            end
            
            PengajuanIzinService->>Prisma: pengajuanIzin.create({data, status: PENDING})
            Prisma->>Database: INSERT INTO pengajuan_izin VALUES (...)
            Database-->>Prisma: New PengajuanIzin record
            Prisma-->>PengajuanIzinService: PengajuanIzin object
            
            PengajuanIzinService-->>PengajuanIzinController: Pengajuan created
            PengajuanIzinController-->>Client: 201 Created {success, data}
        end
    end
```

### 4. Sequence Diagram: Approve Pengajuan Izin Process

```mermaid
sequenceDiagram
    participant Admin
    participant PengajuanIzinController
    participant AuthMiddleware
    participant PengajuanIzinService
    participant Prisma
    participant Database
    participant NotificationService

    Admin->>PengajuanIzinController: PATCH /api/pengajuan-izin/:id/approve
    PengajuanIzinController->>AuthMiddleware: authenticateToken()
    AuthMiddleware-->>PengajuanIzinController: User authenticated
    
    PengajuanIzinController->>AuthMiddleware: requireAdmin()
    AuthMiddleware-->>PengajuanIzinController: Admin verified
    
    PengajuanIzinController->>PengajuanIzinService: approvePengajuanIzin(id, adminId)
    
    PengajuanIzinService->>Prisma: pengajuanIzin.findUnique({id})
    Prisma->>Database: SELECT * FROM pengajuan_izin WHERE id = ?
    Database-->>Prisma: PengajuanIzin data
    Prisma-->>PengajuanIzinService: PengajuanIzin object
    
    alt Pengajuan not found
        PengajuanIzinService-->>PengajuanIzinController: Error: Pengajuan tidak ditemukan
        PengajuanIzinController-->>Admin: 404 Not Found
    else Pengajuan found
        alt Status not PENDING
            PengajuanIzinService-->>PengajuanIzinController: Error: Status bukan PENDING
            PengajuanIzinController-->>Admin: 400 Bad Request
        else Status PENDING
            PengajuanIzinService->>Prisma: pengajuanIzin.update({status: DISETUJUI, disetujuiOleh, disetujuiPada})
            Prisma->>Database: UPDATE pengajuan_izin SET status = ?, disetujui_oleh = ?, disetujui_pada = ? WHERE id = ?
            Database-->>Prisma: Updated PengajuanIzin
            Prisma-->>PengajuanIzinService: PengajuanIzin object
            
            PengajuanIzinService->>NotificationService: sendNotification(pesertaId, "Pengajuan disetujui")
            NotificationService-->>PengajuanIzinService: Notification sent
            
            PengajuanIzinService-->>PengajuanIzinController: Pengajuan approved
            PengajuanIzinController-->>Admin: 200 OK {success, data}
        end
    end
```

### 5. Sequence Diagram: Get Dashboard Statistics

```mermaid
sequenceDiagram
    participant Client
    participant DashboardController
    participant DashboardService
    participant Prisma
    participant Database

    Client->>DashboardController: GET /api/dashboard/stats
    DashboardController->>DashboardService: getDashboardStats(userId, role)
    
    alt Role = ADMIN
        DashboardService->>Prisma: pesertaMagang.count()
        Prisma->>Database: SELECT COUNT(*) FROM peserta_magang
        Database-->>Prisma: Total count
        Prisma-->>DashboardService: totalPesertaMagang
        
        DashboardService->>Prisma: pesertaMagang.count({status: AKTIF})
        Prisma->>Database: SELECT COUNT(*) FROM peserta_magang WHERE status = 'AKTIF'
        Database-->>Prisma: Active count
        Prisma-->>DashboardService: pesertaMagangAktif
        
        DashboardService->>Prisma: absensi.findMany({tipe: MASUK, today})
        Prisma->>Database: SELECT * FROM absensi WHERE tipe = 'MASUK' AND DATE(timestamp) = TODAY
        Database-->>Prisma: Absensi array
        Prisma-->>DashboardService: absensiMasukHariIni
        
        DashboardService->>Prisma: absensi.findMany({tipe: KELUAR, today})
        Prisma->>Database: SELECT * FROM absensi WHERE tipe = 'KELUAR' AND DATE(timestamp) = TODAY
        Database-->>Prisma: Absensi array
        Prisma-->>DashboardService: absensiKeluarHariIni
        
        DashboardService->>DashboardService: calculateTingkatKehadiran()
        DashboardService-->>DashboardController: DashboardStats
    else Role = PESERTA_MAGANG
        DashboardService->>Prisma: absensi.findMany({pesertaMagangId: userId})
        Prisma->>Database: SELECT * FROM absensi WHERE peserta_magang_id = ?
        Database-->>Prisma: Absensi array
        Prisma-->>DashboardService: absensiPribadi
        
        DashboardService->>Prisma: pengajuanIzin.findMany({pesertaMagangId: userId})
        Prisma->>Database: SELECT * FROM pengajuan_izin WHERE peserta_magang_id = ?
        Database-->>Prisma: PengajuanIzin array
        Prisma-->>DashboardService: pengajuanIzin
        
        DashboardService-->>DashboardController: PesertaDashboardStats
    end
    
    DashboardController-->>Client: 200 OK {success, data: stats}
```

### 6. Sequence Diagram: Create Peserta Magang (Admin)

```mermaid
sequenceDiagram
    participant Admin
    participant PesertaMagangController
    participant AuthMiddleware
    participant PesertaMagangService
    participant UserService
    participant Prisma
    participant Database

    Admin->>PesertaMagangController: POST /api/peserta-magang (data)
    PesertaMagangController->>AuthMiddleware: authenticateToken()
    AuthMiddleware-->>PesertaMagangController: User authenticated
    
    PesertaMagangController->>AuthMiddleware: requireAdmin()
    AuthMiddleware-->>PesertaMagangController: Admin verified
    
    PesertaMagangController->>PesertaMagangService: createPesertaMagang(data)
    
    PesertaMagangService->>PesertaMagangService: validateInput(data)
    
    alt Invalid input
        PesertaMagangService-->>PesertaMagangController: Error: Validation failed
        PesertaMagangController-->>Admin: 400 Bad Request
    else Valid input
        PesertaMagangService->>Prisma: pesertaMagang.findUnique({username})
        Prisma->>Database: SELECT * FROM peserta_magang WHERE username = ?
        Database-->>Prisma: Result
        Prisma-->>PesertaMagangService: Existing peserta or null
        
        alt Username exists
            PesertaMagangService-->>PesertaMagangController: Error: Username sudah digunakan
            PesertaMagangController-->>Admin: 400 Bad Request
        else Username available
            alt Create user account
                PesertaMagangService->>UserService: createUser(username, password, role: USER)
                UserService->>Prisma: user.create({data})
                Prisma->>Database: INSERT INTO users VALUES (...)
                Database-->>Prisma: New User
                Prisma-->>UserService: User object
                UserService-->>PesertaMagangService: User created
            end
            
            PesertaMagangService->>Prisma: pesertaMagang.create({data, userId})
            Prisma->>Database: INSERT INTO peserta_magang VALUES (...)
            Database-->>Prisma: New PesertaMagang
            Prisma-->>PesertaMagangService: PesertaMagang object
            
            PesertaMagangService-->>PesertaMagangController: PesertaMagang created
            PesertaMagangController-->>Admin: 201 Created {success, data}
        end
    end
```

### 7. Sequence Diagram: Create Logbook Process

```mermaid
sequenceDiagram
    participant Client
    participant LogbookController
    participant LogbookService
    participant Prisma
    participant Database

    Client->>LogbookController: POST /api/logbook (data)
    LogbookController->>LogbookService: createLogbook(data)
    
    LogbookService->>Prisma: pesertaMagang.findUnique({id})
    Prisma->>Database: SELECT * FROM peserta_magang WHERE id = ?
    Database-->>Prisma: PesertaMagang data
    Prisma-->>LogbookService: PesertaMagang object
    
    alt Peserta not found or not active
        LogbookService-->>LogbookController: Error: Peserta tidak aktif
        LogbookController-->>Client: 400 Bad Request
    else Peserta active
        LogbookService->>LogbookService: validateInput(data)
        
        alt Invalid input
            LogbookService-->>LogbookController: Error: Validation failed
            LogbookController-->>Client: 400 Bad Request
        else Valid input
            LogbookService->>LogbookService: validateDate(tanggal)
            
            alt Invalid date
                LogbookService-->>LogbookController: Error: Tanggal tidak valid
                LogbookController-->>Client: 400 Bad Request
            else Valid date
                LogbookService->>Prisma: logbook.create({data, status: DRAFT})
                Prisma->>Database: INSERT INTO logbook VALUES (...)
                Database-->>Prisma: New Logbook record
                Prisma-->>LogbookService: Logbook object
                
                LogbookService-->>LogbookController: Logbook created
                LogbookController-->>Client: 201 Created {success, data}
            end
        end
    end
```

### 8. Sequence Diagram: Submit Logbook Process

```mermaid
sequenceDiagram
    participant Client
    participant LogbookController
    participant LogbookService
    participant Prisma
    participant Database
    participant NotificationService

    Client->>LogbookController: PATCH /api/logbook/:id/submit
    LogbookController->>LogbookService: submitLogbook(id)
    
    LogbookService->>Prisma: logbook.findUnique({id})
    Prisma->>Database: SELECT * FROM logbook WHERE id = ?
    Database-->>Prisma: Logbook data
    Prisma-->>LogbookService: Logbook object
    
    alt Logbook not found
        LogbookService-->>LogbookController: Error: Logbook tidak ditemukan
        LogbookController-->>Client: 404 Not Found
    else Logbook found
        alt Status not DRAFT
            LogbookService-->>LogbookController: Error: Status bukan DRAFT
            LogbookController-->>Client: 400 Bad Request
        else Status DRAFT
            LogbookService->>Prisma: logbook.update({status: SUBMITTED})
            Prisma->>Database: UPDATE logbook SET status = ? WHERE id = ?
            Database-->>Prisma: Updated Logbook
            Prisma-->>LogbookService: Logbook object
            
            LogbookService->>NotificationService: sendNotification(pembimbingId, "Logbook baru disubmit")
            NotificationService-->>LogbookService: Notification sent
            
            LogbookService-->>LogbookController: Logbook submitted
            LogbookController-->>Client: 200 OK {success, data}
        end
    end
```

### 9. Sequence Diagram: Get All Absensi with Pagination

```mermaid
sequenceDiagram
    participant Client
    participant AbsensiController
    participant AbsensiService
    participant Prisma
    participant Database

    Client->>AbsensiController: GET /api/absensi?page=1&limit=10&filter=...
    AbsensiController->>AbsensiService: getAllAbsensi(queryParams)
    
    AbsensiService->>AbsensiService: parseQueryParams(page, limit, filter)
    
    AbsensiService->>Prisma: absensi.findMany({where, skip, take, include})
    Prisma->>Database: SELECT * FROM absensi WHERE ... LIMIT ? OFFSET ?
    Database-->>Prisma: Absensi array
    Prisma-->>AbsensiService: AbsensiList
    
    AbsensiService->>Prisma: absensi.count({where})
    Prisma->>Database: SELECT COUNT(*) FROM absensi WHERE ...
    Database-->>Prisma: Total count
    Prisma-->>AbsensiService: Total
    
    AbsensiService->>AbsensiService: calculatePagination(page, limit, total)
    AbsensiService-->>AbsensiController: {data: AbsensiList, pagination}
    AbsensiController-->>Client: 200 OK {success, data, pagination}
```

## 📊 Sequence Diagram Summary

### Total Sequence Diagrams: 9

1. **Login Process**: Authentication flow dengan JWT
2. **Absensi Masuk**: Complete absensi creation dengan validasi
3. **Create Pengajuan Izin**: Izin request creation
4. **Approve Pengajuan Izin**: Approval workflow
5. **Get Dashboard Statistics**: Role-based statistics retrieval
6. **Create Peserta Magang**: Admin creation dengan user account linking
7. **Create Logbook**: Logbook entry creation
8. **Submit Logbook**: Logbook submission untuk review
9. **Get All Absensi**: Pagination dan filtering

### Key Components

- **Controllers**: Handle HTTP requests/responses
- **Services**: Business logic layer
- **Middleware**: Authentication & authorization
- **Prisma**: ORM layer
- **Database**: PostgreSQL database
- **External Services**: JWT, FileService, NotificationService, LocationService

### Common Patterns

1. **Authentication First**: Semua protected endpoints check auth
2. **Role-Based Access**: Admin-only endpoints check role
3. **Validation**: Input validation sebelum database operations
4. **Error Handling**: Proper error responses
5. **Database Transactions**: Atomic operations
6. **Pagination**: For list endpoints

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0


