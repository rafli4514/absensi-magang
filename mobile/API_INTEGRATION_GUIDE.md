# 🚀 Panduan Lengkap Integrasi Backend-Mobile

## 📋 Daftar Isi
1. [Setup Backend](#1-setup-backend)
2. [Konfigurasi Mobile](#2-konfigurasi-mobile)
3. [Testing Koneksi](#3-testing-koneksi)
4. [Implementasi ke Halaman](#4-implementasi-ke-halaman)
5. [Tips & Troubleshooting](#5-tips--troubleshooting)

---

## 1. Setup Backend

### Jalankan Backend Server

```bash
# Masuk ke folder backend
cd backend

# Install dependencies (jika belum)
npm install

# Jalankan development server
npm run dev
```

Backend akan running di: **http://localhost:3000**

### Test Backend dengan Browser/Postman

1. Health Check: `http://localhost:3000/api/health`
2. Login: `POST http://localhost:3000/api/auth/login`
   ```json
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```

---

## 2. Konfigurasi Mobile

### Update API Config Sesuai Environment

Edit `mobile/lib/config/api_config.dart`:

#### Testing di Emulator Android:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String uploadsUrl = 'http://10.0.2.2:3000/uploads';
```

#### Testing di Device Fisik:
1. Cari IP lokal komputer Anda:
   - Windows: `ipconfig` → cari IPv4 Address
   - Mac/Linux: `ifconfig` atau `ip addr`
   
2. Update config:
```dart
static const String baseUrl = 'http://192.168.1.XXX:3000/api';
static const String uploadsUrl = 'http://192.168.1.XXX:3000/uploads';
```

#### Production:
```dart
static const String baseUrl = 'https://your-api.com/api';
static const String uploadsUrl = 'https://your-api.com/uploads';
```

---

## 3. Testing Koneksi

### Test Health Check

Buat file test sederhana atau tambahkan di login page:

```dart
Future<void> testConnection() async {
  try {
    final response = await ApiService.get(
      'http://10.0.2.2:3000/api/health'
    );
    print('Connection Success: $response');
  } catch (e) {
    print('Connection Failed: $e');
  }
}
```

### Common Issues:

#### Error: "Connection refused" / "SocketException"
- ✅ Pastikan backend sudah running
- ✅ Pastikan API URL sesuai (10.0.2.2 untuk emulator)
- ✅ Cek firewall komputer

#### Error: "Unauthorized"
- ✅ Token sudah kedaluwarsa atau belum login
- ✅ Header Authorization tidak ada

#### Error: "Timeout"
- ✅ Backend terlalu lama merespon
- ✅ Koneksi internet lambat

---

## 4. Implementasi ke Halaman

### A. Login Page

Update `mobile/lib/pages/login.dart`:

```dart
import '../services/auth_service.dart';
import '../components/main_wrapper.dart';

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final response = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (response.success && response.data != null) {
      // Login berhasil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainWrapper()),
      );
    } else {
      // Login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Login gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### B. Dashboard Page

Update `mobile/lib/pages/dashboard.dart`:

```dart
import '../services/dashboard_service.dart';
import '../services/auth_service.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';

class _DashboardPageState extends State<DashboardPage> {
  DashboardModel? _dashboardData;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get user data
      final user = await AuthService.getCurrentUser();
      
      // Get dashboard data
      final dashboardResponse = await DashboardService.getDashboard();
      
      if (dashboardResponse.success) {
        setState(() {
          _currentUser = user;
          _dashboardData = dashboardResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // ... rest of your UI
      // Gunakan _currentUser?.nama untuk nama user
      // Gunakan _dashboardData?.stats untuk statistik
    );
  }
}
```

### C. Profile Page

Update `mobile/lib/pages/profil.dart`:

```dart
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class _ProfilPageState extends State<ProfilPage> {
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await UserService.getProfile();
      
      if (response.success && response.data != null) {
        setState(() {
          _userData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await UserService.updateProfile(
        nama: _namaController.text,
        nip: _nimController.text,
        jabatan: _jabatanController.text,
        divisi: _divisiController.text,
      );

      if (response.success) {
        setState(() {
          _userData = response.data;
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
```

### D. Absensi Pages

Update `mobile/lib/pages/absen_masuk.dart`:

```dart
import '../services/absensi_service.dart';

Future<void> _checkIn() async {
  setState(() => _isLoading = true);

  try {
    final response = await AbsensiService.checkIn(
      lokasi: _lokasiController.text,
      keterangan: _keteranganController.text,
      qrCode: _qrCodeData, // dari scan QR
    );

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Check-in berhasil'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### E. Riwayat Absensi Page

Update `mobile/lib/pages/riwayat_absensi.dart`:

```dart
import '../services/absensi_service.dart';
import '../models/absensi_model.dart';

class _RiwayatAbsensiPageState extends State<RiwayatAbsensiPage> {
  List<AbsensiModel> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final response = await AbsensiService.getHistory(
        status: _selectedFilter == 'Semua' ? null : _selectedFilter,
      );

      if (response.success && response.data != null) {
        setState(() {
          _historyList = response.data!;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## 5. Tips & Troubleshooting

### Best Practices

1. **Selalu cek `mounted` sebelum `setState`**
   ```dart
   if (!mounted) return;
   setState(() { ... });
   ```

2. **Gunakan try-catch untuk error handling**
   ```dart
   try {
     final response = await Service.method();
   } catch (e) {
     // Handle error
   }
   ```

3. **Tampilkan loading indicator**
   ```dart
   if (_isLoading) {
     return Center(child: CircularProgressIndicator());
   }
   ```

4. **Simpan data penting di local storage**
   - Token sudah otomatis disimpan oleh `ApiService`
   - User data sudah otomatis disimpan saat login

### Common Errors & Solutions

| Error | Solution |
|-------|----------|
| Connection refused | Backend belum running atau URL salah |
| Unauthorized (401) | Token kedaluwarsa, perlu login ulang |
| Not Found (404) | Endpoint salah, cek routes backend |
| Server Error (500) | Error di backend, cek log server |
| Timeout | Koneksi lambat atau backend lambat |

### Testing Flow

1. ✅ Start backend: `cd backend && npm run dev`
2. ✅ Update `api_config.dart` dengan URL yang benar
3. ✅ Test health endpoint terlebih dahulu
4. ✅ Test login dengan user dummy dari backend
5. ✅ Test fitur lainnya satu per satu

### Debug Tips

```dart
// Tambahkan print untuk debug
print('Request: $url');
print('Body: $body');
print('Response: $response');

// Atau gunakan debugger
debugPrint('Debug message');
```

---

## 📚 Referensi File

- **Konfigurasi**: `lib/config/api_config.dart`
- **Models**: `lib/models/`
- **Services**: `lib/services/`
- **Provider**: `lib/providers/auth_provider.dart`
- **Contoh Login**: `lib/pages/login_example.dart`
- **Dokumentasi Services**: `lib/services/README.md`

---

## 🎯 Next Steps

1. Update `api_config.dart` dengan URL yang sesuai
2. Jalankan backend server
3. Implementasikan login page dengan `AuthService`
4. Update dashboard dengan `DashboardService`
5. Update profil dengan `UserService`
6. Update absensi pages dengan `AbsensiService`
7. Test semua fitur end-to-end

---

## ❓ Butuh Bantuan?

Jika ada error atau masalah:
1. Cek apakah backend sudah running
2. Cek log backend untuk error details
3. Cek console Flutter untuk error messages
4. Pastikan URL API sudah benar
5. Pastikan struktur response backend sesuai dengan model

Semoga berhasil! 🚀

