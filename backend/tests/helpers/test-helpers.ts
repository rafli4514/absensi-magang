import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { generateToken } from '../../src/utils/jwt';

const prisma = new PrismaClient();

export interface TestUser {
  id: string;
  username: string;
  password: string;
  role: string;
  token?: string;
}

export interface TestPesertaMagang {
  id: string;
  nama: string;
  username: string;
  password: string;
  divisi: string;
  instansi: string;
  nomorHp: string;
  token?: string;
  userId?: string;
}

/**
 * Create a test admin user
 */
export async function createTestAdmin(): Promise<TestUser> {
  const hashedPassword = await bcrypt.hash('testpassword123', 10);
  
  const user = await prisma.user.upsert({
    where: { username: 'testadmin' },
    update: {},
    create: {
      username: 'testadmin',
      password: hashedPassword,
      role: 'ADMIN',
      isActive: true,
    },
  });

  const token = generateToken({
    id: user.id,
    username: user.username,
    role: user.role,
  });

  return {
    id: user.id,
    username: user.username,
    password: 'testpassword123',
    role: user.role,
    token,
  };
}

/**
 * Create a test peserta magang
 */
export async function createTestPesertaMagang(): Promise<TestPesertaMagang> {
  const hashedPassword = await bcrypt.hash('testpassword123', 10);
  
  // Create user first
  const user = await prisma.user.create({
    data: {
      username: `testpeserta${Date.now()}`,
      password: hashedPassword,
      role: 'PESERTA_MAGANG',
      isActive: true,
    },
  });

  // Create peserta magang
  const peserta = await prisma.pesertaMagang.create({
    data: {
      nama: 'Test Peserta Magang',
      username: user.username,
      divisi: 'IT',
      instansi: 'Test University',
      nomorHp: '081234567890',
      tanggalMulai: '2024-01-01',
      tanggalSelesai: '2024-12-31',
      status: 'AKTIF',
      userId: user.id,
    },
  });

  const token = generateToken({
    id: user.id,
    username: user.username,
    role: user.role,
  });

  return {
    id: peserta.id,
    nama: peserta.nama,
    username: peserta.username,
    password: 'testpassword123',
    divisi: peserta.divisi,
    instansi: peserta.instansi,
    nomorHp: peserta.nomorHp,
    token,
    userId: user.id,
  };
}

/**
 * Clean up test data
 */
export async function cleanupTestData() {
  // Delete in reverse order of dependencies
  await prisma.absensi.deleteMany({});
  await prisma.pengajuanIzin.deleteMany({});
  await prisma.logbook.deleteMany({});
  await prisma.pesertaMagang.deleteMany({});
  await prisma.user.deleteMany({});
  await prisma.settings.deleteMany({});
}

/**
 * Get auth headers for API requests
 */
export function getAuthHeaders(token: string) {
  return {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };
}

