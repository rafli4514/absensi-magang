import { type Request, type Response } from 'express';
import { prisma } from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response';
import QRCode from 'qrcode';
import crypto from 'crypto';

interface AppSettings {
  qr: {
    autoGenerate: boolean;
    validityPeriod: number;
    size: 'small' | 'medium' | 'large';
  };
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
  };
}

// Default settings
const DEFAULT_SETTINGS: AppSettings = {
  qr: {
    autoGenerate: true,
    validityPeriod: 5,
    size: 'medium'
  },
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
    sessionTimeout: 60
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
