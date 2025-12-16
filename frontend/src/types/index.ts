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
  id_peserta_magang?: string; // NISN/NIM
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
  // Embedded pesertaMagang is optional when the API expands relations
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
  tipe: "SAKIT" | "IZIN" | "CUTI";
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
}