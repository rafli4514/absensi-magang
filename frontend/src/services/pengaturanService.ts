import api from '../lib/api';

export interface AttendanceSettings {
  allowLateCheckIn: boolean;
  lateThreshold: number;
  requireLocation: boolean;
  allowRemoteCheckIn: boolean;
}

export interface ScheduleSettings {
  workStartTime: string;
  workEndTime: string;
  breakStartTime: string;
  breakEndTime: string;
  workDays: string[];
}

export interface LocationSettings {
  officeAddress: string;
  latitude: number;
  longitude: number;
  radius: number;
  useRadius: boolean;
}

export interface SecuritySettings {
  faceVerification: boolean;
  ipWhitelist: boolean;
  sessionTimeout: number;
  allowedIps: string[];
}

export interface AppSettings {
  attendance: AttendanceSettings;
  schedule: ScheduleSettings;
  location: LocationSettings;
  security: SecuritySettings;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
}

class PengaturanService {
  /**
   * Get all settings
   */
  async getSettings(): Promise<ApiResponse<AppSettings>> {
    try {
      const response = await api.get<ApiResponse<AppSettings>>('/settings');
      return response.data;
    } catch (error: any) {
      // If settings don't exist, return default settings
      if (error.response?.status === 404) {
        return {
          success: true,
          message: 'Default settings loaded',
          data: this.getDefaultSettings()
        };
      }
      throw new Error(error.response?.data?.message || 'Failed to get settings');
    }
  }

  /**
   * Update settings
   */
  async updateSettings(settings: Partial<AppSettings>): Promise<ApiResponse<AppSettings>> {
    try {
      const response = await api.put<ApiResponse<AppSettings>>('/settings', settings);
      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to update settings');
    }
  }

  /**
   * Generate new QR code for check-in (masuk only)
   */
  async generateQRCode(): Promise<ApiResponse<{ qrCode: string; expiresAt: string; validityPeriod: number }>> {
    try {
      const response = await api.post<ApiResponse<{ qrCode: string; expiresAt: string; validityPeriod: number }>>('/settings/qr/generate', {}, {
        params: { type: 'masuk' }
      });
      return response.data;
    } catch (error: any) {
      throw new Error(error.response?.data?.message || 'Failed to generate QR code');
    }
  }

  /**
   * Get current location using browser geolocation API
   */
  async getCurrentLocation(): Promise<{ latitude: number; longitude: number }> {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation) {
        reject(new Error('Browser tidak mendukung geolocation. Gunakan browser modern seperti Chrome atau Firefox.'));
        return;
      }

      // Check if HTTPS or localhost
      const isSecure = location.protocol === 'https:' || location.hostname === 'localhost' || location.hostname === '127.0.0.1';
      if (!isSecure) {
        reject(new Error('Geolocation hanya bekerja di HTTPS. Akses melalui https:// atau localhost.'));
        return;
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          
          // Validate coordinates
          if (isNaN(latitude) || isNaN(longitude)) {
            reject(new Error('Koordinat tidak valid'));
            return;
          }
          
          resolve({ latitude, longitude });
        },
        (error) => {
          console.error('Geolocation error:', error);
          let message = 'Gagal mengambil lokasi';
          
          try {
            switch (error.code) {
              case 1: // PERMISSION_DENIED
                message = '❌ Akses lokasi ditolak. Klik ikon kunci di address bar dan izinkan akses lokasi.';
                break;
              case 2: // POSITION_UNAVAILABLE
                message = '📍 Lokasi tidak tersedia. Pastikan GPS aktif dan coba di luar ruangan.';
                break;
              case 3: // TIMEOUT
                message = '⏰ Timeout mengambil lokasi. Periksa koneksi internet dan coba lagi.';
                break;
              default:
                message = `🔧 Error geolocation (${error.code}): ${error.message || 'Unknown error'}`;
                break;
            }
          } catch (e) {
            message = '🔧 Error parsing geolocation error. Gunakan input manual.';
            console.error('Error parsing geolocation error:', e);
          }
          
          reject(new Error(message));
        },
        {
          enableHighAccuracy: false, // Change to false for better compatibility
          timeout: 15000, // Increase timeout to 15 seconds
          maximumAge: 60000 // Cache for 1 minute
        }
      );
    });
  }

  /**
   * Validate coordinates by checking if they're within reasonable bounds
   */
  validateCoordinates(latitude: number, longitude: number): { isValid: boolean; message: string } {
    if (latitude < -90 || latitude > 90) {
      return { isValid: false, message: 'Latitude harus diantara -90 dan 90' };
    }
    if (longitude < -180 || longitude > 180) {
      return { isValid: false, message: 'Longitude harus diantara -180 dan 180' };
    }
    return { isValid: true, message: 'Koordinat valid' };
  }

  /**
   * Test location settings by checking distance from office
   */
  async testLocation(
    officeLatitude: number,
    officeLongitude: number,
    radius: number
  ): Promise<ApiResponse<{ distance: number; isWithinRange: boolean }>> {
    try {
      const currentLocation = await this.getCurrentLocation();
      const distance = this.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        officeLatitude,
        officeLongitude
      );

      return {
        success: true,
        message: distance <= radius ? 'Test lokasi berhasil' : 'Test lokasi gagal - di luar radius',
        data: {
          distance: Math.round(distance),
          isWithinRange: distance <= radius
        }
      };
    } catch (error: any) {
      throw new Error(error.message || 'Failed to test location');
    }
  }

  /**
   * Calculate distance between two coordinates using Haversine formula
   */
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  /**
   * Search location using OpenStreetMap Nominatim API
   */
  async searchLocation(query: string): Promise<{ address: string; latitude: number; longitude: number }[]> {
    try {
      // Add timeout and better error handling
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout
      
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=5&countrycodes=id`, 
        {
          signal: controller.signal,
          headers: {
            'User-Agent': 'Absensi-App/1.0'
          }
        }
      );

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      if (!Array.isArray(data)) {
        throw new Error('Invalid response format');
      }

      return data
        .filter(item => item.lat && item.lon && item.display_name)
        .map(item => ({
          address: item.display_name,
          latitude: parseFloat(item.lat),
          longitude: parseFloat(item.lon)
        }))
        .filter(item => !isNaN(item.latitude) && !isNaN(item.longitude));
    } catch (error: any) {
      if (error.name === 'AbortError') {
        throw new Error('Pencarian lokasi timeout. Coba lagi.');
      }
      console.error('Search location error:', error);
      throw new Error('Gagal mencari lokasi. Periksa koneksi internet.');
    }
  }

  /**
   * Get default settings
   */
  private getDefaultSettings(): AppSettings {
    return {
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
  }

  /**
   * Get settings from localStorage (fallback)
   */
  getLocalSettings(): AppSettings {
    try {
      const settings = localStorage.getItem('appSettings');
      if (settings) {
        return { ...this.getDefaultSettings(), ...JSON.parse(settings) };
      }
    } catch (error) {
      console.error('Error parsing local settings:', error);
    }
    return this.getDefaultSettings();
  }

  /**
   * Save settings to localStorage (fallback)
   */
  saveLocalSettings(settings: AppSettings): void {
    try {
      localStorage.setItem('appSettings', JSON.stringify(settings));
    } catch (error) {
      console.error('Error saving local settings:', error);
    }
  }

  /**
   * Validate settings data
   */
  validateSettings(settings: Partial<AppSettings>): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Validate attendance settings
    if (settings.attendance) {
      if (settings.attendance.lateThreshold && (settings.attendance.lateThreshold < 0 || settings.attendance.lateThreshold > 120)) {
        errors.push('Late threshold must be between 0 and 120 minutes');
      }
    }

    // Validate schedule settings
    if (settings.schedule) {
      const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
      if (settings.schedule.workStartTime && !timeRegex.test(settings.schedule.workStartTime)) {
        errors.push('Work start time must be in HH:MM format');
      }
      if (settings.schedule.workEndTime && !timeRegex.test(settings.schedule.workEndTime)) {
        errors.push('Work end time must be in HH:MM format');
      }
      if (settings.schedule.breakStartTime && !timeRegex.test(settings.schedule.breakStartTime)) {
        errors.push('Break start time must be in HH:MM format');
      }
      if (settings.schedule.breakEndTime && !timeRegex.test(settings.schedule.breakEndTime)) {
        errors.push('Break end time must be in HH:MM format');
      }
    }

    // Validate location settings
    if (settings.location) {
      if (settings.location.latitude && (settings.location.latitude < -90 || settings.location.latitude > 90)) {
        errors.push('Latitude must be between -90 and 90');
      }
      if (settings.location.longitude && (settings.location.longitude < -180 || settings.location.longitude > 180)) {
        errors.push('Longitude must be between -180 and 180');
      }
      // Only validate radius if useRadius is enabled
      if (settings.location.useRadius && settings.location.radius && (settings.location.radius < 10 || settings.location.radius > 2000)) {
        errors.push('Location radius must be between 10 and 2000 meters when radius is enabled');
      }
    }

    // Validate security settings
    if (settings.security) {
      if (settings.security.sessionTimeout && (settings.security.sessionTimeout < 5 || settings.security.sessionTimeout > 480)) {
        errors.push('Session timeout must be between 5 and 480 minutes');
      }
      
      // Validate IP addresses
      if (settings.security.allowedIps) {
        const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
        for (const ip of settings.security.allowedIps) {
          if (!ipRegex.test(ip)) {
            errors.push(`Invalid IP address format: ${ip}`);
          }
        }
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

export default new PengaturanService();