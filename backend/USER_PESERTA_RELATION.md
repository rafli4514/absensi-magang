# Relasi Users dan Peserta Magang - Dokumentasi Perubahan

## Masalah Sebelumnya
Tabel `users` dan `peserta_magang` tidak terhubung secara langsung, menyebabkan:
- Duplikasi data username
- Tidak ada hubungan antara akun login dan data peserta magang
- Sulit untuk mengelola autentikasi peserta magang

## Solusi yang Diterapkan

### 1. Perubahan Schema Database
- Menambahkan kolom `userId` di tabel `peserta_magang` sebagai foreign key ke tabel `users`
- Membuat relasi one-to-one antara `User` dan `PesertaMagang`
- Menggunakan cascade delete untuk menjaga integritas data

### 2. Migration Database
- Membuat migration untuk menambahkan kolom `userId` (nullable)
- Menjalankan script SQL untuk menghubungkan data yang sudah ada
- Membuat user baru untuk peserta magang yang belum memiliki akun

### 3. Update Controller

#### PesertaMagangController
- `createPesertaMagang`: Sekarang membuat user dan peserta magang secara bersamaan
- `getAllPesertaMagang`: Include data user dalam response
- `getPesertaMagangById`: Include data user dan relasi lainnya
- `getPesertaMagangByUserId`: Endpoint baru untuk mendapatkan peserta magang berdasarkan user ID
- `deletePesertaMagang`: Menghapus user yang terkait saat menghapus peserta magang

#### AuthController
- `loginPesertaMagang`: Menggunakan relasi untuk autentikasi peserta magang
- `getProfile`: Include data peserta magang jika user adalah peserta magang

### 4. Endpoint Baru
- `GET /api/peserta-magang/user/:userId` - Mendapatkan peserta magang berdasarkan user ID

## Struktur Relasi Baru

```
User (1) ←→ (1) PesertaMagang
  ↓
  (1) ←→ (N) Absensi
  ↓
  (1) ←→ (N) PengajuanIzin
```

## Keuntungan
1. **Integritas Data**: Tidak ada duplikasi username
2. **Autentikasi Terpusat**: Semua login menggunakan tabel users
3. **Fleksibilitas**: Mudah untuk menambah role atau permission
4. **Konsistensi**: Data peserta magang selalu terkait dengan akun user

## Cara Penggunaan

### Membuat Peserta Magang Baru
```json
POST /api/peserta-magang
{
  "nama": "John Doe",
  "username": "johndoe",
  "password": "password123",
  "divisi": "IT",
  "instansi": "Universitas ABC",
  "nomorHp": "08123456789",
  "tanggalMulai": "2024-01-01",
  "tanggalSelesai": "2024-06-30"
}
```

### Login Peserta Magang
```json
POST /api/auth/login-peserta-magang
{
  "username": "johndoe",
  "password": "password123"
}
```

### Mendapatkan Profile User
```
GET /api/auth/profile
```
Response akan include data peserta magang jika user adalah peserta magang.

## Catatan Penting
- Password peserta magang sekarang di-hash menggunakan bcrypt
- Saat menghapus peserta magang, user yang terkait juga akan dihapus
- Semua endpoint peserta magang sekarang include data user dalam response
