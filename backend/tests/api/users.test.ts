import request from 'supertest';
import app from '../../src/app';
import { createTestAdmin, cleanupTestData, getAuthHeaders } from '../helpers/test-helpers';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Users API', () => {
  let adminUser: any;

  beforeAll(async () => {
    await cleanupTestData();
    adminUser = await createTestAdmin();
  });

  afterAll(async () => {
    await cleanupTestData();
    await prisma.$disconnect();
  });

  describe('GET /api/users', () => {
    it('should get all users (admin only)', async () => {
      const response = await request(app)
        .get('/api/users')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('should fail to get users without authentication', async () => {
      const response = await request(app)
        .get('/api/users')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/users', () => {
    it('should create a new user (admin only)', async () => {
      const response = await request(app)
        .post('/api/users')
        .set(getAuthHeaders(adminUser.token!))
        .send({
          username: `testuser${Date.now()}`,
          password: 'testpassword123',
          role: 'PESERTA_MAGANG',
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('username');
      expect(response.body.data).not.toHaveProperty('password');
    });

    it('should fail to create user with duplicate username', async () => {
      const username = `testuser${Date.now()}`;
      
      // Create first user
      await request(app)
        .post('/api/users')
        .set(getAuthHeaders(adminUser.token!))
        .send({
          username,
          password: 'testpassword123',
          role: 'PESERTA_MAGANG',
        })
        .expect(201);

      // Try to create duplicate
      const response = await request(app)
        .post('/api/users')
        .set(getAuthHeaders(adminUser.token!))
        .send({
          username,
          password: 'testpassword123',
          role: 'PESERTA_MAGANG',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });
});

