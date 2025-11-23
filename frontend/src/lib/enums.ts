// Utility functions untuk mapping enum values antara database dan display

// Status Peserta Magang mapping
export const statusPesertaMapping = {
  // Database -> Display
  'AKTIF': 'Aktif',
  'NONAKTIF': 'Nonaktif', 
  'SELESAI': 'Selesai'
} as const;

export const displayToStatusPeserta = {
  // Display -> Database
  'Aktif': 'AKTIF',
  'Nonaktif': 'NONAKTIF',
  'Selesai': 'SELESAI'
} as const;

// Tipe Absensi mapping
export const tipeAbsensiMapping = {
  // Database -> Display
  'MASUK': 'Masuk',
  'KELUAR': 'Keluar',
  'IZIN': 'Izin',
  'SAKIT': 'Sakit',
  'CUTI': 'Cuti'
} as const;

export const displayToTipeAbsensi = {
  // Display -> Database
  'Masuk': 'MASUK',
  'Keluar': 'KELUAR',
  'Izin': 'IZIN',
  'Sakit': 'SAKIT',
  'Cuti': 'CUTI'
} as const;

// Status Absensi mapping
export const statusAbsensiMapping = {
  // Database -> Display
  'VALID': 'Valid',
  'INVALID': 'Invalid',
  'TERLAMBAT': 'Terlambat'
} as const;

export const displayToStatusAbsensi = {
  // Display -> Database
  'Valid': 'VALID',
  'Invalid': 'INVALID',
  'Terlambat': 'TERLAMBAT'
} as const;

// Tipe Izin mapping
export const tipeIzinMapping = {
  // Database -> Display
  'SAKIT': 'Sakit',
  'IZIN': 'Izin',
  'CUTI': 'Cuti'
} as const;

export const displayToTipeIzin = {
  // Display -> Database
  'Sakit': 'SAKIT',
  'Izin': 'IZIN',
  'Cuti': 'CUTI'
} as const;

// Status Pengajuan mapping
export const statusPengajuanMapping = {
  // Database -> Display
  'PENDING': 'Menunggu',
  'DISETUJUI': 'Disetujui',
  'DITOLAK': 'Ditolak'
} as const;

export const displayToStatusPengajuan = {
  // Display -> Database
  'Menunggu': 'PENDING',
  'Disetujui': 'DISETUJUI',
  'Ditolak': 'DITOLAK'
} as const;

// Role mapping
export const roleMapping = {
  // Database -> Display
  'ADMIN': 'Admin',
  'USER': 'User',
  'PEMBIMBING_MAGANG': 'Pembimbing Magang'
} as const;

export const displayToRole = {
  // Display -> Database
  'Admin': 'ADMIN',
  'User': 'USER',
  'Pembimbing Magang': 'PEMBIMBING_MAGANG'
} as const;

// Helper functions
export const getDisplayStatus = (dbStatus: keyof typeof statusPesertaMapping) => {
  return statusPesertaMapping[dbStatus] || dbStatus;
};

export const getDisplayTipeAbsensi = (dbTipe: keyof typeof tipeAbsensiMapping) => {
  return tipeAbsensiMapping[dbTipe] || dbTipe;
};

export const getDisplayStatusAbsensi = (dbStatus: keyof typeof statusAbsensiMapping) => {
  return statusAbsensiMapping[dbStatus] || dbStatus;
};

export const getDisplayTipeIzin = (dbTipe: keyof typeof tipeIzinMapping) => {
  return tipeIzinMapping[dbTipe] || dbTipe;
};

export const getDisplayStatusPengajuan = (dbStatus: keyof typeof statusPengajuanMapping) => {
  return statusPengajuanMapping[dbStatus] || dbStatus;
};

export const getDisplayRole = (dbRole: keyof typeof roleMapping) => {
  return roleMapping[dbRole] || dbRole;
};
