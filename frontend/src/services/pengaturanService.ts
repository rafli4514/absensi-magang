import api from '../lib/api';

export interface QRSettings {
  autoGenerate: boolean;
  validityPeriod: number;
  size: 'small' | 'medium' | 'large';
}

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
}

export interface SecuritySettings {
  faceVerification: boolean;
  ipWhitelist: boolean;
  sessionTimeout: number;
}

export interface AppSettings {
  qr: QRSettings;
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
   * Generate new QR code
   */
  async generateQRCode(): Promise<ApiResponse<{ qrCode: string; expiresAt: string }>> {
    try {
      const response = await api.post<ApiResponse<{ qrCode: string; expiresAt: string }>>('/settings/qr/generate');
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
        reject(new Error('Geolocation is not supported by this browser'));
        return;
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude
          });
        },
        (error) => {
          let message = 'Failed to get location';
          switch (error.code) {
            case error.PERMISSION_DENIED:
              message = 'Location access denied by user';
              break;
            case error.POSITION_UNAVAILABLE:
              message = 'Location information unavailable';
              break;
            case error.TIMEOUT:
              message = 'Location request timed out';
              break;
          }
          reject(new Error(message));
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 0
        }
      );
    });
  }

  /**
   * Validate coordinates by checking if they're within reasonable bounds
   */
  validateCoordinates(latitude: number, longitude: number): { isValid: boolean; message: string } {
    if (latitude < -90 || latitude > 90) {
      return { isValid: false, message: 'Latitude must be between -90 and 90' };
    }
    if (longitude < -180 || longitude > 180) {
      return { isValid: false, message: 'Longitude must be between -180 and 180' };
    }
    return { isValid: true, message: 'Coordinates are valid' };
  }

  /**
   * Test location settings by checking distance from office
   */
  async testLocation(officeLatitude: number, officeLongitude: number, radius: number): Promise<ApiResponse<{ distance: number; isWithinRange: boolean }>> {
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
        message: distance <= radius ? 'Location test successful' : 'Location test failed - outside radius',
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
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c;
  }

  /**
   * Search location using OpenStreetMap Nominatim API
   */
  async searchLocation(query: string): Promise<{ address: string; latitude: number; longitude: number }[]> {
    try {
      const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=5`);
      const data = await response.json();
      
      return data.map((item: any) => ({
        address: item.display_name,
        latitude: parseFloat(item.lat),
        longitude: parseFloat(item.lon)
      }));
    } catch (error) {
      throw new Error('Failed to search location');
    }
  }

  /**
   * Get default settings
   */
  private getDefaultSettings(): AppSettings {
    return {
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
        officeAddress: '',
        latitude: -6.2088,
        longitude: 106.8456,
        radius: 100
      },
      security: {
        faceVerification: true,
        ipWhitelist: false,
        sessionTimeout: 60
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
}

export default new PengaturanService();
