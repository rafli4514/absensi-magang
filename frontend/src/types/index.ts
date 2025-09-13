export interface User {
  id: string;
  nama: string;
  username: string;
  role: "admin" | "student";
  avatar?: string;
  createdAt: string; 
  updatedAt: string; 
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
  status: "Aktif" | "Nonaktif" | "Selesai";
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Absensi {
  id: string;
  pesertaMagangId: string;
  // Embedded pesertaMagang is optional when the API expands relations
  pesertaMagang?: PesertaMagang;
  tipe: "Masuk" | "Keluar";
  timestamp: string;
  lokasi?: {
    latitude: number;
    longitude: number;
    alamat: string;
  };
  selfieUrl?: string;
  qrCodeData: string;
  status: "valid" | "invalid" | "Terlambat";
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
  tipe: "sakit" | "izin" | "cuti";
  tanggalMulai: string;
  tanggalSelesai: string;
  alasan: string;
  status: "pending" | "disetujui" | "ditolak";
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
}
