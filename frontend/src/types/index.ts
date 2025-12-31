export interface User {
  id: string;
  username: string;
  role: "ADMIN" | "PESERTA_MAGANG" | "PEMBIMBING_MAGANG";
  isActive: boolean;
  avatar?: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface PesertaMagang {
  id: string;
  nama: string;
  username: string;
  id_peserta_magang?: string;
  divisi: string;
  instansi: string;
  id_instansi?: string;
  nomorHp: string;
  tanggalMulai: string;
  tanggalSelesai: string;
  status: "AKTIF" | "NONAKTIF" | "SELESAI";
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Absensi {
  id: string;
  pesertaMagangId: string;
  pesertaMagang?: PesertaMagang;
  tipe: "MASUK" | "KELUAR" | "IZIN" | "SAKIT" | "CUTI";
  timestamp: string;
  lokasi?: {
    latitude: number;
    longitude: number;
    alamat: string;
  };
  selfieUrl?: string;
  qrCodeData: string;
  status: "VALID" | "INVALID" | "TERLAMBAT";
  catatan?: string;
  createdAt: string;
  updatedAt?: string;
  ipAddress?: string;
  device?: string;
}

export interface LaporanAbsensi {
  pesertaMagangId: string;
  pesertaMagangName: string;
  totalHari: number;
  hadir: number;
  tidakHadir: number;
  terlambat: number;
  tingkatKehadiran: number;
  periode: {
    mulai: string;
  };
}

export interface PengajuanIzin {
  id: string;
  pesertaMagangId: string;
  pesertaMagang?: PesertaMagang;
  // UPDATE DISINI: Tambahkan tipe baru
  tipe: "SAKIT" | "IZIN" | "CUTI" | "PULANG_CEPAT" | "ALPHA";
  tanggalMulai: string;
  tanggalSelesai: string;
  alasan: string;
  status: "PENDING" | "DISETUJUI" | "DITOLAK";
  diajukanPada: string;
  dokumenPendukung?: string;
  disetujuiOleh?: string;
  disetujuiPada?: string;
  catatan?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface DashboardStats {
  totalPesertaMagang: number;
  pesertaMagangAktif: number;
  absensiMasukHariIni: number;
  absensiKeluarHariIni: number;
  tingkatKehadiran: number;
  aktivitasBaruBaruIni: Absensi[];
  // Tambahan untuk Dashboard Kehadiran
  attendance?: {
    present: number;
    permission: number;
    sick: number;
    pending: number;
    alpha: number;
  };
}

// Tipe Gabungan untuk UI (Unified Row)
export interface UnifiedAttendanceLog {
  id: string;
  sourceType: 'ABSENSI' | 'IZIN';
  peserta: PesertaMagang | undefined;
  timestamp: string;
  
  // Normalized Status
  statusDisplay: "HADIR" | "TERLAMBAT" | "IZIN" | "SAKIT" | "PENDING" | "INVALID" | "REJECTED";
  statusColor: "green" | "orange" | "blue" | "red" | "yellow" | "gray";
  
  // Detail Data
  tipe: string;
  detailTimeOrDuration: string;
  lokasiOrAlasan: string;
  buktiUrl?: string;
  
  // Original Data (untuk aksi API)
  originalData: Absensi | PengajuanIzin;
}