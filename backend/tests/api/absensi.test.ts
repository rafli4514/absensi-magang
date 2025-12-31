import request from 'supertest';
import app from '../../src/app';
import { createTestAdmin, createTestPesertaMagang, cleanupTestData, getAuthHeaders } from '../helpers/test-helpers';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Absensi API', () => {
  let adminUser: any;
  let pesertaMagang: any;

  beforeAll(async () => {
    await cleanupTestData();
    adminUser = await createTestAdmin();
    pesertaMagang = await createTestPesertaMagang();
  });

  afterAll(async () => {
    await cleanupTestData();
    await prisma.$disconnect();
  });

  describe('POST /api/absensi', () => {
    it('should create clock-in absensi', async () => {
      const response = await request(app)
        .post('/api/absensi')
        .set(getAuthHeaders(pesertaMagang.token!))
        .send({
          tipe: 'MASUK',
          timestamp: new Date().toISOString(),
          lokasi: {
            latitude: -6.2088,
            longitude: 106.8456,
            alamat: 'Test Location',
          },
          qrCodeData: 'test-qr-code',
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.tipe).toBe('MASUK');
    });

    it('should fail to create absensi without authentication', async () => {
      const response = await request(app)
        .post('/api/absensi')
        .send({
          tipe: 'MASUK',
          timestamp: new Date().toISOString(),
        })
        .expect(401);

      expect(response.body.success).toBe(false);
    });

    it('should fail to create absensi with invalid data', async () => {
      const response = await request(app)
        .post('/api/absensi')
        .set(getAuthHeaders(pesertaMagang.token!))
        .send({
          tipe: 'INVALID_TYPE',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/absensi', () => {
    it('should get list of absensi (admin)', async () => {
      const response = await request(app)
        .get('/api/absensi')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('should fail to get absensi without authentication', async () => {
      const response = await request(app)
        .get('/api/absensi')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/absensi/peserta/:id', () => {
    it('should get absensi by peserta id', async () => {
      const response = await request(app)
        .get(`/api/absensi/peserta/${pesertaMagang.id}`)
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });
});

