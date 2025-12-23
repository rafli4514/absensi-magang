# Dokumentasi Sistem Absensi Magang

## 📚 Daftar Dokumentasi

Dokumentasi lengkap untuk sistem absensi magang yang mencakup aplikasi mobile (Flutter) dan web (React), beserta backend API (Node.js/Express).

### 📊 Diagram & Dokumentasi Teknis

1. **[ERD-COMPLETE.md](./ERD-COMPLETE.md)**
   - Entity Relationship Diagram lengkap
   - Struktur database PostgreSQL
   - Relasi antar entitas
   - Enumerations dan constraints

2. **[DFD-MOBILE.md](./DFD-MOBILE.md)**
   - Data Flow Diagram untuk aplikasi mobile
   - Alur data dari user input hingga backend
   - Process descriptions untuk setiap proses
   - Mobile-specific features

3. **[DFD-WEB.md](./DFD-WEB.md)**
   - Data Flow Diagram untuk aplikasi web
   - Alur data untuk admin operations
   - Process descriptions untuk CRUD operations
   - Web-specific features

4. **[UML-CLASS-COMPLETE.md](./UML-CLASS-COMPLETE.md)**
   - UML Class Diagram lengkap
   - Backend models (Prisma)
   - Mobile models (Flutter)
   - Web components (React)
   - Service layers

5. **[UML-SEQUENCE.md](./UML-SEQUENCE.md)**
   - Sequence diagrams untuk proses penting
   - Login process (mobile & web)
   - Clock in/out process
   - Report generation
   - Approval workflows

6. **[UML-USECASE.md](./UML-USECASE.md)**
   - Use case diagrams untuk mobile dan web
   - Detail setiap use case
   - Aktor dan hubungan use case
   - Preconditions dan postconditions

## 🏗️ Arsitektur Sistem

### Platform
- **Mobile**: Flutter (Dart)
- **Web**: React (TypeScript)
- **Backend**: Node.js + Express (TypeScript)
- **Database**: PostgreSQL
- **ORM**: Prisma

### Komponen Utama

```
┌─────────────┐         ┌─────────────┐
│   Mobile    │         │     Web     │
│   (Flutter) │         │   (React)   │
└──────┬──────┘         └──────┬──────┘
       │                       │
       │    HTTP/REST API      │
       └───────────┬───────────┘
                   │
         ┌─────────▼─────────┐
         │   Backend API     │
         │  (Node.js/Express)│
         └─────────┬─────────┘
                   │
         ┌─────────▼─────────┐
         │   PostgreSQL      │
         │   (via Prisma)    │
         └───────────────────┘
```

## 📋 Entitas Utama

1. **User**: Admin, pembimbing magang
2. **PesertaMagang**: Peserta magang
3. **Absensi**: Record absensi masuk/keluar
4. **PengajuanIzin**: Pengajuan izin peserta
5. **Logbook**: Log kegiatan peserta
6. **Settings**: Konfigurasi sistem

## 🔄 Alur Utama

### Mobile App
1. Login → 2. Clock In (QR Scan) → 3. Clock Out → 4. View History
5. Submit Logbook → 6. Submit Pengajuan Izin → 7. View Profile

### Web App
1. Login → 2. Dashboard → 3. Manage Users/Peserta → 4. View Absensi
5. Manage Pengajuan Izin → 6. Generate Reports → 7. Manage Settings

## 📖 Cara Menggunakan Dokumentasi

1. **Untuk memahami struktur database**: Baca [ERD-COMPLETE.md](./ERD-COMPLETE.md)
2. **Untuk memahami alur data mobile**: Baca [DFD-MOBILE.md](./DFD-MOBILE.md)
3. **Untuk memahami alur data web**: Baca [DFD-WEB.md](./DFD-WEB.md)
4. **Untuk memahami struktur class**: Baca [UML-CLASS-COMPLETE.md](./UML-CLASS-COMPLETE.md)
5. **Untuk memahami alur proses**: Baca [UML-SEQUENCE.md](./UML-SEQUENCE.md)
6. **Untuk memahami use cases**: Baca [UML-USECASE.md](./UML-USECASE.md)

## 🎯 Diagram Rendering

Semua diagram menggunakan format Mermaid yang dapat di-render di:
- GitHub (otomatis)
- VS Code dengan extension Mermaid Preview
- Online: https://mermaid.live/
- Dokumentasi tools: GitBook, MkDocs, dll

## 📝 Notasi

- **ERD**: Entity Relationship Diagram menggunakan notasi Crow's Foot
- **DFD**: Data Flow Diagram dengan level 0, 1, dan 2
- **UML**: Unified Modeling Language (Class, Sequence, Use Case)

## 🔄 Versi

- **ERD**: v2.0.0
- **DFD**: v1.0.0
- **UML**: v2.0.0 (Class), v1.0.0 (Sequence, Use Case)

---

**Dibuat oleh**: Tim Development  
**Tanggal**: 2024  
**Versi Dokumentasi**: 1.0.0

