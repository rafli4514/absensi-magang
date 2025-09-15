import { prisma } from '../lib/prisma';

const DEFAULT_SETTINGS = [
  // QR Settings
  { key: 'qr.autoGenerate', value: true, category: 'qr' },
  { key: 'qr.validityPeriod', value: 5, category: 'qr' },
  { key: 'qr.size', value: 'medium', category: 'qr' },
  
  // Attendance Settings
  { key: 'attendance.allowLateCheckIn', value: true, category: 'attendance' },
  { key: 'attendance.lateThreshold', value: 15, category: 'attendance' },
  { key: 'attendance.requireLocation', value: true, category: 'attendance' },
  { key: 'attendance.allowRemoteCheckIn', value: false, category: 'attendance' },
  
  // Schedule Settings
  { key: 'schedule.workStartTime', value: '08:00', category: 'schedule' },
  { key: 'schedule.workEndTime', value: '17:00', category: 'schedule' },
  { key: 'schedule.breakStartTime', value: '12:00', category: 'schedule' },
  { key: 'schedule.breakEndTime', value: '13:00', category: 'schedule' },
  { key: 'schedule.workDays', value: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'], category: 'schedule' },
  
  // Location Settings
  { key: 'location.officeAddress', value: 'Jakarta, Indonesia', category: 'location' },
  { key: 'location.latitude', value: -6.2088, category: 'location' },
  { key: 'location.longitude', value: 106.8456, category: 'location' },
  { key: 'location.radius', value: 100, category: 'location' },
  
  // Security Settings
  { key: 'security.faceVerification', value: true, category: 'security' },
  { key: 'security.ipWhitelist', value: false, category: 'security' },
  { key: 'security.sessionTimeout', value: 60, category: 'security' },
];

export const seedSettings = async () => {
  console.log('🌱 Seeding default settings...');
  
  try {
    // Check if settings already exist
    const existingSettings = await prisma.settings.count();
    
    if (existingSettings > 0) {
      console.log('⚠️ Settings already exist, skipping seed');
      return;
    }

    // Create default settings
    for (const setting of DEFAULT_SETTINGS) {
      await prisma.settings.create({
        data: setting
      });
    }

    console.log('✅ Default settings seeded successfully');
  } catch (error) {
    console.error('❌ Error seeding settings:', error);
    throw error;
  }
};

// Run seed if this file is executed directly
if (require.main === module) {
  seedSettings()
    .then(() => {
      console.log('Settings seed completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Settings seed failed:', error);
      process.exit(1);
    });
}
