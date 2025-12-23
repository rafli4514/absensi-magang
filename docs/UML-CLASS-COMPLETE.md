# UML Class Diagram - Complete
## Sistem Absensi Magang - Mobile & Web

## 📊 Overview
Dokumen ini menjelaskan struktur class dan model lengkap dalam sistem absensi magang, termasuk backend models, mobile models (Flutter), dan web components (React).

## 🏗️ Backend Class Structure

### Database Models (Prisma)

```mermaid
classDiagram
    class User {
        +String id
        +String username
        +String password
        +Role role
        +Boolean isActive
        +String? avatar
        +DateTime createdAt
        +DateTime updatedAt
        +PesertaMagang? pesertaMagang
    }
    
    class PesertaMagang {
        +String id
        +String nama
        +String username
        +String? id_peserta_magang
        +String divisi
        +String instansi
        +String? id_instansi
        +String nomorHp
        +String tanggalMulai
        +String tanggalSelesai
        +StatusPeserta status
        +String? avatar
        +String? userId
        +DateTime createdAt
        +DateTime updatedAt
        +User? user
        +Absensi[] absensi
        +PengajuanIzin[] pengajuanIzin
        +Logbook[] logbook
    }
    
    class Absensi {
        +String id
        +String pesertaMagangId
        +TipeAbsensi tipe
        +String timestamp
        +Json? lokasi
        +String? selfieUrl
        +String? qrCodeData
        +StatusAbsensi status
        +String? catatan
        +String? ipAddress
        +String? device
        +DateTime createdAt
        +DateTime updatedAt
        +PesertaMagang pesertaMagang
    }
    
    class PengajuanIzin {
        +String id
        +String pesertaMagangId
        +TipeIzin tipe
        +String tanggalMulai
        +String tanggalSelesai
        +String alasan
        +StatusPengajuan status
        +String? dokumenPendukung
        +String? disetujuiOleh
        +String? disetujuiPada
        +String? catatan
        +DateTime createdAt
        +DateTime updatedAt
        +PesertaMagang pesertaMagang
    }
    
    class Logbook {
        +String id
        +String pesertaMagangId
        +String tanggal
        +String kegiatan
        +String deskripsi
        +String? durasi
        +ActivityType? type
        +ActivityStatus? status
        +DateTime createdAt
        +DateTime updatedAt
        +PesertaMagang pesertaMagang
    }
    
    class Settings {
        +String id
        +String key
        +Json value
        +String category
        +DateTime createdAt
        +DateTime updatedAt
    }
    
    User "1" -- "0..1" PesertaMagang : has
    PesertaMagang "1" -- "*" Absensi : has
    PesertaMagang "1" -- "*" PengajuanIzin : has
    PesertaMagang "1" -- "*" Logbook : has
```

### Backend Controllers

```mermaid
classDiagram
    class AuthController {
        +login(req, res)
        +loginPeserta(req, res)
        +register(req, res)
        +getProfile(req, res)
        +updateProfile(req, res)
        +uploadAvatar(req, res)
        +deleteAvatar(req, res)
    }
    
    class AbsensiController {
        +createAbsensi(req, res)
        +getAllAbsensi(req, res)
        +getAbsensiById(req, res)
        +updateAbsensi(req, res)
        +deleteAbsensi(req, res)
        +getAbsensiByPeserta(req, res)
        -evaluateAttendanceRules(settings, timestamp, tipe)
    }
    
    class PesertaMagangController {
        +getAllPeserta(req, res)
        +getPesertaById(req, res)
        +createPeserta(req, res)
        +updatePeserta(req, res)
        +deletePeserta(req, res)
    }
    
    class UserController {
        +getAllUsers(req, res)
        +getUserById(req, res)
        +updateUser(req, res)
        +deleteUser(req, res)
        +activateUser(req, res)
        +deactivateUser(req, res)
    }
    
    class SettingsController {
        +getAllSettings(req, res)
        +getSettingByKey(req, res)
        +createSetting(req, res)
        +updateSetting(req, res)
        +deleteSetting(req, res)
    }
    
    class DashboardController {
        +getStatistics(req, res)
        +getRecentAbsensi(req, res)
        +getPendingIzin(req, res)
    }
    
    class PengajuanIzinController {
        +getAllIzin(req, res)
        +getIzinById(req, res)
        +createIzin(req, res)
        +updateIzin(req, res)
        +approveIzin(req, res)
        +rejectIzin(req, res)
        +deleteIzin(req, res)
    }
    
    class LogbookController {
        +getAllLogbook(req, res)
        +getLogbookById(req, res)
        +createLogbook(req, res)
        +updateLogbook(req, res)
        +deleteLogbook(req, res)
    }
    
    AuthController --> User
    AbsensiController --> Absensi
    AbsensiController --> Settings
    PesertaMagangController --> PesertaMagang
    UserController --> User
    SettingsController --> Settings
    DashboardController --> Absensi
    DashboardController --> PesertaMagang
    PengajuanIzinController --> PengajuanIzin
    LogbookController --> Logbook
```

## 📱 Mobile Application Classes (Flutter)

### Models

```mermaid
classDiagram
    class UserModel {
        +String id
        +String username
        +String? nama
        +Role role
        +String? avatar
        +PesertaMagangModel? pesertaMagang
        +fromJson(Map json)
        +toJson() Map
    }
    
    class PesertaMagangModel {
        +String id
        +String nama
        +String username
        +String divisi
        +String instansi
        +String nomorHp
        +StatusPeserta status
        +String? avatar
        +fromJson(Map json)
        +toJson() Map
    }
    
    class AttendanceModel {
        +String id
        +String pesertaMagangId
        +TipeAbsensi tipe
        +DateTime timestamp
        +LocationModel? lokasi
        +String? selfieUrl
        +StatusAbsensi status
        +String? catatan
        +fromJson(Map json)
        +toJson() Map
    }
    
    class LocationModel {
        +double latitude
        +double longitude
        +String? alamat
        +fromJson(Map json)
        +toJson() Map
    }
    
    class LogbookModel {
        +String id
        +String pesertaMagangId
        +DateTime tanggal
        +String kegiatan
        +String deskripsi
        +String? durasi
        +ActivityType? type
        +ActivityStatus? status
        +fromJson(Map json)
        +toJson() Map
    }
    
    class SettingsModel {
        +Map~String, dynamic~ settings
        +fromJson(Map json)
        +toJson() Map
        +getWorkDays() List~String~
        +getWorkStartTime() String
        +getWorkEndTime() String
    }
    
    AttendanceModel --> LocationModel
```

### Providers (State Management)

```mermaid
classDiagram
    class AuthProvider {
        -String? _token
        -UserModel? _user
        -bool _isLoading
        +Future~bool~ login(String username, String password)
        +Future~void~ logout()
        +bool get isAuthenticated
        +UserModel? get user
        +String? get token
    }
    
    class AttendanceProvider {
        -bool _isClockedIn
        -bool _isClockedOut
        -DateTime? _clockInTime
        -DateTime? _clockOutTime
        -String? _currentPesertaMagangId
        +Future~void~ clockIn(String qrCode, LocationModel location)
        +Future~void~ clockOut(LocationModel location)
        +Future~void~ refreshTodayAttendance()
        +bool get canClockIn
        +bool get canClockOut
        +void resetAttendance()
    }
    
    class SettingsProvider {
        -SettingsModel? _settings
        -DateTime? _lastFetch
        +Future~void~ fetchSettings()
        +SettingsModel? get settings
    }
    
    AuthProvider --> UserModel
    AttendanceProvider --> AttendanceModel
    AttendanceProvider --> SettingsProvider
    SettingsProvider --> SettingsModel
```

### Services

```mermaid
classDiagram
    class ApiService {
        -String baseUrl
        -String? _token
        +Future~ApiResponse~ get(String endpoint)
        +Future~ApiResponse~ post(String endpoint, Map body)
        +Future~ApiResponse~ put(String endpoint, Map body)
        +Future~ApiResponse~ delete(String endpoint)
        -Map~String, String~ _getHeaders()
    }
    
    class AuthService {
        +Future~ApiResponse~ login(String username, String password)
        +Future~ApiResponse~ loginPeserta(String username, String password)
        +Future~ApiResponse~ getProfile()
        +Future~ApiResponse~ updateProfile(Map data)
    }
    
    class AttendanceService {
        +Future~ApiResponse~ createAbsensi(Map data)
        +Future~ApiResponse~ getAbsensiByPeserta(String pesertaId)
        +Future~ApiResponse~ getTodayAttendance(String pesertaId)
    }
    
    class LocationService {
        +Future~LocationModel~ getCurrentLocation()
        +Future~bool~ isWithinOfficeRadius(double lat, double lon)
        +Future~String~ getAddressFromCoordinates(double lat, double lon)
    }
    
    class SettingsService {
        -SettingsModel? _cachedSettings
        -DateTime? _cacheTime
        +Future~SettingsModel~ getSettings()
        +void clearCache()
    }
    
    ApiService --> ApiResponse
    AuthService --> ApiService
    AttendanceService --> ApiService
    LocationService --> LocationModel
    SettingsService --> ApiService
    SettingsService --> SettingsModel
```

## 🌐 Web Application Classes (React/TypeScript)

### Components

```mermaid
classDiagram
    class LoginPage {
        -string username
        -string password
        -bool isLoading
        +handleLogin()
        +render() JSX
    }
    
    class DashboardPage {
        -object statistics
        -array recentAbsensi
        -bool isLoading
        +useEffect()
        +fetchStatistics()
        +render() JSX
    }
    
    class UserManagementPage {
        -array users
        -object selectedUser
        -bool isModalOpen
        +handleCreate()
        +handleUpdate()
        +handleDelete()
        +render() JSX
    }
    
    class AbsensiPage {
        -array absensi
        -object filters
        -bool isLoading
        +handleFilter()
        +handleDelete()
        +render() JSX
    }
    
    class LaporanPage {
        -array reportData
        -object dateRange
        -string selectedFormat
        +handleExport()
        +handleExportDetail()
        +render() JSX
    }
    
    class SettingsPage {
        -object settings
        -bool isEditing
        +handleUpdate()
        +render() JSX
    }
    
    LoginPage --> AuthService
    DashboardPage --> DashboardService
    UserManagementPage --> UserService
    AbsensiPage --> AbsensiService
    LaporanPage --> AbsensiService
    SettingsPage --> SettingsService
```

### Services

```mermaid
classDiagram
    class ApiClient {
        -string baseURL
        -string? token
        +get(string endpoint) Promise
        +post(string endpoint, object data) Promise
        +put(string endpoint, object data) Promise
        +delete(string endpoint) Promise
        -getHeaders() object
    }
    
    class AuthService {
        +login(username, password) Promise
        +logout() void
        +getProfile() Promise
        +updateProfile(data) Promise
    }
    
    class UserService {
        +getAllUsers() Promise
        +getUserById(id) Promise
        +createUser(data) Promise
        +updateUser(id, data) Promise
        +deleteUser(id) Promise
    }
    
    class AbsensiService {
        +getAllAbsensi(filters) Promise
        +getAbsensiById(id) Promise
        +deleteAbsensi(id) Promise
        +getStatistics() Promise
    }
    
    class DashboardService {
        +getStatistics() Promise
        +getRecentAbsensi() Promise
        +getPendingIzin() Promise
    }
    
    class SettingsService {
        +getAllSettings() Promise
        +getSettingByKey(key) Promise
        +updateSetting(key, value) Promise
    }
    
    ApiClient --> ApiResponse
    AuthService --> ApiClient
    UserService --> ApiClient
    AbsensiService --> ApiClient
    DashboardService --> ApiClient
    SettingsService --> ApiClient
```

## 🔗 Relationships Between Layers

```mermaid
classDiagram
    class MobileApp {
        <<Flutter>>
    }
    
    class WebApp {
        <<React>>
    }
    
    class BackendAPI {
        <<Node.js/Express>>
    }
    
    class Database {
        <<PostgreSQL>>
    }
    
    MobileApp --> BackendAPI : HTTP/REST
    WebApp --> BackendAPI : HTTP/REST
    BackendAPI --> Database : Prisma ORM
    
    note for MobileApp "Mobile App menggunakan\nFlutter dengan Providers\nuntuk state management"
    note for WebApp "Web App menggunakan\nReact dengan Hooks\nuntuk state management"
    note for BackendAPI "Backend menggunakan\nExpress dengan Prisma\nuntuk database access"
```

## 📋 Enumerations

### Role (Backend & Mobile)
- `ADMIN`: Administrator sistem
- `PESERTA_MAGANG`: Peserta magang
- `PEMBIMBING_MAGANG`: Pembimbing magang

### StatusPeserta
- `AKTIF`: Peserta aktif
- `NONAKTIF`: Peserta nonaktif
- `SELESAI`: Peserta selesai magang

### TipeAbsensi
- `MASUK`: Clock-in
- `KELUAR`: Clock-out
- `IZIN`: Izin
- `SAKIT`: Sakit
- `CUTI`: Cuti

### StatusAbsensi
- `VALID`: Valid
- `INVALID`: Tidak valid
- `TERLAMBAT`: Terlambat

### TipeIzin
- `SAKIT`: Sakit
- `IZIN`: Izin
- `CUTI`: Cuti

### StatusPengajuan
- `PENDING`: Pending
- `DISETUJUI`: Disetujui
- `DITOLAK`: Ditolak

### ActivityType (Logbook)
- `MEETING`: Meeting
- `TRAINING`: Training
- `PRESENTATION`: Presentation
- `DEADLINE`: Deadline
- `OTHER`: Other

### ActivityStatus (Logbook)
- `COMPLETED`: Completed
- `IN_PROGRESS`: In Progress
- `PENDING`: Pending
- `CANCELLED`: Cancelled

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 2.0.0  
**Platform**: Mobile (Flutter) + Web (React) + Backend (Node.js/Express)

