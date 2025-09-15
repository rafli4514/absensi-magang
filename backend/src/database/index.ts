// Database module exports
export { default as prisma, connectDatabase, disconnectDatabase, checkDatabaseHealth } from './connection';
export { default as DatabaseMigrations } from './migrations';

// Re-export Prisma types for convenience
export type { PrismaClient } from '@prisma/client';
export type { 
  User, 
  PesertaMagang, 
  Absensi, 
  PengajuanIzin,
  Role,
  StatusPeserta,
  TipeAbsensi,
  StatusAbsensi,
  TipeIzin,
  StatusPengajuan
} from '@prisma/client';
