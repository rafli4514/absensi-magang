import request from 'supertest';
import app from '../../src/app';
import { createTestAdmin, cleanupTestData, getAuthHeaders } from '../helpers/test-helpers';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

describe('Settings API', () => {
  let adminUser: any;

  beforeAll(async () => {
    await cleanupTestData();
    adminUser = await createTestAdmin();
  });

  afterAll(async () => {
    await cleanupTestData();
    await prisma.$disconnect();
  });

  describe('GET /api/settings', () => {
    it('should get all settings', async () => {
      const response = await request(app)
        .get('/api/settings')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
    });

    it('should fail to get settings without authentication', async () => {
      const response = await request(app)
        .get('/api/settings')
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });
});

