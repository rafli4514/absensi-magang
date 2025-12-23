// Test setup file
import { PrismaClient } from '@prisma/client';

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-for-testing-only';
process.env.DATABASE_URL = process.env.TEST_DATABASE_URL || 'postgresql://test:test@localhost:5432/absensi_test_db?schema=public';

// Cleanup after all tests
afterAll(async () => {
  // Add any cleanup logic here
  // For example, close database connections
});

// Global test timeout
jest.setTimeout(10000);

