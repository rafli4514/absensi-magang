import { PrismaClient } from '@prisma/client';

// Global variable to store Prisma client instance
declare global {
  var __prisma: PrismaClient | undefined;
}

// Create Prisma client instance
const prisma = globalThis.__prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  errorFormat: 'pretty',
});

// In development, save the client to global variable to prevent multiple instances
if (process.env.NODE_ENV === 'development') {
  globalThis.__prisma = prisma;
}

export default prisma;

// Database connection helper
export const connectDatabase = async (): Promise<void> => {
  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    throw error;
  }
};

// Database disconnection helper
export const disconnectDatabase = async (): Promise<void> => {
  try {
    await prisma.$disconnect();
    console.log('📴 Database disconnected');
  } catch (error) {
    console.error('❌ Database disconnection failed:', error);
    throw error;
  }
};

// Health check for database
export const checkDatabaseHealth = async (): Promise<boolean> => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch (error) {
    console.error('❌ Database health check failed:', error);
    return false;
  }
};
