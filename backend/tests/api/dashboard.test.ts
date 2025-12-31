import request from 'supertest';
import app from '../../src/app';
import { createTestAdmin, cleanupTestData, getAuthHeaders } from '../helpers/test-helpers';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Dashboard API', () => {
  let adminUser: any;

  beforeAll(async () => {
    await cleanupTestData();
    adminUser = await createTestAdmin();
  });

  afterAll(async () => {
    await cleanupTestData();
    await prisma.$disconnect();
  });

  describe('GET /api/dashboard/statistics', () => {
    it('should get dashboard statistics', async () => {
      const response = await request(app)
        .get('/api/dashboard/statistics')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('totalPesertaMagang');
      expect(response.body.data).toHaveProperty('pesertaMagangAktif');
      expect(response.body.data).toHaveProperty('absensiMasukHariIni');
      expect(response.body.data).toHaveProperty('absensiKeluarHariIni');
      expect(response.body.data).toHaveProperty('tingkatKehadiran');
    });

    it('should fail to get statistics without authentication', async () => {
      const response = await request(app)
        .get('/api/dashboard/statistics')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/dashboard/recent-absensi', () => {
    it('should get recent absensi', async () => {
      const response = await request(app)
        .get('/api/dashboard/recent-absensi')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });
});

