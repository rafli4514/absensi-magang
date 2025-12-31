# UML Sequence Diagrams
## Sistem Absensi Magang - Mobile & Web

## 📊 Overview
Dokumen ini menjelaskan sequence diagrams untuk proses-proses penting dalam sistem absensi magang, baik untuk aplikasi mobile maupun web.

## 📱 Mobile Application Sequences

### 1. Login Process (Mobile)

```mermaid
sequenceDiagram
    participant User
    participant MobileApp
    participant AuthProvider
    participant AuthService
    participant API
    participant Database
    
    User->>MobileApp: Input username & password
    MobileApp->>AuthProvider: login(username, password)
    AuthProvider->>AuthService: login(username, password)
    AuthService->>API: POST /auth/login-peserta
    API->>Database: Query PesertaMagang by username
    Database-->>API: PesertaMagang data
    API->>API: Validate password (bcrypt)
    API->>API: Generate JWT token
    API-->>AuthService: {token, user, success}
    AuthService-->>AuthProvider: ApiResponse
    AuthProvider->>AuthProvider: Save token to Storage
    AuthProvider->>AuthProvider: Save user data to Storage
    AuthProvider-->>MobileApp: Success
    MobileApp->>MobileApp: Navigate to Home Screen
    MobileApp-->>User: Show Home Screen
```

### 2. Clock In Process (Mobile)

```mermaid
sequenceDiagram
    participant User
    participant QRScanScreen
    participant AttendanceProvider
    participant LocationService
    participant SettingsService
    participant AttendanceService
    participant API
    participant Database
    participant Settings
    
    User->>QRScanScreen: Scan QR Code
    QRScanScreen->>QRScanScreen: Parse QR Data
    QRScanScreen->>AttendanceProvider: clockIn(qrData)
    AttendanceProvider->>LocationService: getCurrentLocation()
    LocationService->>LocationService: Request GPS permission
    LocationService->>LocationService: Get GPS coordinates
    LocationService-->>AttendanceProvider: LocationModel
    
    AttendanceProvider->>SettingsService: getSettings()
    SettingsService->>Settings: Check cache
    alt Cache valid
        Settings-->>SettingsService: Cached settings
    else Cache invalid/empty
        SettingsService->>API: GET /settings
        API->>Database: Query Settings
        Database-->>API: Settings data
        API-->>SettingsService: Settings
        SettingsService->>Settings: Update cache
    end
    SettingsService-->>AttendanceProvider: SettingsModel
    
    AttendanceProvider->>AttendanceProvider: Validate location (within radius)
    AttendanceProvider->>AttendanceProvider: Validate time (work hours)
    AttendanceProvider->>AttendanceProvider: Validate work day
    
    alt Validation success
        AttendanceProvider->>AttendanceService: createAbsensi(data)
        AttendanceService->>API: POST /absensi
        API->>Database: Check existing attendance today
        Database-->>API: Existing record (if any)
        API->>API: Validate business rules
        API->>Database: Insert Absensi record
        Database-->>API: Success
        API-->>AttendanceService: {success, data}
        AttendanceService-->>AttendanceProvider: ApiResponse
        AttendanceProvider->>AttendanceProvider: Update local state
        AttendanceProvider-->>QRScanScreen: Success
        QRScanScreen->>QRScanScreen: Navigate to Home
        QRScanScreen-->>User: Show success message
    else Validation failed
        AttendanceProvider-->>QRScanScreen: Error
        QRScanScreen-->>User: Show error message
    end
```

### 3. Clock Out Process (Mobile)

```mermaid
sequenceDiagram
    participant User
    participant HomeScreen
    participant AttendanceProvider
    participant LocationService
    participant AttendanceService
    participant API
    participant Database
    
    User->>HomeScreen: Tap "Clock Out" button
    HomeScreen->>AttendanceProvider: clockOut()
    AttendanceProvider->>LocationService: getCurrentLocation()
    LocationService->>LocationService: Get GPS coordinates
    LocationService-->>AttendanceProvider: LocationModel
    
    AttendanceProvider->>AttendanceService: createAbsensi({tipe: KELUAR, ...})
    AttendanceService->>API: POST /absensi
    API->>Database: Query today's clock-in
    Database-->>API: Clock-in record
    API->>API: Validate business rules
    API->>Database: Insert clock-out record
    Database-->>API: Success
    API-->>AttendanceService: {success, data}
    AttendanceService-->>AttendanceProvider: ApiResponse
    AttendanceProvider->>AttendanceProvider: Update local state (_isClockedOut = true)
    AttendanceProvider-->>HomeScreen: Success
    HomeScreen->>HomeScreen: Refresh UI
    HomeScreen-->>User: Show updated status
```

### 4. View Today's Attendance (Mobile)

```mermaid
sequenceDiagram
    participant User
    participant HomeScreen
    participant AttendanceProvider
    participant AttendanceService
    participant API
    participant Database
    
    User->>HomeScreen: Open Home Screen
    HomeScreen->>AttendanceProvider: refreshTodayAttendance()
    AttendanceProvider->>AttendanceService: getAbsensiByPeserta(pesertaId)
    AttendanceService->>API: GET /absensi/peserta/:id
    API->>Database: Query Absensi by pesertaId
    Database-->>API: All attendance records
    API->>API: Filter today's records
    API-->>AttendanceService: Today's attendance
    AttendanceService-->>AttendanceProvider: ApiResponse
    AttendanceProvider->>AttendanceProvider: Process today's attendance
    AttendanceProvider->>AttendanceProvider: Set _isClockedIn, _clockInTime, etc.
    AttendanceProvider-->>HomeScreen: Updated state
    HomeScreen->>HomeScreen: Render attendance status
    HomeScreen-->>User: Display status
```

## 🌐 Web Application Sequences

### 5. Admin Login Process (Web)

```mermaid
sequenceDiagram
    participant Admin
    participant LoginPage
    participant AuthService
    participant API
    participant Database
    
    Admin->>LoginPage: Input username & password
    LoginPage->>AuthService: login(username, password)
    AuthService->>API: POST /auth/login
    API->>Database: Query User by username
    Database-->>API: User data
    API->>API: Validate password (bcrypt)
    API->>API: Generate JWT token
    API-->>AuthService: {token, user, success}
    AuthService->>AuthService: Save token to localStorage
    AuthService->>AuthService: Save user data to localStorage
    AuthService-->>LoginPage: Success
    LoginPage->>LoginPage: Navigate to Dashboard
    LoginPage-->>Admin: Show Dashboard
```

### 6. Create User (Web)

```mermaid
sequenceDiagram
    participant Admin
    participant UserManagementPage
    participant UserService
    participant API
    participant Database
    
    Admin->>UserManagementPage: Fill form & submit
    UserManagementPage->>UserManagementPage: Validate form
    UserManagementPage->>UserService: createUser(userData)
    UserService->>API: POST /users (with token)
    API->>API: Validate token & role (must be ADMIN)
    API->>Database: Check username uniqueness
    Database-->>API: Username available
    API->>API: Hash password (bcrypt)
    API->>Database: Insert User record
    Database-->>API: New user created
    API-->>UserService: {success, user}
    UserService-->>UserManagementPage: Success response
    UserManagementPage->>UserManagementPage: Refresh user list
    UserManagementPage->>UserService: getAllUsers()
    UserService->>API: GET /users
    API->>Database: Query all users
    Database-->>API: User list
    API-->>UserService: User list
    UserService-->>UserManagementPage: Updated list
    UserManagementPage-->>Admin: Show updated table
```

### 7. Generate Report (Web)

```mermaid
sequenceDiagram
    participant Admin
    participant LaporanPage
    participant AbsensiService
    participant API
    participant Database
    
    Admin->>LaporanPage: Select date range & format
    Admin->>LaporanPage: Click "Generate Report"
    LaporanPage->>AbsensiService: getAllAbsensi(filters)
    AbsensiService->>API: GET /absensi?startDate=X&endDate=Y
    API->>Database: Query Absensi with date filter
    Database-->>API: Filtered attendance records
    API->>Database: Join with PesertaMagang
    Database-->>API: Attendance with participant data
    API->>API: Aggregate statistics
    API-->>AbsensiService: Report data
    AbsensiService-->>LaporanPage: Report data
    
    alt Format: CSV
        LaporanPage->>LaporanPage: Generate CSV file
    else Format: Excel
        LaporanPage->>LaporanPage: Generate Excel file
    else Format: PDF
        LaporanPage->>LaporanPage: Generate PDF (print dialog)
    end
    
    LaporanPage-->>Admin: Download file
```

### 8. Approve Pengajuan Izin (Web)

```mermaid
sequenceDiagram
    participant Admin
    participant PengajuanIzinPage
    participant PengajuanIzinService
    participant API
    participant Database
    
    Admin->>PengajuanIzinPage: Click "Approve" button
    PengajuanIzinPage->>PengajuanIzinService: approveIzin(izinId, catatan)
    PengajuanIzinService->>API: PUT /pengajuan-izin/:id/approve
    API->>API: Validate token & role
    API->>Database: Query PengajuanIzin by id
    Database-->>API: Izin record
    API->>API: Update status to DISETUJUI
    API->>API: Set disetujuiOleh (current user id)
    API->>API: Set disetujuiPada (current timestamp)
    API->>Database: Update PengajuanIzin record
    Database-->>API: Success
    API-->>PengajuanIzinService: {success, updatedIzin}
    PengajuanIzinService-->>PengajuanIzinPage: Success
    PengajuanIzinPage->>PengajuanIzinPage: Refresh izin list
    PengajuanIzinPage->>PengajuanIzinService: getAllIzin()
    PengajuanIzinService->>API: GET /pengajuan-izin
    API->>Database: Query all PengajuanIzin
    Database-->>API: Izin list
    API-->>PengajuanIzinService: Izin list
    PengajuanIzinService-->>PengajuanIzinPage: Updated list
    PengajuanIzinPage-->>Admin: Show updated status
```

## 🔄 Cross-Platform Sequences

### 9. Update Settings (Web) → Effect on Mobile

```mermaid
sequenceDiagram
    participant Admin
    participant SettingsPage
    participant SettingsService
    participant API
    participant Database
    participant MobileApp
    participant SettingsProvider
    
    Admin->>SettingsPage: Update work hours
    SettingsPage->>SettingsService: updateSetting(key, value)
    SettingsService->>API: PUT /settings/:id
    API->>Database: Update Settings record
    Database-->>API: Success
    API-->>SettingsService: Success
    SettingsService-->>SettingsPage: Success
    SettingsPage-->>Admin: Show success message
    
    Note over MobileApp,SettingsProvider: Mobile app akan menggunakan<br/>settings baru saat clock in berikutnya
    
    MobileApp->>SettingsProvider: fetchSettings()
    SettingsProvider->>API: GET /settings
    API->>Database: Query Settings
    Database-->>API: Updated settings
    API-->>SettingsProvider: Updated settings
    SettingsProvider->>SettingsProvider: Clear cache
    SettingsProvider->>SettingsProvider: Update cache with new settings
```

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0  
**Platform**: Mobile (Flutter) + Web (React) + Backend (Node.js/Express)

