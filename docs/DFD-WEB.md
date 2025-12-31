# Data Flow Diagram (DFD) - Web Application
## Sistem Absensi Magang - Aplikasi Web (React)

## 📊 Overview
Dokumen ini menjelaskan Data Flow Diagram (DFD) khusus untuk aplikasi web (React), menunjukkan alur data dari input admin hingga output dan interaksi dengan backend API.

## 🔄 DFD Levels

### DFD Level 0 (Context Diagram) - Web App

```mermaid
flowchart TD
    Admin[Admin] -->|Login, CRUD Operations, Reports| WebApp[Aplikasi Web<br/>React]
    WebApp -->|Dashboard, Reports, Management UI| Admin
    
    WebApp <-->|HTTP/HTTPS REST API| BackendAPI[Backend API<br/>Node.js/Express]
    BackendAPI <-->|Read/Write| Database[(PostgreSQL<br/>Database)]
    
    Browser[Browser Storage<br/>LocalStorage/SessionStorage] -->|Token, Preferences| WebApp
    WebApp -->|Store Token, Cache| Browser
```

**Deskripsi**:
- **External Entities**: Admin, Backend API, Database, Browser Storage
- **System**: Aplikasi Web React
- **Data Flows**: Login credentials, CRUD operations, report requests, API responses

### DFD Level 1 - Web Application Processes

```mermaid
flowchart TD
    Admin[Admin] -->|Username, Password| AuthProc[1.0 Authentication<br/>Process]
    AuthProc -->|Token| BrowserStore[(Browser Storage)]
    AuthProc -->|User Data| Admin
    
    BrowserStore -->|Token| AuthProc
    
    Admin -->|View Request| DashboardProc[2.0 Dashboard<br/>Process]
    DashboardProc -->|Token| BrowserStore
    DashboardProc -->|Request| API[Backend API]
    API -->|Statistics Data| DashboardProc
    DashboardProc -->|Display| Admin
    
    Admin -->|CRUD Operations| UserMgmtProc[3.0 User Management<br/>Process]
    UserMgmtProc -->|Token| BrowserStore
    UserMgmtProc -->|User Data| API
    API -->|Confirmation| UserMgmtProc
    UserMgmtProc -->|Status| Admin
    
    Admin -->|CRUD Operations| PesertaMgmtProc[4.0 Peserta Magang<br/>Management]
    PesertaMgmtProc -->|Token| BrowserStore
    PesertaMgmtProc -->|Peserta Data| API
    API -->|Confirmation| PesertaMgmtProc
    PesertaMgmtProc -->|Status| Admin
    
    Admin -->|View, Delete| AbsensiMgmtProc[5.0 Absensi<br/>Management]
    AbsensiMgmtProc -->|Token| BrowserStore
    AbsensiMgmtProc -->|Request| API
    API -->|Absensi Data| AbsensiMgmtProc
    AbsensiMgmtProc -->|Display| Admin
    
    Admin -->|Approve/Reject| IzinMgmtProc[6.0 Pengajuan Izin<br/>Management]
    IzinMgmtProc -->|Token| BrowserStore
    IzinMgmtProc -->|Status Update| API
    API -->|Confirmation| IzinMgmtProc
    IzinMgmtProc -->|Status| Admin
    
    Admin -->|Report Request| ReportProc[7.0 Laporan<br/>Generation]
    ReportProc -->|Token| BrowserStore
    ReportProc -->|Query| API
    API -->|Report Data| ReportProc
    ReportProc -->|Export File| Admin
    
    Admin -->|Settings CRUD| SettingsMgmtProc[8.0 Settings<br/>Management]
    SettingsMgmtProc -->|Token| BrowserStore
    SettingsMgmtProc -->|Settings Data| API
    API -->|Confirmation| SettingsMgmtProc
    SettingsMgmtProc -->|Status| Admin
    
    Admin -->|QR Code View| QRProc[9.0 QR Code<br/>Generation]
    QRProc -->|Token| BrowserStore
    QRProc -->|Request| API
    API -->|QR Data| QRProc
    QRProc -->|QR Image| Admin
```

### DFD Level 2: Authentication Process (1.0)

```mermaid
flowchart TD
    Admin[Admin] -->|Username, Password| ValidateInput[1.1 Validate Input]
    ValidateInput -->|Request| API[POST /auth/login]
    API -->|Response| ValidateInput
    
    ValidateInput -->|Success| SaveToken[1.2 Save Token<br/>& User Data]
    ValidateInput -->|Error| ErrorHandler[1.3 Error Handler]
    
    SaveToken -->|Token, User Data| BrowserStore[(Browser Storage)]
    BrowserStore -->|Stored| Redirect[1.4 Redirect to<br/>Dashboard]
    Redirect -->|Display| Admin
    
    ErrorHandler -->|Error Message| Admin
```

### DFD Level 2: Dashboard Process (2.0)

```mermaid
flowchart TD
    Admin[Admin] -->|View Request| LoadToken[2.1 Load Token]
    LoadToken -->|Token| BrowserStore[(Browser Storage)]
    LoadToken -->|Token| FetchStats[2.2 Fetch<br/>Statistics]
    
    FetchStats -->|Request + Token| API1[GET /dashboard/statistics]
    API1 -->|Statistics Data| ProcessData[2.3 Process<br/>Statistics Data]
    
    ProcessData -->|Aggregated Data| FormatDisplay[2.4 Format<br/>Display]
    FormatDisplay -->|Dashboard UI| Admin
    
    ProcessData -->|Error| ErrorHandler[2.5 Error Handler]
    ErrorHandler -->|Error Message| Admin
```

### DFD Level 2: User Management Process (3.0)

```mermaid
flowchart TD
    Admin[Admin] -->|CRUD Operation| ValidateOperation[3.1 Validate<br/>Operation]
    
    ValidateOperation -->|Create/Update| PrepareData[3.2 Prepare<br/>Data]
    ValidateOperation -->|Delete| ConfirmDelete[3.3 Confirm<br/>Delete]
    ValidateOperation -->|List| FetchUsers[3.4 Fetch<br/>Users]
    
    PrepareData -->|User Data| API1[POST/PUT /users]
    ConfirmDelete -->|Delete Request| API2[DELETE /users/:id]
    FetchUsers -->|Request| API3[GET /users]
    
    API1 -->|Confirmation| ProcessResponse[3.5 Process<br/>Response]
    API2 -->|Confirmation| ProcessResponse
    API3 -->|User List| ProcessResponse
    
    ProcessResponse -->|Updated List| UpdateUI[3.6 Update UI]
    UpdateUI -->|Display| Admin
```

### DFD Level 2: Peserta Magang Management Process (4.0)

```mermaid
flowchart TD
    Admin[Admin] -->|CRUD Operation| ValidateOperation[4.1 Validate<br/>Operation]
    
    ValidateOperation -->|Create/Update| PrepareData[4.2 Prepare<br/>Peserta Data]
    ValidateOperation -->|Delete| ConfirmDelete[4.3 Confirm<br/>Delete]
    ValidateOperation -->|List| FetchPeserta[4.4 Fetch<br/>Peserta]
    
    PrepareData -->|Peserta Data| API1[POST/PUT /peserta-magang]
    ConfirmDelete -->|Delete Request| API2[DELETE /peserta-magang/:id]
    FetchPeserta -->|Request| API3[GET /peserta-magang]
    
    API1 -->|Confirmation| ProcessResponse[4.5 Process<br/>Response]
    API2 -->|Confirmation| ProcessResponse
    API3 -->|Peserta List| ProcessResponse
    
    ProcessResponse -->|Updated List| UpdateUI[4.6 Update UI]
    UpdateUI -->|Display| Admin
```

### DFD Level 2: Absensi Management Process (5.0)

```mermaid
flowchart TD
    Admin[Admin] -->|View/Delete Request| LoadToken[5.1 Load Token]
    LoadToken -->|Token| BrowserStore[(Browser Storage)]
    LoadToken -->|Token| FetchAbsensi[5.2 Fetch<br/>Absensi Data]
    
    FetchAbsensi -->|Request + Token| API1[GET /absensi]
    API1 -->|Absensi Data| ProcessData[5.3 Process<br/>& Filter Data]
    
    ProcessData -->|Filtered Data| FormatTable[5.4 Format<br/>Table Display]
    FormatTable -->|Display| Admin
    
    Admin -->|Delete Request| DeleteAbsensi[5.5 Delete<br/>Absensi]
    DeleteAbsensi -->|Delete Request| API2[DELETE /absensi/:id]
    API2 -->|Confirmation| UpdateList[5.6 Update<br/>List]
    UpdateList -->|Updated Display| Admin
```

### DFD Level 2: Pengajuan Izin Management Process (6.0)

```mermaid
flowchart TD
    Admin[Admin] -->|View Request| FetchIzin[6.1 Fetch<br/>Pengajuan Izin]
    FetchIzin -->|Request| API1[GET /pengajuan-izin]
    API1 -->|Izin Data| ProcessData[6.2 Process<br/>Data]
    
    ProcessData -->|Izin List| FormatDisplay[6.3 Format<br/>Display]
    FormatDisplay -->|Display| Admin
    
    Admin -->|Approve/Reject| UpdateStatus[6.4 Update<br/>Status]
    UpdateStatus -->|Status Data| API2[PUT /pengajuan-izin/:id/approve<br/>or /reject]
    API2 -->|Confirmation| UpdateList[6.5 Update<br/>List]
    UpdateList -->|Updated Display| Admin
```

### DFD Level 2: Laporan Generation Process (7.0)

```mermaid
flowchart TD
    Admin[Admin] -->|Report Request| SelectParams[7.1 Select<br/>Parameters]
    
    SelectParams -->|Date Range, Filters| FetchData[7.2 Fetch<br/>Report Data]
    FetchData -->|Request| API[GET /absensi<br/>with filters]
    API -->|Attendance Data| ProcessData[7.3 Process<br/>& Aggregate Data]
    
    ProcessData -->|Aggregated Data| SelectFormat[7.4 Select<br/>Export Format]
    
    SelectFormat -->|CSV| GenerateCSV[7.5 Generate<br/>CSV]
    SelectFormat -->|Excel| GenerateExcel[7.6 Generate<br/>Excel]
    SelectFormat -->|PDF| GeneratePDF[7.7 Generate<br/>PDF]
    
    GenerateCSV -->|CSV File| Download[7.8 Download<br/>File]
    GenerateExcel -->|Excel File| Download
    GeneratePDF -->|PDF File| Download
    
    Download -->|File| Admin
```

### DFD Level 2: Settings Management Process (8.0)

```mermaid
flowchart TD
    Admin[Admin] -->|View Request| FetchSettings[8.1 Fetch<br/>Settings]
    FetchSettings -->|Request| API1[GET /settings]
    API1 -->|Settings Data| FormatDisplay[8.2 Format<br/>Display]
    FormatDisplay -->|Settings UI| Admin
    
    Admin -->|Update Request| ValidateUpdate[8.3 Validate<br/>Update]
    ValidateUpdate -->|Valid| UpdateSettings[8.4 Update<br/>Settings]
    ValidateUpdate -->|Invalid| ErrorHandler[8.6 Error Handler]
    
    UpdateSettings -->|Settings Data| API2[PUT /settings/:id]
    API2 -->|Confirmation| ProcessResponse[8.5 Process<br/>Response]
    ProcessResponse -->|Updated Settings| Admin
    
    ErrorHandler -->|Error Message| Admin
```

### DFD Level 2: QR Code Generation Process (9.0)

```mermaid
flowchart TD
    Admin[Admin] -->|View Request| LoadToken[9.1 Load Token]
    LoadToken -->|Token| BrowserStore[(Browser Storage)]
    LoadToken -->|Token| FetchQR[9.2 Fetch<br/>QR Data]
    
    FetchQR -->|Request + Token| API[GET /qr]
    API -->|QR Data| GenerateQR[9.3 Generate<br/>QR Code Image]
    
    GenerateQR -->|QR Image| DisplayQR[9.4 Display<br/>QR Code]
    DisplayQR -->|QR Image| Admin
```

## 📊 Data Dictionary

### Data Stores

#### Browser Storage
- **Description**: Browser local storage atau session storage
- **Contents**: 
  - `auth_token`: JWT token
  - `user_data`: User profile data (JSON)
  - `theme_preference`: UI theme preference
- **Volume**: ~10-50 KB
- **Access**: Read/Write by all processes

### Data Flows

#### Authentication Data
- **From**: Admin → Authentication Process
- **To**: Backend API → Browser Storage
- **Contents**: Username, Password → JWT Token, User Data
- **Frequency**: Once per login session

#### Statistics Data
- **From**: Backend API → Dashboard Process
- **To**: Admin Display
- **Contents**: Aggregated statistics (counts, percentages, trends)
- **Frequency**: On dashboard load, refresh

#### Management Data (Users, Peserta, Absensi)
- **From**: Backend API → Management Processes
- **To**: Admin Display
- **Contents**: CRUD operation results, lists, confirmations
- **Frequency**: On operation request

#### Report Data
- **From**: Backend API → Report Generation Process
- **To**: Admin (File Download)
- **Contents**: Filtered attendance data, aggregated statistics
- **Frequency**: On report generation request

#### Settings Data
- **From**: Backend API → Settings Management Process
- **To**: Admin Display
- **Contents**: System configuration settings
- **Frequency**: On settings page load, after update

## 🔍 Process Descriptions

### 1.0 Authentication Process
- **Input**: Username, Password
- **Output**: JWT Token, User Data / Error Message
- **Process**: Validate credentials dengan backend, save token in browser storage
- **Data Stores**: Browser Storage (Write)

### 2.0 Dashboard Process
- **Input**: View Request
- **Output**: Dashboard Statistics
- **Process**: Fetch statistics from backend, aggregate and display
- **Data Stores**: Browser Storage (Read), Backend API (Read)

### 3.0 User Management Process
- **Input**: CRUD Operations
- **Output**: User List, Confirmation / Error Message
- **Process**: Create, Read, Update, Delete users via API
- **Data Stores**: Backend API (Read/Write)

### 4.0 Peserta Magang Management Process
- **Input**: CRUD Operations
- **Output**: Peserta List, Confirmation / Error Message
- **Process**: Create, Read, Update, Delete peserta magang via API
- **Data Stores**: Backend API (Read/Write)

### 5.0 Absensi Management Process
- **Input**: View/Delete Request
- **Output**: Absensi List / Confirmation
- **Process**: Fetch absensi data, display in table, handle delete operations
- **Data Stores**: Backend API (Read/Write)

### 6.0 Pengajuan Izin Management Process
- **Input**: View/Approve/Reject Request
- **Output**: Izin List, Status Update Confirmation
- **Process**: Fetch izin requests, approve/reject via API
- **Data Stores**: Backend API (Read/Write)

### 7.0 Laporan Generation Process
- **Input**: Report Parameters (Date Range, Filters)
- **Output**: Report File (CSV/Excel/PDF)
- **Process**: Fetch data, aggregate, generate file in selected format
- **Data Stores**: Backend API (Read)

### 8.0 Settings Management Process
- **Input**: Settings Update Request
- **Output**: Updated Settings / Error Message
- **Process**: Fetch settings, update via API
- **Data Stores**: Backend API (Read/Write)

### 9.0 QR Code Generation Process
- **Input**: View Request
- **Output**: QR Code Image
- **Process**: Fetch QR data from API, generate QR code image
- **Data Stores**: Backend API (Read)

## 🌐 Web-Specific Features

### State Management
- **React Hooks**: useState, useEffect untuk local state management
- **API Service**: Centralized API service layer
- **Error Handling**: Global error handling dengan user-friendly messages

### UI/UX Features
- **Responsive Design**: Mobile-friendly responsive layout
- **Real-time Updates**: Auto-refresh untuk data yang sering berubah
- **File Export**: Multiple format export (CSV, Excel, PDF)
- **Data Filtering**: Advanced filtering untuk absensi dan reports

### Security Features
- **JWT Authentication**: Token-based authentication
- **Protected Routes**: Route protection berdasarkan role
- **Input Validation**: Client-side validation sebelum API call
- **CORS Handling**: Proper CORS configuration

### Performance Optimization
- **Data Pagination**: Pagination untuk large datasets
- **Lazy Loading**: Lazy loading untuk components
- **Caching**: Browser storage caching untuk frequently accessed data

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0  
**Platform**: React Web Application

