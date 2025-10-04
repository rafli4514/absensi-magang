# API Services Documentation

## Struktur Integrasi Backend-Mobile

### 1. Konfigurasi API (`config/api_config.dart`)
File ini berisi semua endpoint API dan konfigurasi koneksi.

**Penting:** Ubah `baseUrl` sesuai environment:
- Emulator Android: `http://10.0.2.2:3000/api`
- Device Fisik: `http://YOUR_LOCAL_IP:3000/api`
- Production: `https://your-api.com/api`

### 2. Models (`models/`)
Berisi class untuk data structure:
- `api_response.dart` - Wrapper untuk semua response API
- `user_model.dart` - Model data user
- `absensi_model.dart` - Model data absensi
- `dashboard_model.dart` - Model data dashboard

### 3. Services (`services/`)

#### `api_service.dart` - Base HTTP Client
Menyediakan method dasar untuk HTTP request:
- `get(url)` - GET request
- `post(url, body)` - POST request
- `put(url, body)` - PUT request
- `delete(url)` - DELETE request
- `uploadFile(url, filePath, fieldName)` - Upload file

#### `auth_service.dart` - Authentication
```dart
// Login
final response = await AuthService.login(email, password);
if (response.success) {
  final user = response.data; // UserModel
}

// Register
final response = await AuthService.register(nama, email, password, confirmPassword);

// Logout
await AuthService.logout();

// Check login status
bool isLoggedIn = await AuthService.isLoggedIn();

// Get current user
UserModel? user = await AuthService.getCurrentUser();
```

#### `dashboard_service.dart` - Dashboard Data
```dart
// Get dashboard data
final response = await DashboardService.getDashboard();
if (response.success) {
  final dashboard = response.data; // DashboardModel
}

// Get daily stats
final response = await DashboardService.getDailyStats();
if (response.success) {
  final stats = response.data; // DashboardStats
}
```

#### `absensi_service.dart` - Absensi/Attendance
```dart
// Check in
final response = await AbsensiService.checkIn(
  lokasi: 'Kantor Pusat',
  keterangan: 'Masuk pagi',
  qrCode: 'QR_CODE_STRING',
);

// Check out
final response = await AbsensiService.checkOut(
  lokasi: 'Kantor Pusat',
  keterangan: 'Pulang',
);

// Get history
final response = await AbsensiService.getHistory(
  startDate: '2024-01-01',
  endDate: '2024-01-31',
  status: 'Hadir',
);

// Get statistics
final response = await AbsensiService.getStats(
  startDate: '2024-01-01',
  endDate: '2024-01-31',
);

// Get today's absensi
final response = await AbsensiService.getTodayAbsensi();
```

#### `user_service.dart` - User/Profile Management
```dart
// Get profile
final response = await UserService.getProfile();
if (response.success) {
  final user = response.data; // UserModel
}

// Update profile
final response = await UserService.updateProfile(
  nama: 'John Doe',
  email: 'john@example.com',
  nip: '123456',
  jabatan: 'Developer',
  divisi: 'IT',
);

// Change password
final response = await UserService.changePassword(
  oldPassword: 'old123',
  newPassword: 'new123',
  confirmPassword: 'new123',
);

// Upload avatar
final response = await UserService.uploadAvatar('/path/to/image.jpg');
if (response.success) {
  final avatarUrl = response.data; // String URL
}

// Delete avatar
await UserService.deleteAvatar();
```

### 4. Provider (`providers/auth_provider.dart`)
State management untuk authentication menggunakan Provider pattern.

```dart
// Dalam main.dart
import 'package:provider/provider.dart';

runApp(
  ChangeNotifierProvider(
    create: (context) => AuthProvider(),
    child: MyApp(),
  ),
);

// Dalam widget
final authProvider = Provider.of<AuthProvider>(context);

// Login
await authProvider.login(email, password);

// Check status
if (authProvider.isLoggedIn) {
  final user = authProvider.currentUser;
}

// Logout
await authProvider.logout();
```

## Error Handling

Semua service mengembalikan `ApiResponse<T>` dengan struktur:
```dart
{
  success: bool,
  message: String?,
  data: T?,
  error: dynamic
}
```

Contoh penggunaan:
```dart
final response = await AuthService.login(email, password);

if (response.success) {
  // Berhasil
  print('Success: ${response.message}');
  final user = response.data;
} else {
  // Gagal
  print('Error: ${response.message}');
  print('Details: ${response.error}');
}
```

## Testing API Connection

1. Pastikan backend running: `cd backend && npm run dev`
2. Test health endpoint:
   ```dart
   final response = await ApiService.get('http://localhost:3000/api/health');
   print(response);
   ```

## Next Steps

1. Update `ApiConfig.baseUrl` sesuai environment Anda
2. Implementasi login page dengan `AuthService`
3. Update dashboard page dengan `DashboardService`
4. Update absensi pages dengan `AbsensiService`
5. Update profile page dengan `UserService`
6. Tambahkan loading states dan error handling di UI

