# Activity Diagram
## Sistem Absensi Magang

## 📊 Overview
Dokumen ini menjelaskan activity diagram untuk berbagai proses dalam sistem absensi magang.

## 🔄 Activity Diagrams

### 1. Activity Diagram: Proses Login

```mermaid
flowchart TD
    Start([User Membuka Halaman Login]) --> Input[Input Username dan Password]
    Input --> Validate{Validasi Input}
    Validate -->|Tidak Valid| Error1[Tampilkan Error]
    Error1 --> Input
    Validate -->|Valid| CheckDB{Check Database}
    CheckDB -->|User Tidak Ditemukan| Error2[Username/Password Salah]
    Error2 --> Input
    CheckDB -->|User Ditemukan| CheckActive{User Aktif?}
    CheckActive -->|Tidak Aktif| Error3[Akun Tidak Aktif]
    Error3 --> Input
    CheckActive -->|Aktif| GenerateToken[Generate JWT Token]
    GenerateToken --> SaveSession[Simpan Session]
    SaveSession --> Success[Login Berhasil]
    Success --> Redirect[Redirect ke Dashboard]
    Redirect --> End([End])
```

### 2. Activity Diagram: Proses Absensi Masuk

```mermaid
flowchart TD
    Start([Peserta Magang Membuka Halaman Absensi]) --> CheckLogin{User Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckActive{Status Aktif?}
    CheckActive -->|Tidak Aktif| Error1[Peserta Tidak Aktif]
    Error1 --> End1
    CheckActive -->|Aktif| CheckWorkDay{Hari Kerja?}
    CheckWorkDay -->|Bukan Hari Kerja| Error2[Hari Ini Bukan Hari Kerja]
    Error2 --> End1
    CheckWorkDay -->|Hari Kerja| CheckWorkHours{Jam Operasional?}
    CheckWorkHours -->|Di Luar Jam| Error3[Di Luar Jam Operasional]
    Error3 --> End1
    CheckWorkHours -->|Jam Operasional| ScanQR[Scan QR Code / Input Manual]
    ScanQR --> ValidateQR{QR Code Valid?}
    ValidateQR -->|Tidak Valid| Error4[QR Code Tidak Valid]
    Error4 --> ScanQR
    ValidateQR -->|Valid| GetLocation[Ambil Lokasi GPS]
    GetLocation --> CheckLocation{Validasi Lokasi}
    CheckLocation -->|Di Luar Radius| Error5[Lokasi Tidak Valid]
    Error5 --> End1
    CheckLocation -->|Dalam Radius| CheckLate{Check Keterlambatan}
    CheckLate -->|Terlambat| SetLate[Set Status TERLAMBAT]
    CheckLate -->|Tidak Terlambat| SetValid[Set Status VALID]
    SetLate --> CreateRecord[Create Absensi Record]
    SetValid --> CreateRecord
    CreateRecord --> TakeSelfie[Ambil Foto Selfie - Opsional]
    TakeSelfie --> SaveData[Simpan ke Database]
    SaveData --> UpdateDashboard[Update Dashboard]
    UpdateDashboard --> Success[Absensi Berhasil]
    Success --> End2([End])
```

### 3. Activity Diagram: Proses Pengajuan Izin

```mermaid
flowchart TD
    Start([Peserta Magang Membuka Form Pengajuan Izin]) --> CheckLogin{User Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| FillForm[Isi Form Pengajuan]
    FillForm --> InputData[Input: Tipe, Tanggal, Alasan]
    InputData --> UploadDoc[Upload Dokumen Pendukung - Opsional]
    UploadDoc --> Validate{Validasi Data}
    Validate -->|Tidak Valid| Error1[Tampilkan Error]
    Error1 --> FillForm
    Validate -->|Valid| CheckDate{Tanggal Valid?}
    CheckDate -->|Tidak Valid| Error2[Tanggal Tidak Valid]
    Error2 --> FillForm
    CheckDate -->|Valid| CreateRequest[Create Pengajuan dengan Status PENDING]
    CreateRequest --> SaveDB[Simpan ke Database]
    SaveDB --> NotifyAdmin[Notifikasi ke Admin - Opsional]
    NotifyAdmin --> Success[Pengajuan Berhasil Dibuat]
    Success --> End2([End])
```

### 4. Activity Diagram: Proses Persetujuan Pengajuan Izin

```mermaid
flowchart TD
    Start([Admin Membuka Detail Pengajuan Izin]) --> CheckLogin{Admin Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckRole{Role Admin?}
    CheckRole -->|Bukan Admin| Error1[Akses Ditolak]
    Error1 --> End1
    CheckRole -->|Admin| ViewRequest[Lihat Detail Pengajuan]
    ViewRequest --> Review[Review Pengajuan]
    Review --> Decision{Decision}
    Decision -->|Approve| AddNote1[Input Catatan - Opsional]
    AddNote1 --> UpdateStatus1[Update Status = DISETUJUI]
    UpdateStatus1 --> SaveApprover[Simpan Info Approver]
    SaveApprover --> SaveTime[Simpan Waktu Approval]
    SaveTime --> NotifyUser1[Notifikasi ke Peserta - Opsional]
    NotifyUser1 --> Success1[Pengajuan Disetujui]
    Success1 --> End2([End])
    Decision -->|Reject| AddNote2[Input Catatan Penolakan]
    AddNote2 --> UpdateStatus2[Update Status = DITOLAK]
    UpdateStatus2 --> SaveRejecter[Simpan Info Rejecter]
    SaveRejecter --> SaveRejectTime[Simpan Waktu Rejection]
    SaveRejectTime --> NotifyUser2[Notifikasi ke Peserta - Opsional]
    NotifyUser2 --> Success2[Pengajuan Ditolak]
    Success2 --> End2
    Decision -->|Pending| End2
```

### 5. Activity Diagram: Proses Create Peserta Magang

```mermaid
flowchart TD
    Start([Admin Membuka Form Peserta Magang]) --> CheckLogin{Admin Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckRole{Role Admin?}
    CheckRole -->|Bukan Admin| Error1[Akses Ditolak]
    Error1 --> End1
    CheckRole -->|Admin| FillForm[Isi Form Peserta Magang]
    FillForm --> InputData[Input: Nama, Username, Divisi, dll]
    InputData --> ValidateUsername{Username Unik?}
    ValidateUsername -->|Tidak Unik| Error2[Username Sudah Digunakan]
    Error2 --> FillForm
    ValidateUsername -->|Unik| ValidateData{Validasi Data}
    ValidateData -->|Tidak Valid| Error3[Tampilkan Error]
    Error3 --> FillForm
    ValidateData -->|Valid| CreateUser[Create User Account - Opsional]
    CreateUser --> LinkUser[Link User ke Peserta Magang]
    LinkUser --> CreatePeserta[Create Peserta Magang Record]
    CreatePeserta --> SaveDB[Simpan ke Database]
    SaveDB --> Success[Peserta Magang Berhasil Dibuat]
    Success --> End2([End])
```

### 6. Activity Diagram: Proses View Dashboard

```mermaid
flowchart TD
    Start([User Membuka Dashboard]) --> CheckLogin{User Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckRole{Check Role}
    CheckRole -->|Admin| GetAdminStats[Ambil Statistik Admin]
    GetAdminStats --> GetTotalPeserta[Total Peserta Magang]
    GetTotalPeserta --> GetAktifPeserta[Peserta Aktif]
    GetAktifPeserta --> GetAbsensiHariIni[Absensi Hari Ini]
    GetAbsensiHariIni --> GetTingkatKehadiran[Tingkat Kehadiran]
    GetTingkatKehadiran --> GetAktivitas[Aktivitas Terbaru]
    GetAktivitas --> DisplayAdmin[Dashboard Admin]
    CheckRole -->|Peserta Magang| GetPesertaStats[Ambil Statistik Peserta]
    GetPesertaStats --> GetAbsensiPribadi[Absensi Pribadi]
    GetAbsensiPribadi --> GetRiwayat[Riwayat Absensi]
    GetRiwayat --> GetPengajuan[Status Pengajuan Izin]
    GetPengajuan --> DisplayPeserta[Dashboard Peserta]
    CheckRole -->|Pembimbing| GetPembimbingStats[Ambil Statistik Pembimbing]
    GetPembimbingStats --> GetPesertaBimbingan[Peserta Bimbingan]
    GetPesertaBimbingan --> GetLaporan[Laporan Absensi]
    GetLaporan --> DisplayPembimbing[Dashboard Pembimbing]
    DisplayAdmin --> Render[Render Dashboard]
    DisplayPeserta --> Render
    DisplayPembimbing --> Render
    Render --> End2([End])
```

### 7. Activity Diagram: Proses Validasi Absensi

```mermaid
flowchart TD
    Start([Validasi Absensi Dimulai]) --> LoadSettings[Load Settings dari Database]
    LoadSettings --> CheckLocation{Require Location?}
    CheckLocation -->|Ya| GetLocation[Ambil Lokasi GPS]
    GetLocation --> CheckRadius{Check Radius}
    CheckRadius -->|Di Luar Radius| Invalid1[Status = INVALID]
    Invalid1 --> End1([End])
    CheckRadius -->|Dalam Radius| CheckWorkDay{Hari Kerja?}
    CheckLocation -->|Tidak| CheckWorkDay
    CheckWorkDay -->|Bukan Hari Kerja| Invalid2[Status = INVALID]
    Invalid2 --> End1
    CheckWorkDay -->|Hari Kerja| CheckWorkHours{Jam Operasional?}
    CheckWorkHours -->|Di Luar Jam| Invalid3[Status = INVALID]
    Invalid3 --> End1
    CheckWorkHours -->|Jam Operasional| CheckType{Tipe Absensi?}
    CheckType -->|MASUK| CheckLate{Check Keterlambatan}
    CheckLate -->|Terlambat| Late[Status = TERLAMBAT]
    CheckLate -->|Tidak Terlambat| Valid1[Status = VALID]
    CheckType -->|KELUAR| Valid2[Status = VALID]
    CheckType -->|IZIN/SAKIT/CUTI| Valid3[Status = VALID]
    Late --> End2([End])
    Valid1 --> End2
    Valid2 --> End2
    Valid3 --> End2
```

### 8. Activity Diagram: Proses Isi Logbook

```mermaid
flowchart TD
    Start([Peserta Magang Membuka Form Logbook]) --> CheckLogin{User Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckActive{Status Aktif?}
    CheckActive -->|Tidak Aktif| Error1[Peserta Tidak Aktif]
    Error1 --> End1
    CheckActive -->|Aktif| FillForm[Isi Form Logbook]
    FillForm --> InputData[Input: Tanggal, Kegiatan, Deskripsi, Durasi]
    InputData --> Validate{Validasi Data}
    Validate -->|Tidak Valid| Error2[Tampilkan Error]
    Error2 --> FillForm
    Validate -->|Valid| CheckDate{Tanggal Valid?}
    CheckDate -->|Tidak Valid| Error3[Tanggal Tidak Valid]
    Error3 --> FillForm
    CheckDate -->|Valid| CreateLogbook[Create Logbook dengan Status DRAFT]
    CreateLogbook --> SaveDB[Simpan ke Database]
    SaveDB --> Success[Logbook Berhasil Dibuat]
    Success --> End2([End])
```

### 9. Activity Diagram: Proses Submit Logbook

```mermaid
flowchart TD
    Start([Peserta Magang Membuka Detail Logbook]) --> CheckLogin{User Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckStatus{Status DRAFT?}
    CheckStatus -->|Bukan DRAFT| Error1[Logbook Sudah Disubmit]
    Error1 --> End1
    CheckStatus -->|DRAFT| ReviewData[Review Data Logbook]
    ReviewData --> Confirm{Konfirmasi Submit?}
    Confirm -->|Tidak| End1
    Confirm -->|Ya| UpdateStatus[Update Status = SUBMITTED]
    UpdateStatus --> SaveDB[Simpan ke Database]
    SaveDB --> NotifyPembimbing[Notifikasi ke Pembimbing - Opsional]
    NotifyPembimbing --> Success[Logbook Berhasil Disubmit]
    Success --> End2([End])
```

### 10. Activity Diagram: Proses Review Logbook (Pembimbing/Admin)

```mermaid
flowchart TD
    Start([Pembimbing/Admin Membuka Detail Logbook]) --> CheckLogin{User Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckRole{Role Pembimbing/Admin?}
    CheckRole -->|Bukan| Error1[Akses Ditolak]
    Error1 --> End1
    CheckRole -->|Ya| ViewLogbook[Lihat Detail Logbook]
    ViewLogbook --> Review[Review Logbook]
    Review --> CheckStatus{Status SUBMITTED?}
    CheckStatus -->|Bukan SUBMITTED| Error2[Logbook Belum Disubmit]
    Error2 --> End1
    CheckStatus -->|SUBMITTED| Decision{Decision}
    Decision -->|Approve| AddNote1[Input Catatan - Opsional]
    AddNote1 --> UpdateStatus1[Update Status = APPROVED]
    UpdateStatus1 --> SaveApprover[Simpan Info Approver]
    SaveApprover --> SaveTime[Simpan Waktu Approval]
    SaveTime --> NotifyUser1[Notifikasi ke Peserta - Opsional]
    NotifyUser1 --> Success1[Logbook Disetujui]
    Success1 --> End2([End])
    Decision -->|Reject| AddNote2[Input Catatan Penolakan]
    AddNote2 --> UpdateStatus2[Update Status = REJECTED]
    UpdateStatus2 --> SaveRejecter[Simpan Info Rejecter]
    SaveRejecter --> SaveRejectTime[Simpan Waktu Rejection]
    SaveRejectTime --> NotifyUser2[Notifikasi ke Peserta - Opsional]
    NotifyUser2 --> Success2[Logbook Ditolak]
    Success2 --> End2
    Decision -->|Pending| End2
```

### 11. Activity Diagram: Proses Update Settings

```mermaid
flowchart TD
    Start([Admin Membuka Settings]) --> CheckLogin{Admin Sudah Login?}
    CheckLogin -->|Tidak| RedirectLogin[Redirect ke Login]
    RedirectLogin --> End1([End])
    CheckLogin -->|Ya| CheckRole{Role Admin?}
    CheckRole -->|Bukan Admin| Error1[Akses Ditolak]
    Error1 --> End1
    CheckRole -->|Admin| ViewSettings[Lihat Settings]
    ViewSettings --> SelectSetting[Pilih Setting yang Akan Diupdate]
    SelectSetting --> EditValue[Edit Nilai Setting]
    EditValue --> Validate{Validasi Nilai}
    Validate -->|Tidak Valid| Error2[Tampilkan Error]
    Error2 --> EditValue
    Validate -->|Valid| UpdateSetting[Update Setting di Database]
    UpdateSetting --> SaveDB[Simpan Perubahan]
    SaveDB --> ReloadConfig[Reload Konfigurasi]
    ReloadConfig --> Success[Setting Berhasil Diupdate]
    Success --> End2([End])
```

## 📊 Activity Summary

### Total Activities
- **Login Process**: 1 activity diagram
- **Absensi Process**: 2 activity diagrams (Masuk, Validasi)
- **Pengajuan Izin Process**: 2 activity diagrams (Create, Approval)
- **Logbook Process**: 3 activity diagrams (Isi, Submit, Review)
- **Management Process**: 2 activity diagrams (Create Peserta, Update Settings)
- **Dashboard Process**: 1 activity diagram

### Key Decision Points
1. **Authentication Checks**: Login status, role validation
2. **Data Validation**: Input validation, business rules
3. **Location Validation**: GPS radius check
4. **Time Validation**: Work day, work hours, late check
5. **Status Determination**: Valid, Invalid, Terlambat

### Common Patterns
- **Authentication First**: Semua activity dimulai dengan check login
- **Role-Based Access**: Admin-only activities check role
- **Validation Loops**: Error handling dengan kembali ke input
- **Database Operations**: Create, Read, Update operations
- **Status Updates**: Status changes dengan notifications

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi**: 1.0.0


