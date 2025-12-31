import api from '../lib/api';
import type { Absensi } from '../types';

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface CreateAbsensiRequest {
  pesertaMagangId: string;
  tipe: string;
  timestamp?: string;
  lokasi?: {
    latitude: number;
    longitude: number;
    alamat: string;
  };
  selfieUrl?: string;
  qrCodeData?: string;
  status?: string;
  catatan?: string;
  ipAddress?: string;
  device?: string;
}

class AbsensiService {
  // PERBAIKAN 1: Menambahkan startDate & endDate agar LaporanPage tidak error
  async getAbsensi(params?: {
    page?: number;
    limit?: number;
    pesertaMagangId?: string;
    tipe?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
  }): Promise<PaginatedResponse<Absensi>> {
    const response = await api.get<PaginatedResponse<Absensi>>('/absensi', {
      params,
    });
    return response.data;
  }

  // Alias jika LaporanPage memanggil dengan nama getAllAbsensi
  async getAllAbsensi(params?: any) {
    return this.getAbsensi(params);
  }

  async getAbsensiById(id: string): Promise<ApiResponse<Absensi>> {
    const response = await api.get<ApiResponse<Absensi>>(`/absensi/${id}`);
    return response.data;
  }

  async createAbsensi(data: CreateAbsensiRequest): Promise<ApiResponse<Absensi>> {
    const response = await api.post<ApiResponse<Absensi>>('/absensi', data);
    return response.data;
  }

  async updateAbsensi(id: string, data: Partial<CreateAbsensiRequest>): Promise<ApiResponse<Absensi>> {
    const response = await api.put<ApiResponse<Absensi>>(`/absensi/${id}`, data);
    return response.data;
  }

  async deleteAbsensi(id: string): Promise<ApiResponse<void>> {
    const response = await api.delete<ApiResponse<void>>(`/absensi/${id}`);
    return response.data;
  }

  // Helper method untuk absensi masuk
  async absensiMasuk(pesertaMagangId: string, options?: {
    lokasi?: { latitude: number; longitude: number; alamat: string };
    selfieUrl?: string;
    qrCodeData?: string;
  }): Promise<ApiResponse<Absensi>> {
    return this.createAbsensi({
      pesertaMagangId,
      tipe: 'MASUK',
      timestamp: new Date().toISOString(),
      status: 'VALID',
      ...options,
    });
  }

  // Helper untuk get current user ID
  private getCurrentUserId(): string | null {
    try {
      const userStr = localStorage.getItem('user');
      if (userStr) {
        const user = JSON.parse(userStr);
        return user.id || null;
      }
    } catch (error) {
      console.error('Error getting current user ID:', error);
    }
    return null;
  }

  // Submit absensi dengan auto user ID
  async submitAbsensi(options: {
    tipe: 'MASUK' | 'KELUAR';
    lokasi?: { latitude: number; longitude: number; alamat: string };
    selfieUrl?: string;
    qrCodeData?: string;
  }): Promise<ApiResponse<Absensi>> {
    const userId = this.getCurrentUserId();
    if (!userId) {
      throw new Error('User tidak terautentikasi. Silakan login ulang.');
    }

    return this.createAbsensi({
      pesertaMagangId: userId,
      // PERBAIKAN 2: Menghapus 'tipe: options.tipe' karena sudah ada di ...options
      // Ini mencegah error "tipe is specified more than once"
      timestamp: new Date().toISOString(),
      status: 'VALID',
      ...options,
    });
  }

  // Helper method untuk absensi keluar
  async absensiKeluar(pesertaMagangId: string, options?: {
    lokasi?: { latitude: number; longitude: number; alamat: string };
    selfieUrl?: string;
    qrCodeData?: string;
  }): Promise<ApiResponse<Absensi>> {
    return this.createAbsensi({
      pesertaMagangId,
      tipe: 'KELUAR',
      timestamp: new Date().toISOString(),
      status: 'VALID',
      ...options,
    });
  }
}

export default new AbsensiService();