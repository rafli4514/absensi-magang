import request from 'supertest';
import app from '../../src/app';
import { createTestAdmin, createTestPesertaMagang, cleanupTestData, getAuthHeaders } from '../helpers/test-helpers';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Authentication API', () => {
  let adminUser: any;
  let pesertaMagang: any;

  beforeAll(async () => {
    // Clean up before tests
    await cleanupTestData();
    adminUser = await createTestAdmin();
    pesertaMagang = await createTestPesertaMagang();
  });

  afterAll(async () => {
    await cleanupTestData();
    await prisma.$disconnect();
  });

  describe('POST /api/auth/login', () => {
    it('should login admin successfully with valid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          username: adminUser.username,
          password: adminUser.password,
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data).toHaveProperty('user');
      expect(response.body.data.user.username).toBe(adminUser.username);
      expect(response.body.data.user.role).toBe('ADMIN');
    });

    it('should fail login with invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          username: 'invaliduser',
          password: 'wrongpassword',
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid credentials');
    });

    it('should fail login with missing credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          username: adminUser.username,
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('required');
    });
  });

  describe('POST /api/auth/login-peserta', () => {
    it('should login peserta magang successfully', async () => {
      const response = await request(app)
        .post('/api/auth/login-peserta')
        .send({
          username: pesertaMagang.username,
          password: pesertaMagang.password,
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data).toHaveProperty('user');
      expect(response.body.data).toHaveProperty('pesertaMagang');
    });

    it('should fail login peserta with invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login-peserta')
        .send({
          username: 'invalidpeserta',
          password: 'wrongpassword',
        })
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/auth/profile', () => {
    it('should get profile with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/profile')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('username');
      expect(response.body.data).toHaveProperty('role');
    });

    it('should fail to get profile without token', async () => {
      const response = await request(app)
        .get('/api/auth/profile')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('required');
    });

    it('should fail to get profile with invalid token', async () => {
      const response = await request(app)
        .get('/api/auth/profile')
        .set(getAuthHeaders('invalid-token'))
        .expect(403);

      expect(response.body.success).toBe(false);
    });
  });
});

