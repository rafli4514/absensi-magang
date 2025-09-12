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
  TanggalMulai: string;
  TanggalSelesai: string;
  status: "Aktif" | "Nonaktif" | "Selesai";
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Absensi {
  id: string;
  pesertaMagangId: string;
  pesertaMagang: PesertaMagang;
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
    selesai: string;
  };
}

export interface DashboardStats {
  totalPesertaMagang: number;
  pesertaMagangAktif: number;
  AbsensiMasukHariIni: number;
  AbsensiKeluarHariIni: number;
  tingkatKehadiran: number;
  aktivitasBaruBaruIni: Absensi[];
}
