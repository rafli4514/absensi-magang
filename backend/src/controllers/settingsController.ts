import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response';
import QRCode from 'qrcode';
import crypto from 'crypto';

interface AppSettings {
  attendance: {
    allowLateCheckIn: boolean;
    lateThreshold: number;
    requireLocation: boolean;
    allowRemoteCheckIn: boolean;
  };
  schedule: {
    workStartTime: string;
    workEndTime: string;
    breakStartTime: string;
    breakEndTime: string;
    workDays: string[];
  };
  location: {
    officeAddress: string;
    latitude: number;
    longitude: number;
    radius: number;
    useRadius: boolean;
  };
  security: {
    faceVerification: boolean;
    ipWhitelist: boolean;
    sessionTimeout: number;
    allowedIps: string[];
  };
}

// Default settings
const DEFAULT_SETTINGS: AppSettings = {
  attendance: {
    allowLateCheckIn: true,
    lateThreshold: 15,
    requireLocation: true,
    allowRemoteCheckIn: false
  },
  schedule: {
    workStartTime: '08:00',
    workEndTime: '17:00',
    breakStartTime: '12:00',
    breakEndTime: '13:00',
    workDays: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']
  },
  location: {
    officeAddress: 'PT PLN Icon Plus Kantor Perwakilan Aceh, Jl. Teuku Umar, Banda Aceh',
    latitude: 5.5454249,
    longitude: 95.3175582,
    radius: 100,
    useRadius: true
  },
  security: {
    faceVerification: true,
    ipWhitelist: false,
    sessionTimeout: 60,
    allowedIps: []
  }
};

export const getSettings = async (req: Request, res: Response) => {
  try {
    // Get all settings from database
    const settingsRecords = await prisma.settings.findMany();
    
    if (settingsRecords.length === 0) {
      // If no settings exist, return default settings
      return sendSuccess(res, 'Default settings loaded', DEFAULT_SETTINGS);
    }

    // Convert settings records to settings object
    const settings: any = { ...DEFAULT_SETTINGS };
    
    settingsRecords.forEach(record => {
      const keys = record.key.split('.');
      let current = settings;
      
      for (let i = 0; i < keys.length - 1; i++) {
        if (!current[keys[i]]) {
          current[keys[i]] = {};
        }
        current = current[keys[i]];
      }
      
      current[keys[keys.length - 1]] = record.value;
    });

    sendSuccess(res, 'Settings retrieved successfully', settings);
  } catch (error) {
    console.error('Get settings error:', error);
    sendError(res, 'Failed to retrieve settings', 500);
  }
};

export const updateSettings = async (req: Request, res: Response) => {
  try {
    const settingsData = req.body as Partial<AppSettings>;

    // Validate settings data
    if (!settingsData || typeof settingsData !== 'object') {
      return sendError(res, 'Invalid settings data', 400);
    }

    // Server-side validation
    const validationErrors: string[] = [];

    // Validate attendance settings
    if (settingsData.attendance) {
      if (settingsData.attendance.lateThreshold && (settingsData.attendance.lateThreshold < 0 || settingsData.attendance.lateThreshold > 120)) {
        validationErrors.push('Late threshold must be between 0 and 120 minutes');
      }
    }

    // Validate schedule settings
    if (settingsData.schedule) {
      const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
      if (settingsData.schedule.workStartTime && !timeRegex.test(settingsData.schedule.workStartTime)) {
        validationErrors.push('Work start time must be in HH:MM format');
      }
      if (settingsData.schedule.workEndTime && !timeRegex.test(settingsData.schedule.workEndTime)) {
        validationErrors.push('Work end time must be in HH:MM format');
      }
      if (settingsData.schedule.breakStartTime && !timeRegex.test(settingsData.schedule.breakStartTime)) {
        validationErrors.push('Break start time must be in HH:MM format');
      }
      if (settingsData.schedule.breakEndTime && !timeRegex.test(settingsData.schedule.breakEndTime)) {
        validationErrors.push('Break end time must be in HH:MM format');
      }
    }

    // Validate location settings
    if (settingsData.location) {
      if (settingsData.location.latitude && (settingsData.location.latitude < -90 || settingsData.location.latitude > 90)) {
        validationErrors.push('Latitude must be between -90 and 90');
      }
      if (settingsData.location.longitude && (settingsData.location.longitude < -180 || settingsData.location.longitude > 180)) {
        validationErrors.push('Longitude must be between -180 and 180');
      }
      if (settingsData.location.useRadius && settingsData.location.radius && (settingsData.location.radius < 10 || settingsData.location.radius > 2000)) {
        validationErrors.push('Location radius must be between 10 and 2000 meters when radius is enabled');
      }
    }

    // Validate security settings
    if (settingsData.security) {
      if (settingsData.security.sessionTimeout && (settingsData.security.sessionTimeout < 5 || settingsData.security.sessionTimeout > 480)) {
        validationErrors.push('Session timeout must be between 5 and 480 minutes');
      }
      
      // Validate IP addresses
      if (settingsData.security.allowedIps) {
        const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
        for (const ip of settingsData.security.allowedIps) {
          if (!ipRegex.test(ip)) {
            validationErrors.push(`Invalid IP address format: ${ip}`);
          }
        }
      }
    }

    if (validationErrors.length > 0) {
      return sendError(res, `Validation errors: ${validationErrors.join(', ')}`, 400);
    }

    // Flatten settings object to key-value pairs
    const settingsToUpdate: Array<{ key: string; value: any; category: string }> = [];
    
    const flattenSettings = (obj: any, prefix: string = '', category: string = '') => {
      for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
          const fullKey = prefix ? `${prefix}.${key}` : key;
          const currentCategory = category || key;
          
          if (typeof obj[key] === 'object' && obj[key] !== null && !Array.isArray(obj[key])) {
            flattenSettings(obj[key], fullKey, currentCategory);
          } else {
            settingsToUpdate.push({
              key: fullKey,
              value: obj[key],
              category: currentCategory
            });
          }
        }
      }
    };

    flattenSettings(settingsData);

    // Update or create settings in database
    const updatePromises = settingsToUpdate.map(setting =>
      prisma.settings.upsert({
        where: { key: setting.key },
        update: {
          value: setting.value,
          category: setting.category,
          updatedAt: new Date()
        },
        create: {
          key: setting.key,
          value: setting.value,
          category: setting.category
        }
      })
    );

    await Promise.all(updatePromises);

    // Get updated settings
    const updatedSettingsRecords = await prisma.settings.findMany();
    const updatedSettings: any = { ...DEFAULT_SETTINGS };
    
    updatedSettingsRecords.forEach(record => {
      const keys = record.key.split('.');
      let current = updatedSettings;
      
      for (let i = 0; i < keys.length - 1; i++) {
        if (!current[keys[i]]) {
          current[keys[i]] = {};
        }
        current = current[keys[i]];
      }
      
      current[keys[keys.length - 1]] = record.value;
    });

    sendSuccess(res, 'Settings updated successfully', updatedSettings);
  } catch (error) {
    console.error('Update settings error:', error);
    sendError(res, 'Failed to update settings', 500);
  }
};

export const generateQRCode = async (req: Request, res: Response) => {
  try {
    const { type = 'masuk' } = req.query; // Get attendance type from query
    
    // Get QR settings
    const qrSettings = await prisma.settings.findFirst({
      where: { key: 'qr.validityPeriod' }
    });

    const validityPeriod = qrSettings?.value as number || 5; // default 5 minutes
    
    // Generate attendance QR data with consistent format
    const now = new Date();
    const qrData = JSON.stringify({
      type: type as string,
      timestamp: now.toISOString(),
      location: "ICONNET_OFFICE",
      validUntil: new Date(now.getTime() + validityPeriod * 60 * 1000).toISOString(),
      sessionId: `ABSEN_${(type as string).toUpperCase()}_${Date.now()}`
    });

    // Generate QR code as base64
    const qrCodeDataURL = await QRCode.toDataURL(qrData, {
      width: 300,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    });

    // Extract base64 part (remove data:image/png;base64, prefix)
    const base64QR = qrCodeDataURL.split(',')[1];
    
    // Calculate expiration time
    const expiresAt = new Date(now.getTime() + (validityPeriod * 60 * 1000));

    // Store QR code data in database (optional - for validation later)
    await prisma.settings.upsert({
      where: { key: 'current_qr_code' },
      update: {
        value: {
          data: qrData,
          expiresAt: expiresAt.toISOString(),
          createdAt: new Date().toISOString()
        },
        category: 'qr'
      },
      create: {
        key: 'current_qr_code',
        value: {
          data: qrData,
          expiresAt: expiresAt.toISOString(),
          createdAt: new Date().toISOString()
        },
        category: 'qr'
      }
    });

    sendSuccess(res, 'QR Code generated successfully', {
      qrCode: base64QR,
      expiresAt: expiresAt.toISOString(),
      validityPeriod
    });
  } catch (error) {
    console.error('Generate QR code error:', error);
    sendError(res, 'Failed to generate QR code', 500);
  }
};

export const validateQRCode = async (req: Request, res: Response) => {
  try {
    const { qrData } = req.body;

    if (!qrData) {
      return sendError(res, 'QR data is required', 400);
    }

    try {
      const parsedData = JSON.parse(qrData);
      const now = new Date();

      // Check if QR code is still valid
      const validUntil = new Date(parsedData.validUntil);
      if (now > validUntil) {
        return sendError(res, 'QR code has expired', 400);
      }

      // Check if QR code has required fields
      if (!parsedData.type || !parsedData.sessionId || !parsedData.location) {
        return sendError(res, 'Invalid QR code format', 400);
      }

      // Check if QR code type is valid
      if (!['masuk', 'keluar'].includes(parsedData.type)) {
        return sendError(res, 'Invalid QR code type', 400);
      }

      // Check if location matches
      if (parsedData.location !== 'ICONNET_OFFICE') {
        return sendError(res, 'Invalid QR code location', 400);
      }

      sendSuccess(res, 'QR code is valid', {
        isValid: true,
        data: parsedData,
        type: parsedData.type,
        sessionId: parsedData.sessionId
      });
    } catch (parseError) {
      return sendError(res, 'Invalid QR code format', 400);
    }
  } catch (error) {
    console.error('Validate QR code error:', error);
    sendError(res, 'Failed to validate QR code', 500);
  }
};

export const resetSettings = async (req: Request, res: Response) => {
  try {
    // Delete all settings
    await prisma.settings.deleteMany();

    sendSuccess(res, 'Settings reset to defaults successfully', DEFAULT_SETTINGS);
  } catch (error) {
    console.error('Reset settings error:', error);
    sendError(res, 'Failed to reset settings', 500);
  }
};

export const getSettingsByCategory = async (req: Request, res: Response) => {
  try {
    const { category } = req.params;

    if (!category) {
      return sendError(res, 'Category is required', 400);
    }

    const settingsRecords = await prisma.settings.findMany({
      where: { category }
    });

    const settings: any = {};
    settingsRecords.forEach(record => {
      const keys = record.key.split('.');
      let current = settings;
      
      for (let i = 0; i < keys.length - 1; i++) {
        if (!current[keys[i]]) {
          current[keys[i]] = {};
        }
        current = current[keys[i]];
      }
      
      current[keys[keys.length - 1]] = record.value;
    });

    sendSuccess(res, `${category} settings retrieved successfully`, settings);
  } catch (error) {
    console.error('Get settings by category error:', error);
    sendError(res, 'Failed to retrieve settings', 500);
  }
};

export const exportSettings = async (req: Request, res: Response) => {
  try {
    const settingsRecords = await prisma.settings.findMany();
    
    const settings: any = { ...DEFAULT_SETTINGS };
    settingsRecords.forEach(record => {
      const keys = record.key.split('.');
      let current = settings;
      
      for (let i = 0; i < keys.length - 1; i++) {
        if (!current[keys[i]]) {
          current[keys[i]] = {};
        }
        current = current[keys[i]];
      }
      
      current[keys[keys.length - 1]] = record.value;
    });

    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', 'attachment; filename=settings-export.json');
    res.send(JSON.stringify(settings, null, 2));
  } catch (error) {
    console.error('Export settings error:', error);
    sendError(res, 'Failed to export settings', 500);
  }
};

export const importSettings = async (req: Request, res: Response) => {
  try {
    const settingsData = req.body;

    if (!settingsData || typeof settingsData !== 'object') {
      return sendError(res, 'Invalid settings data', 400);
    }

    // Clear existing settings
    await prisma.settings.deleteMany();

    // Flatten and import new settings
    const settingsToImport: Array<{ key: string; value: any; category: string }> = [];
    
    const flattenSettings = (obj: any, prefix: string = '', category: string = '') => {
      for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
          const fullKey = prefix ? `${prefix}.${key}` : key;
          const currentCategory = category || key;
          
          if (typeof obj[key] === 'object' && obj[key] !== null && !Array.isArray(obj[key])) {
            flattenSettings(obj[key], fullKey, currentCategory);
          } else {
            settingsToImport.push({
              key: fullKey,
              value: obj[key],
              category: currentCategory
            });
          }
        }
      }
    };

    flattenSettings(settingsData);

    // Create new settings
    const createPromises = settingsToImport.map(setting =>
      prisma.settings.create({
        data: {
          key: setting.key,
          value: setting.value,
          category: setting.category
        }
      })
    );

    await Promise.all(createPromises);

    sendSuccess(res, 'Settings imported successfully', settingsData);
  } catch (error) {
    console.error('Import settings error:', error);
    sendError(res, 'Failed to import settings', 500);
  }
};
