// Status Peserta Magang mapping
export const statusPesertaMapping = {
'AKTIF': 'Aktif',
'NONAKTIF': 'Nonaktif',
'SELESAI': 'Selesai'
} as const;

export const displayToStatusPeserta = {
'Aktif': 'AKTIF',
'Nonaktif': 'NONAKTIF',
'Selesai': 'SELESAI'
} as const;

// Tipe Absensi mapping
export const tipeAbsensiMapping = {
'MASUK': 'Masuk',
'KELUAR': 'Keluar',
'IZIN': 'Izin',
'SAKIT': 'Sakit',
'CUTI': 'Cuti'
} as const;

export const displayToTipeAbsensi = {
'Masuk': 'MASUK',
'Keluar': 'KELUAR',
'Izin': 'IZIN',
'Sakit': 'SAKIT',
'Cuti': 'CUTI'
} as const;

// Status Absensi mapping
export const statusAbsensiMapping = {
'VALID': 'Valid',
'INVALID': 'Invalid',
'TERLAMBAT': 'Terlambat'
} as const;

export const displayToStatusAbsensi = {
'Valid': 'VALID',
'Invalid': 'INVALID',
'Terlambat': 'TERLAMBAT'
} as const;

// Tipe Izin mapping (UPDATE DISINI)
export const tipeIzinMapping = {
'SAKIT': 'Sakit',
'IZIN': 'Izin',
'CUTI': 'Cuti',
'PULANG_CEPAT': 'Pulang Cepat',
'ALPHA': 'Alpha',
'LAINNYA': 'Lainnya'
} as const;

export const displayToTipeIzin = {
'Sakit': 'SAKIT',
'Izin': 'IZIN',
'Cuti': 'CUTI',
'Pulang Cepat': 'PULANG_CEPAT',
'Alpha': 'ALPHA',
'Lainnya': 'LAINNYA'
} as const;

// Status Pengajuan mapping
export const statusPengajuanMapping = {
'PENDING': 'Menunggu',
'DISETUJUI': 'Disetujui',
'DITOLAK': 'Ditolak'
} as const;

export const displayToStatusPengajuan = {
'Menunggu': 'PENDING',
'Disetujui': 'DISETUJUI',
'Ditolak': 'DITOLAK'
} as const;

// Role mapping
export const roleMapping = {
'ADMIN': 'Admin',
'PESERTA_MAGANG': 'Peserta Magang',
'PEMBIMBING_MAGANG': 'Pembimbing Magang'
} as const;

export const displayToRole = {
'Admin': 'ADMIN',
'Peserta Magang': 'PESERTA_MAGANG',
'Pembimbing Magang': 'PEMBIMBING_MAGANG'
} as const;

// Helper functions
export const getDisplayStatus = (dbStatus: keyof typeof statusPesertaMapping) => statusPesertaMapping[dbStatus] || dbStatus;
export const getDisplayTipeAbsensi = (dbTipe: keyof typeof tipeAbsensiMapping) => tipeAbsensiMapping[dbTipe] || dbTipe;
export const getDisplayStatusAbsensi = (dbStatus: keyof typeof statusAbsensiMapping) => statusAbsensiMapping[dbStatus] || dbStatus;
export const getDisplayTipeIzin = (dbTipe: keyof typeof tipeIzinMapping) => tipeIzinMapping[dbTipe] || dbTipe;
export const getDisplayStatusPengajuan = (dbStatus: keyof typeof statusPengajuanMapping) => statusPengajuanMapping[dbStatus] || dbStatus;
export const getDisplayRole = (dbRole: keyof typeof roleMapping) => roleMapping[dbRole] || dbRole;