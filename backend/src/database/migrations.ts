import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Database migration utilities
export class DatabaseMigrations {
  /**
   * Run all pending migrations
   */
  static async runMigrations(): Promise<void> {
    try {
      console.log('🔄 Running database migrations...');
      
      // Check if database is accessible
      await prisma.$queryRaw`SELECT 1`;
      
      // Run Prisma migrations
      const { execSync } = require('child_process');
      execSync('npx prisma db push', { stdio: 'inherit' });
      
      console.log('✅ Database migrations completed successfully');
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    }
  }

  /**
   * Reset database (drop all data)
   */
  static async resetDatabase(): Promise<void> {
    try {
      console.log('🔄 Resetting database...');
      
      // Delete all records in reverse order of dependencies
      await prisma.absensi.deleteMany();
      await prisma.pengajuanIzin.deleteMany();
      await prisma.pesertaMagang.deleteMany();
      await prisma.user.deleteMany();
      
      console.log('✅ Database reset completed');
    } catch (error) {
      console.error('❌ Database reset failed:', error);
      throw error;
    }
  }

  /**
   * Check database schema version
   */
  static async checkSchemaVersion(): Promise<string | null> {
    try {
      const result = await prisma.$queryRaw`
        SELECT version FROM _prisma_migrations 
        ORDER BY finished_at DESC 
        LIMIT 1
      ` as any[];
      
      return result[0]?.version || null;
    } catch (error) {
      console.warn('⚠️ Could not check schema version:', error);
      return null;
    }
  }

  /**
   * Get database statistics
   */
  static async getDatabaseStats(): Promise<{
    users: number;
    pesertaMagang: number;
    absensi: number;
    pengajuanIzin: number;
  }> {
    try {
      const [users, pesertaMagang, absensi, pengajuanIzin] = await Promise.all([
        prisma.user.count(),
        prisma.pesertaMagang.count(),
        prisma.absensi.count(),
        prisma.pengajuanIzin.count(),
      ]);

      return {
        users,
        pesertaMagang,
        absensi,
        pengajuanIzin,
      };
    } catch (error) {
      console.error('❌ Failed to get database stats:', error);
      throw error;
    }
  }

  /**
   * Backup database (export data)
   */
  static async backupDatabase(): Promise<{
    users: any[];
    pesertaMagang: any[];
    absensi: any[];
    pengajuanIzin: any[];
  }> {
    try {
      console.log('💾 Creating database backup...');
      
      const [users, pesertaMagang, absensi, pengajuanIzin] = await Promise.all([
        prisma.user.findMany(),
        prisma.pesertaMagang.findMany(),
        prisma.absensi.findMany(),
        prisma.pengajuanIzin.findMany(),
      ]);

      const backup = {
        users,
        pesertaMagang,
        absensi,
        pengajuanIzin,
        timestamp: new Date().toISOString(),
      };

      console.log('✅ Database backup created');
      return backup;
    } catch (error) {
      console.error('❌ Database backup failed:', error);
      throw error;
    }
  }

  /**
   * Restore database from backup
   */
  static async restoreDatabase(backup: any): Promise<void> {
    try {
      console.log('🔄 Restoring database from backup...');
      
      // Reset database first
      await this.resetDatabase();
      
      // Restore data
      if (backup.users?.length) {
        await prisma.user.createMany({ data: backup.users });
      }
      
      if (backup.pesertaMagang?.length) {
        await prisma.pesertaMagang.createMany({ data: backup.pesertaMagang });
      }
      
      if (backup.absensi?.length) {
        await prisma.absensi.createMany({ data: backup.absensi });
      }
      
      if (backup.pengajuanIzin?.length) {
        await prisma.pengajuanIzin.createMany({ data: backup.pengajuanIzin });
      }
      
      console.log('✅ Database restored from backup');
    } catch (error) {
      console.error('❌ Database restore failed:', error);
      throw error;
    }
  }
}

export default DatabaseMigrations;
