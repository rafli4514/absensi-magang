# 🧪 Testing Documentation

Dokumentasi untuk testing aplikasi backend.

## 📋 Setup

### 1. Install Dependencies

```bash
npm ci
```

### 2. Setup Test Database

Pastikan kamu punya test database PostgreSQL:

```env
TEST_DATABASE_URL=postgresql://test:test@localhost:5432/absensi_test_db?schema=public
```

Atau buat di `.env.test`:

```env
DATABASE_URL=postgresql://test:test@localhost:5432/absensi_test_db?schema=public
JWT_SECRET=test-jwt-secret-key
NODE_ENV=test
```

### 3. Run Migrations untuk Test Database

```bash
# Set DATABASE_URL ke test database
export DATABASE_URL="postgresql://test:test@localhost:5432/absensi_test_db?schema=public"

# Run migrations
npx prisma migrate deploy
```

## 🚀 Running Tests

### Run All Tests

```bash
npm test
```

### Run Tests in Watch Mode

```bash
npm run test:watch
```

### Run Tests with Coverage

```bash
npm run test:coverage
```

### Run Specific Test File

```bash
npm test -- auth.test.ts
npm test -- absensi.test.ts
```

### Run Tests Matching Pattern

```bash
npm test -- --testNamePattern="should login"
```

## 📁 Test Structure

```
tests/
├── setup.ts                 # Test setup and teardown
├── helpers/
│   └── test-helpers.ts     # Helper functions for tests
└── api/
    ├── health.test.ts      # Health check tests
    ├── auth.test.ts        # Authentication tests
    ├── absensi.test.ts     # Absensi tests
    └── dashboard.test.ts   # Dashboard tests
```

## 🧪 Test Categories

### 1. Unit Tests
- Test individual functions/utilities
- Mock dependencies
- Fast execution

### 2. Integration Tests
- Test API endpoints
- Test database interactions
- Test full request/response cycle

### 3. E2E Tests
- Test complete user flows
- Test multiple endpoints together

## 📝 Writing Tests

### Example Test Structure

```typescript
import request from 'supertest';
import app from '../../src/app';
import { createTestAdmin, getAuthHeaders } from '../helpers/test-helpers';

describe('Feature Name', () => {
  let adminUser: any;

  beforeAll(async () => {
    // Setup: create test data
    adminUser = await createTestAdmin();
  });

  afterAll(async () => {
    // Cleanup: remove test data
    await cleanupTestData();
  });

  describe('GET /api/endpoint', () => {
    it('should return success with valid request', async () => {
      const response = await request(app)
        .get('/api/endpoint')
        .set(getAuthHeaders(adminUser.token!))
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });
});
```

## 🔍 Test Helpers

### Available Helpers

- `createTestAdmin()` - Create test admin user with token
- `createTestPesertaMagang()` - Create test peserta magang with token
- `cleanupTestData()` - Clean up all test data
- `getAuthHeaders(token)` - Get authorization headers for requests

## 📊 Coverage Goals

- **Statements**: > 70%
- **Branches**: > 60%
- **Functions**: > 70%
- **Lines**: > 70%

## 🚨 Important Notes

1. **Test Database**: Tests menggunakan database terpisah (test database)
2. **Cleanup**: Test data akan di-cleanup setelah tests
3. **Isolation**: Setiap test file dijalankan secara independent
4. **Timeouts**: Default timeout 10 seconds

## 🐛 Troubleshooting

### Tests Fail with Database Connection Error

```bash
# Check if test database exists
psql -U test -d absensi_test_db

# Create test database
createdb -U test absensi_test_db

# Run migrations
export DATABASE_URL="postgresql://test:test@localhost:5432/absensi_test_db?schema=public"
npx prisma migrate deploy
```

### Tests Timeout

- Increase timeout di `jest.config.js`
- Check database connection
- Check if test data is being created properly

### Port Already in Use

```bash
# Check what's using the port
lsof -i :3000

# Kill the process or change PORT in .env.test
```

## 📚 Additional Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Supertest Documentation](https://github.com/visionmedia/supertest)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

