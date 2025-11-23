# Data Flow Diagram (DFD)
## Sistem Absensi Magang

## 📊 Overview
Dokumen ini menjelaskan Data Flow Diagram (DFD) untuk sistem absensi magang, menunjukkan alur data dari input hingga output.

## 🔄 DFD Levels

### DFD Level 0 (Context Diagram)

```mermaid
flowchart TD
    Admin[Admin] -->|User Data, Settings| System[Sistem Absensi Magang]
    PesertaMagang[Peserta Magang] -->|Absensi Data, Pengajuan Izin| System
    Pembimbing[Pembimbing Magang] -->|Query Requests| System
    
    System -->|User Management, Reports| Admin
    System -->|Absensi Confirmation, Status| PesertaMagang
    System -->|Laporan, Statistics| Pembimbing
    
    System <-->|Read/Write| Database[(Database)]
    System -->|Notifications| External[External Services]
```

**Deskripsi**:
- **External Entities**: Admin, Peserta Magang, Pembimbing Magang, Database, External Services
- **System**: Sistem Absensi Magang (single process)
- **Data Flows**: User data, Absensi data, Reports, Settings, dll

### DFD Level 1 (Top Level)

```mermaid
flowchart TD
    Admin[Admin] -->|Login Request| Auth[1.0 Authentication]
    PesertaMagang[Peserta Magang] -->|Login Request| Auth
    Pembimbing[Pembimbing Magang] -->|Login Request| Auth
    
    Auth -->|User Data| D1[(D1: Users)]
    Auth -->|Token| Admin
    Auth -->|Token| PesertaMagang
    Auth -->|Token| Pembimbing
    
    Admin -->|User CRUD| UserMgmt[2.0 User Management]
    UserMgmt -->|User Data| D1
    UserMgmt -->|User Data| Admin
    
    Admin -->|Peserta CRUD| PesertaMgmt[3.0 Peserta Magang Management]
    PesertaMgmt -->|Peserta Data| D2[(D2: Peserta Magang)]
    PesertaMgmt -->|Peserta Data| Admin
    
    PesertaMagang -->|Absensi Data| AbsensiProc[4.0 Absensi Processing]
    AbsensiProc -->|Absensi Data| D3[(D3: Absensi)]
    AbsensiProc -->|Validation Rules| D4[(D4: Settings)]
    AbsensiProc -->|Confirmation| PesertaMagang
    
    PesertaMagang -->|Izin Request| IzinProc[5.0 Pengajuan Izin Processing]
    IzinProc -->|Izin Data| D5[(D5: Pengajuan Izin)]
    IzinProc -->|Status| PesertaMagang
    
    Admin -->|Approval/Rejection| IzinProc
    IzinProc -->|Updated Status| PesertaMagang
    
    PesertaMagang -->|Logbook Data| LogbookProc[8.0 Logbook Processing]
    LogbookProc -->|Logbook Data| D6[(D6: Logbook)]
    LogbookProc -->|Status| PesertaMagang
    
    Admin -->|Approval/Rejection| LogbookProc
    Pembimbing -->|Approval/Rejection| LogbookProc
    LogbookProc -->|Updated Status| PesertaMagang
    
    Admin -->|Query| Dashboard[6.0 Dashboard & Reporting]
    PesertaMagang -->|Query| Dashboard
    Pembimbing -->|Query| Dashboard
    
    Dashboard -->|Statistics| D3
    Dashboard -->|Statistics| D2
    Dashboard -->|Statistics| D5
    Dashboard -->|Statistics| D6
    Dashboard -->|Reports| Admin
    Dashboard -->|Reports| PesertaMagang
    Dashboard -->|Reports| Pembimbing
    
    Admin -->|Settings CRUD| SettingsMgmt[7.0 Settings Management]
    SettingsMgmt -->|Settings Data| D4
    SettingsMgmt -->|Settings Data| Admin
```

**Data Stores**:
- **D1**: Users
- **D2**: Peserta Magang
- **D3**: Absensi
- **D4**: Settings
- **D5**: Pengajuan Izin
- **D6**: Logbook

### DFD Level 2: Authentication Process (1.0)

```mermaid
flowchart TD
    User[User] -->|Username, Password| Validate[1.1 Validate Credentials]
    Validate -->|Query| D1[(D1: Users)]
    D1 -->|User Data| Validate
    
    Validate -->|Valid| GenerateToken[1.2 Generate JWT Token]
    Validate -->|Invalid| Error[1.3 Return Error]
    
    GenerateToken -->|Token, User Data| User
    Error -->|Error Message| User
```

### DFD Level 2: Absensi Processing (4.0)

```mermaid
flowchart TD
    PesertaMagang[Peserta Magang] -->|QR Code, Location, Timestamp| ValidateInput[4.1 Validate Input]
    
    ValidateInput -->|Query| D2[(D2: Peserta Magang)]
    D2 -->|Peserta Data| ValidateInput
    
    ValidateInput -->|Valid| LoadSettings[4.2 Load Settings]
    LoadSettings -->|Query| D4[(D4: Settings)]
    D4 -->|Settings Data| LoadSettings
    
    LoadSettings -->|Settings| ValidateLocation[4.3 Validate Location]
    ValidateLocation -->|GPS Data| ValidateLocation
    
    ValidateLocation -->|Valid| ValidateTime[4.4 Validate Time]
    ValidateTime -->|Work Day/Hours| ValidateTime
    
    ValidateTime -->|Valid| CheckLate[4.5 Check Late Status]
    CheckLate -->|Timestamp| CheckLate
    
    CheckLate -->|Status| CreateRecord[4.6 Create Absensi Record]
    CreateRecord -->|Absensi Data| D3[(D3: Absensi)]
    D3 -->|Confirmation| PesertaMagang
    
    ValidateInput -->|Invalid| Error1[4.7 Return Error]
    ValidateLocation -->|Invalid| Error1
    ValidateTime -->|Invalid| Error1
    Error1 -->|Error Message| PesertaMagang
```

### DFD Level 2: Pengajuan Izin Processing (5.0)

```mermaid
flowchart TD
    PesertaMagang[Peserta Magang] -->|Izin Data, Document| ValidateIzin[5.1 Validate Izin Data]
    
    ValidateIzin -->|Query| D2[(D2: Peserta Magang)]
    D2 -->|Peserta Data| ValidateIzin
    
    ValidateIzin -->|Valid| UploadDoc[5.2 Upload Document]
    UploadDoc -->|File| External[External Storage]
    External -->|Document URL| UploadDoc
    
    UploadDoc -->|Document URL| CreateIzin[5.3 Create Izin Record]
    CreateIzin -->|Izin Data| D5[(D5: Pengajuan Izin)]
    D5 -->|Status: PENDING| PesertaMagang
    
    Admin[Admin] -->|Approval/Rejection| ReviewIzin[5.4 Review Izin]
    ReviewIzin -->|Query| D5
    D5 -->|Izin Data| ReviewIzin
    
    ReviewIzin -->|Decision| UpdateStatus[5.5 Update Status]
    UpdateStatus -->|Updated Data| D5
    D5 -->|Status Update| PesertaMagang
    
    ValidateIzin -->|Invalid| Error2[5.6 Return Error]
    Error2 -->|Error Message| PesertaMagang
```

### DFD Level 2: Logbook Processing (8.0)

```mermaid
flowchart TD
    PesertaMagang[Peserta Magang] -->|Logbook Data| ValidateLogbook[8.1 Validate Logbook Data]
    
    ValidateLogbook -->|Query| D2[(D2: Peserta Magang)]
    D2 -->|Peserta Data| ValidateLogbook
    
    ValidateLogbook -->|Valid| CreateLogbook[8.2 Create Logbook Record]
    CreateLogbook -->|Logbook Data| D6[(D6: Logbook)]
    D6 -->|Status: DRAFT| PesertaMagang
    
    PesertaMagang -->|Submit Request| SubmitLogbook[8.3 Submit Logbook]
    SubmitLogbook -->|Query| D6
    D6 -->|Logbook Data| SubmitLogbook
    SubmitLogbook -->|Update Status| D6
    D6 -->|Status: SUBMITTED| PesertaMagang
    
    Admin[Admin] -->|Review Request| ReviewLogbook[8.4 Review Logbook]
    Pembimbing[Pembimbing] -->|Review Request| ReviewLogbook
    ReviewLogbook -->|Query| D6
    D6 -->|Logbook Data| ReviewLogbook
    
    ReviewLogbook -->|Decision| UpdateStatus[8.5 Update Status]
    UpdateStatus -->|Updated Data| D6
    D6 -->|Status Update| PesertaMagang
    
    ValidateLogbook -->|Invalid| Error3[8.6 Return Error]
    Error3 -->|Error Message| PesertaMagang
```

### DFD Level 2: Dashboard & Reporting (6.0)

```mermaid
flowchart TD
    User[User] -->|Query Request| CheckRole[6.1 Check User Role]
    
    CheckRole -->|Admin| AdminStats[6.2 Get Admin Statistics]
    CheckRole -->|Peserta| PesertaStats[6.3 Get Peserta Statistics]
    CheckRole -->|Pembimbing| PembimbingStats[6.4 Get Pembimbing Statistics]
    
    AdminStats -->|Query| D2[(D2: Peserta Magang)]
    AdminStats -->|Query| D3[(D3: Absensi)]
    AdminStats -->|Query| D5[(D5: Pengajuan Izin)]
    AdminStats -->|Query| D6[(D6: Logbook)]
    
    D2 -->|Data| CalculateAdmin[6.5 Calculate Admin Stats]
    D3 -->|Data| CalculateAdmin
    D5 -->|Data| CalculateAdmin
    D6 -->|Data| CalculateAdmin
    
    PesertaStats -->|Query| D3
    PesertaStats -->|Query| D5
    PesertaStats -->|Query| D6
    D3 -->|Data| CalculatePeserta[6.6 Calculate Peserta Stats]
    D5 -->|Data| CalculatePeserta
    D6 -->|Data| CalculatePeserta
    
    PembimbingStats -->|Query| D2
    PembimbingStats -->|Query| D3
    D2 -->|Data| CalculatePembimbing[6.7 Calculate Pembimbing Stats]
    D3 -->|Data| CalculatePembimbing
    
    CalculateAdmin -->|Statistics| FormatReport[6.8 Format Report]
    CalculatePeserta -->|Statistics| FormatReport
    CalculatePembimbing -->|Statistics| FormatReport
    
    FormatReport -->|Dashboard Data| User
```

## 📊 Data Dictionary

### Data Stores

#### D1: Users
- **Description**: Menyimpan data pengguna sistem
- **Contents**: id, username, password, role, isActive, avatar, timestamps
- **Volume**: ~100-1000 records
- **Access**: Read/Write by Authentication & User Management

#### D2: Peserta Magang
- **Description**: Menyimpan data peserta magang
- **Contents**: id, nama, username, divisi, instansi, nomorHp, tanggal, status, timestamps
- **Volume**: ~50-500 records
- **Access**: Read/Write by Peserta Management & Absensi Processing

#### D3: Absensi
- **Description**: Menyimpan data absensi
- **Contents**: id, pesertaMagangId, tipe, timestamp, lokasi, selfieUrl, qrCodeData, status, timestamps
- **Volume**: ~1000-10000 records/month
- **Access**: Read/Write by Absensi Processing, Read by Dashboard

#### D4: Settings
- **Description**: Menyimpan konfigurasi sistem
- **Contents**: id, key, value (JSON), category, timestamps
- **Volume**: ~20-50 records
- **Access**: Read by Absensi Processing, Read/Write by Settings Management

#### D5: Pengajuan Izin
- **Description**: Menyimpan data pengajuan izin
- **Contents**: id, pesertaMagangId, tipe, tanggal, alasan, status, dokumen, approval info, timestamps
- **Volume**: ~100-1000 records/month
- **Access**: Read/Write by Izin Processing, Read by Dashboard

#### D6: Logbook
- **Description**: Menyimpan data logbook peserta magang
- **Contents**: id, pesertaMagangId, tanggal, kegiatan, deskripsi, durasi, status, catatan pembimbing, approval info, timestamps
- **Volume**: ~500-5000 records/month
- **Access**: Read/Write by Logbook Processing, Read by Dashboard

### Data Flows

#### User Data
- **From**: Admin, User Management
- **To**: Database (D1)
- **Contents**: User information (username, password, role, etc.)
- **Frequency**: Low (on user creation/update)

#### Absensi Data
- **From**: Peserta Magang, Absensi Processing
- **To**: Database (D3)
- **Contents**: Absensi information (tipe, timestamp, lokasi, status, etc.)
- **Frequency**: High (multiple times per day per user)

#### Settings Data
- **From**: Admin, Settings Management
- **To**: Database (D4)
- **Contents**: System configuration (work hours, location, security, etc.)
- **Frequency**: Low (on settings update)

#### Statistics Data
- **From**: Database (D2, D3, D5)
- **To**: Dashboard, Users
- **Contents**: Aggregated statistics (counts, percentages, trends)
- **Frequency**: Medium (on dashboard load)

## 🔍 Process Descriptions

### 1.0 Authentication
- **Input**: Username, Password
- **Output**: JWT Token, User Data / Error Message
- **Process**: Validate credentials, generate token
- **Data Stores**: D1 (Read)

### 2.0 User Management
- **Input**: User CRUD operations
- **Output**: User Data / Confirmation
- **Process**: Create, Read, Update, Delete users
- **Data Stores**: D1 (Read/Write)

### 3.0 Peserta Magang Management
- **Input**: Peserta CRUD operations
- **Output**: Peserta Data / Confirmation
- **Process**: Create, Read, Update, Delete peserta magang
- **Data Stores**: D2 (Read/Write)

### 4.0 Absensi Processing
- **Input**: QR Code, Location, Timestamp, Selfie
- **Output**: Absensi Confirmation / Error Message
- **Process**: Validate input, location, time, create record
- **Data Stores**: D2 (Read), D3 (Write), D4 (Read)

### 5.0 Pengajuan Izin Processing
- **Input**: Izin Data, Document
- **Output**: Izin Status / Error Message
- **Process**: Validate, create request, handle approval/rejection
- **Data Stores**: D2 (Read), D5 (Read/Write)

### 6.0 Dashboard & Reporting
- **Input**: Query Parameters, User Role
- **Output**: Statistics, Reports
- **Process**: Aggregate data, calculate statistics, format reports
- **Data Stores**: D2 (Read), D3 (Read), D5 (Read), D6 (Read)


### 7.0 Settings Management
- **Input**: Settings CRUD operations
- **Output**: Settings Data / Confirmation
- **Process**: Create, Read, Update settings
- **Data Stores**: D4 (Read/Write)

### 8.0 Logbook Processing
- **Input**: Logbook Data
- **Output**: Logbook Status / Error Message
- **Process**: Validate, create entry, handle submit, approval/rejection
- **Data Stores**: D2 (Read), D6 (Read/Write)

## 📈 Data Flow Summary

### Input Flows
- **User Input**: Login credentials, CRUD operations, Absensi data, Izin requests, Logbook data
- **System Input**: GPS location, Timestamp, QR code data

### Output Flows
- **User Output**: Tokens, Confirmations, Statistics, Reports, Error messages
- **System Output**: Database records, Notifications

### Internal Flows
- **Validation**: Input → Validation → Database
- **Processing**: Input → Business Logic → Database
- **Reporting**: Database → Aggregation → Statistics → Reports

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0


