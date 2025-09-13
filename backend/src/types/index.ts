// Shared types for the backend

export interface User {
  id: string;
  username: string;
  email: string;
  role: 'admin' | 'user';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface PesertaMagang {
  id: string;
  nama: string;
  username: string;
  divisi: string;
  universitas: string;
  nomorHp: string;
  tanggalMulai: string;
  tanggalSelesai: string;
  status: 'Aktif' | 'Nonaktif' | 'Selesai';
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Absensi {
  id: string;
  pesertaMagangId: string;
  tipe: 'Masuk' | 'Keluar' | 'Izin' | 'Sakit' | 'Cuti';
  timestamp: string;
  lokasi?: {
    latitude: number;
    longitude: number;
    alamat: string;
  };
  selfieUrl?: string;
  qrCodeData?: string;
  status: 'valid' | 'Terlambat' | 'invalid';
  createdAt: string;
  updatedAt?: string;
}

export interface PengajuanIzin {
  id: string;
  pesertaMagangId: string;
  tipe: 'sakit' | 'izin' | 'cuti';
  tanggalMulai: string;
  tanggalSelesai: string;
  alasan: string;
  status: 'pending' | 'disetujui' | 'ditolak';
  dokumenPendukung?: string;
  disetujuiOleh?: string;
  disetujuiPada?: string;
  catatan?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
