# Data Flow Diagram (DFD) - Mobile Application
## Sistem Absensi Magang - Aplikasi Mobile (Flutter)

## 📊 Overview
Dokumen ini menjelaskan Data Flow Diagram (DFD) khusus untuk aplikasi mobile (Flutter), menunjukkan alur data dari input user hingga output dan interaksi dengan backend API.

## 🔄 DFD Levels

### DFD Level 0 (Context Diagram) - Mobile App

```mermaid
flowchart TD
    PesertaMagang[Peserta Magang] -->|Login, QR Scan, Location, Data Input| MobileApp[Aplikasi Mobile<br/>Flutter]
    MobileApp -->|JWT Token, Profile, Attendance Data| PesertaMagang
    
    MobileApp <-->|HTTP/HTTPS REST API| BackendAPI[Backend API<br/>Node.js/Express]
    BackendAPI <-->|Read/Write| Database[(PostgreSQL<br/>Database)]
    
    MobileDevice[Device Services<br/>GPS, Camera, Storage] -->|Location, Image| MobileApp
    MobileApp -->|Store Token, Cache| LocalStorage[Local Storage<br/>SharedPreferences]
```

**Deskripsi**:
- **External Entities**: Peserta Magang, Backend API, Database, Device Services, Local Storage
- **System**: Aplikasi Mobile Flutter
- **Data Flows**: Login credentials, QR code, GPS location, attendance data, API responses

### DFD Level 1 - Mobile Application Processes

```mermaid
flowchart TD
    User[Peserta Magang] -->|Username, Password| AuthProc[1.0 Authentication<br/>Process]
    AuthProc -->|Token| LocalStore[(Local Storage)]
    AuthProc -->|User Data| User
    
    LocalStore -->|Token| AuthProc
    
    User -->|QR Code, Location| ScanProc[2.0 QR Scan<br/>Process]
    ScanProc -->|Location Data| GPS[GPS Service]
    GPS -->|Coordinates| ScanProc
    ScanProc -->|Attendance Data| API[Backend API]
    API -->|Confirmation| ScanProc
    ScanProc -->|Status| User
    
    User -->|View Request| HomeProc[3.0 Home Screen<br/>Process]
    HomeProc -->|Token| LocalStore
    HomeProc -->|Fetch Request| API
    API -->|Attendance Status| HomeProc
    HomeProc -->|Display Status| User
    
    User -->|Clock Out Request| ClockOutProc[4.0 Clock Out<br/>Process]
    ClockOutProc -->|Token| LocalStore
    ClockOutProc -->|Location| GPS
    GPS -->|Coordinates| ClockOutProc
    ClockOutProc -->|Attendance Data| API
    API -->|Confirmation| ClockOutProc
    ClockOutProc -->|Status| User
    
    User -->|Logbook Data| LogbookProc[5.0 Logbook<br/>Process]
    LogbookProc -->|Token| LocalStore
    LogbookProc -->|Logbook Data| API
    API -->|Confirmation| LogbookProc
    LogbookProc -->|Status| User
    
    User -->|Izin Request| IzinProc[6.0 Pengajuan Izin<br/>Process]
    IzinProc -->|Token| LocalStore
    IzinProc -->|Document| FileService[File Service]
    FileService -->|File Data| IzinProc
    IzinProc -->|Izin Data| API
    API -->|Confirmation| IzinProc
    IzinProc -->|Status| User
    
    User -->|Profile Update| ProfileProc[7.0 Profile<br/>Management]
    ProfileProc -->|Token| LocalStore
    ProfileProc -->|Profile Data| API
    API -->|Profile Data| ProfileProc
    ProfileProc -->|Display| User
    
    User -->|Settings Request| SettingsProc[8.0 Settings<br/>Fetch]
    SettingsProc -->|Token| LocalStore
    SettingsProc -->|Request| API
    API -->|Settings Data| SettingsProc
    SettingsProc -->|Cache| CacheStore[(Settings Cache)]
    SettingsProc -->|Settings| User
```

### DFD Level 2: Authentication Process (1.0)

```mermaid
flowchart TD
    User[User] -->|Username, Password| ValidateInput[1.1 Validate Input]
    ValidateInput -->|Request| API[POST /auth/login-peserta]
    API -->|Response| ValidateInput
    
    ValidateInput -->|Success| SaveToken[1.2 Save Token<br/>& User Data]
    ValidateInput -->|Error| ErrorHandler[1.3 Error Handler]
    
    SaveToken -->|Token, User Data| LocalStore[(Local Storage)]
    LocalStore -->|Stored| User
    
    ErrorHandler -->|Error Message| User
```

### DFD Level 2: QR Scan & Clock In Process (2.0)

```mermaid
flowchart TD
    User[User] -->|Scan QR| QRScanner[2.1 QR Code<br/>Scanner]
    QRScanner -->|QR Data| ValidateQR[2.2 Validate QR<br/>Data]
    
    ValidateQR -->|Valid| GetLocation[2.3 Get GPS<br/>Location]
    ValidateQR -->|Invalid| Error1[2.8 Return Error]
    
    GetLocation -->|Request| GPSService[GPS Service]
    GPSService -->|Coordinates| CheckLocation[2.4 Check Location<br/>Within Radius]
    
    CheckLocation -->|Location Data| GetSettings[2.5 Get Settings<br/>Work Hours, etc.]
    GetSettings -->|Request| API1[GET /settings]
    API1 -->|Settings| CheckLocation
    
    CheckLocation -->|Within Range| ValidateTime[2.6 Validate Time<br/>& Work Day]
    CheckLocation -->|Out of Range| Error1
    
    ValidateTime -->|Valid| CreateAttendance[2.7 Create Attendance<br/>Record]
    ValidateTime -->|Invalid| Error1
    
    CreateAttendance -->|Attendance Data| API2[POST /absensi]
    API2 -->|Confirmation| CreateAttendance
    CreateAttendance -->|Success| User
    
    Error1 -->|Error Message| User
```

### DFD Level 2: Home Screen Process (3.0)

```mermaid
flowchart TD
    User[User] -->|View Request| LoadToken[3.1 Load Token<br/>from Storage]
    LoadToken -->|Token| LocalStore[(Local Storage)]
    LocalStore -->|Token| FetchToday[3.2 Fetch Today's<br/>Attendance]
    
    FetchToday -->|Request + Token| API[GET /absensi/peserta/:id]
    API -->|Attendance Data| ProcessData[3.3 Process<br/>Attendance Data]
    
    ProcessData -->|Today Status| CheckState[3.4 Check Clock In/Out<br/>State]
    CheckState -->|State| UpdateUI[3.5 Update UI<br/>Display]
    UpdateUI -->|Display| User
    
    ProcessData -->|Error| ErrorHandler[3.6 Error Handler]
    ErrorHandler -->|Error Message| User
```

### DFD Level 2: Clock Out Process (4.0)

```mermaid
flowchart TD
    User[User] -->|Clock Out Request| GetLocation[4.1 Get GPS<br/>Location]
    GetLocation -->|Request| GPSService[GPS Service]
    GPSService -->|Coordinates| PrepareData[4.2 Prepare<br/>Clock Out Data]
    
    PrepareData -->|Attendance Data| API[POST /absensi]
    API -->|Confirmation| ProcessResponse[4.3 Process<br/>Response]
    
    ProcessResponse -->|Success| UpdateState[4.4 Update Local<br/>State]
    ProcessResponse -->|Error| ErrorHandler[4.5 Error Handler]
    
    UpdateState -->|Updated Status| User
    ErrorHandler -->|Error Message| User
```

### DFD Level 2: Logbook Process (5.0)

```mermaid
flowchart TD
    User[User] -->|Logbook Form| ValidateForm[5.1 Validate<br/>Form Data]
    
    ValidateForm -->|Valid| GetToken[5.2 Get Token]
    GetToken -->|Token| LocalStore[(Local Storage)]
    GetToken -->|Token| CreateLogbook[5.3 Create Logbook<br/>Entry]
    
    ValidateForm -->|Invalid| Error1[5.6 Return Error]
    
    CreateLogbook -->|Logbook Data| API[POST /logbook]
    API -->|Confirmation| ProcessResponse[5.4 Process<br/>Response]
    
    ProcessResponse -->|Success| UpdateUI[5.5 Update UI]
    ProcessResponse -->|Error| Error1
    
    UpdateUI -->|Updated List| User
    Error1 -->|Error Message| User
```

### DFD Level 2: Pengajuan Izin Process (6.0)

```mermaid
flowchart TD
    User[User] -->|Izin Form + Document| ValidateForm[6.1 Validate<br/>Form Data]
    
    ValidateForm -->|Valid| UploadDoc[6.2 Upload<br/>Document]
    ValidateForm -->|Invalid| Error1[6.6 Return Error]
    
    UploadDoc -->|File| FileService[File Service]
    FileService -->|File Path| PrepareData[6.3 Prepare<br/>Izin Data]
    
    PrepareData -->|Izin Data| API[POST /pengajuan-izin]
    API -->|Confirmation| ProcessResponse[6.4 Process<br/>Response]
    
    ProcessResponse -->|Success| UpdateUI[6.5 Update UI]
    ProcessResponse -->|Error| Error1
    
    UpdateUI -->|Updated Status| User
    Error1 -->|Error Message| User
```

## 📊 Data Dictionary

### Data Stores

#### Local Storage
- **Description**: Local storage menggunakan SharedPreferences (Flutter)
- **Contents**: 
  - `auth_token`: JWT token
  - `user_data`: User profile data (JSON)
  - `theme_mode`: Theme preference
  - `onboard_seen`: Onboarding status
- **Volume**: ~10-50 KB
- **Access**: Read/Write by all processes

#### Settings Cache
- **Description**: Cache untuk settings dari backend
- **Contents**: Settings data (work hours, location, etc.)
- **Volume**: ~5-10 KB
- **Access**: Read by QR Scan & Clock Out processes, Write by Settings Fetch

### Data Flows

#### Authentication Data
- **From**: User → Authentication Process
- **To**: Backend API → Local Storage
- **Contents**: Username, Password → JWT Token, User Data
- **Frequency**: Once per login session

#### QR Scan Data
- **From**: QR Scanner → QR Scan Process
- **To**: Backend API
- **Contents**: QR code data, GPS coordinates, timestamp
- **Frequency**: Multiple times per day (max once per day for clock-in)

#### Attendance Data
- **From**: Backend API → Home Screen Process
- **To**: User Display
- **Contents**: Today's attendance status, clock-in/out times
- **Frequency**: On app open, after clock-in/out

#### Location Data
- **From**: GPS Service → QR Scan/Clock Out Processes
- **To**: Backend API
- **Contents**: Latitude, Longitude, Address
- **Frequency**: On every clock-in/out

## 🔍 Process Descriptions

### 1.0 Authentication Process
- **Input**: Username, Password
- **Output**: JWT Token, User Data / Error Message
- **Process**: Validate credentials dengan backend, save token locally
- **Data Stores**: Local Storage (Write)

### 2.0 QR Scan & Clock In Process
- **Input**: QR Code, GPS Location
- **Output**: Attendance Confirmation / Error Message
- **Process**: Scan QR, validate location, check work hours, create attendance record
- **Data Stores**: Settings Cache (Read), Backend API (Write)

### 3.0 Home Screen Process
- **Input**: View Request
- **Output**: Today's Attendance Status
- **Process**: Fetch today's attendance from backend, process and display
- **Data Stores**: Local Storage (Read), Backend API (Read)

### 4.0 Clock Out Process
- **Input**: Clock Out Request, GPS Location
- **Output**: Clock Out Confirmation / Error Message
- **Process**: Get location, create clock-out attendance record
- **Data Stores**: Backend API (Write)

### 5.0 Logbook Process
- **Input**: Logbook Form Data
- **Output**: Logbook Entry Confirmation / Error Message
- **Process**: Validate form, create logbook entry via API
- **Data Stores**: Backend API (Write)

### 6.0 Pengajuan Izin Process
- **Input**: Izin Form Data, Document
- **Output**: Izin Request Confirmation / Error Message
- **Process**: Validate form, upload document, create izin request via API
- **Data Stores**: File Service (Write), Backend API (Write)

### 7.0 Profile Management
- **Input**: Profile Update Request
- **Output**: Updated Profile Data
- **Process**: Fetch/update profile via API, update local storage
- **Data Stores**: Local Storage (Read/Write), Backend API (Read/Write)

### 8.0 Settings Fetch
- **Input**: Settings Request
- **Output**: Settings Data
- **Process**: Fetch settings from API, cache locally
- **Data Stores**: Settings Cache (Write), Backend API (Read)

## 📱 Mobile-Specific Features

### Offline Capability
- **Token Storage**: Token disimpan di local storage untuk offline authentication
- **Cache**: Settings di-cache untuk mengurangi API calls
- **Error Handling**: Graceful error handling dengan retry mechanism

### Device Integration
- **GPS Service**: Integrasi dengan device GPS untuk location tracking
- **Camera Service**: QR code scanning menggunakan device camera
- **Storage Service**: Local file storage untuk dokumen pendukung

### State Management
- **Providers**: Flutter Provider untuk state management
- **Refresh Logic**: Auto-refresh attendance status saat app dibuka
- **Day Change Detection**: Auto-reset state saat pergantian hari

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0  
**Platform**: Flutter Mobile Application

