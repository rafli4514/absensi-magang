import api from '../lib/api';
import type { PengajuanIzin } from '../types';

export interface ApiResponse<T = unknown> {
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

export interface CreatePengajuanIzinRequest {
  pesertaMagangId: string;
  tipe: string;
  tanggalMulai: string;
  tanggalSelesai: string;
  alasan: string;
  dokumenPendukung?: string;
  // Field status ditambahkan agar bisa di-update
  status?: "PENDING" | "DISETUJUI" | "DITOLAK";
}

export interface PengajuanIzinStats {
  total: number;
  pending: number;
  disetujui: number;
  ditolak: number;
}

class PengajuanIzinService {
  async getAll(params?: {
    page?: number;
    limit?: number;
    status?: string;
    tipe?: string;
    pesertaMagangId?: string;
  }): Promise<PaginatedResponse<PengajuanIzin>> {
    const response = await api.get<PaginatedResponse<PengajuanIzin>>('/pengajuan-izin', {
      params,
    });
    return response.data;
  }

  async getById(id: string): Promise<ApiResponse<PengajuanIzin>> {
    const response = await api.get<ApiResponse<PengajuanIzin>>(`/pengajuan-izin/${id}`);
    return response.data;
  }

  async create(data: CreatePengajuanIzinRequest): Promise<ApiResponse<PengajuanIzin>> {
    const response = await api.post<ApiResponse<PengajuanIzin>>('/pengajuan-izin', data);
    return response.data;
  }

  async update(id: string, data: Partial<CreatePengajuanIzinRequest>): Promise<ApiResponse<PengajuanIzin>> {
    const response = await api.put<ApiResponse<PengajuanIzin>>(`/pengajuan-izin/${id}`, data);
    return response.data;
  }

  async delete(id: string): Promise<ApiResponse<void>> {
    const response = await api.delete<ApiResponse<void>>(`/pengajuan-izin/${id}`);
    return response.data;
  }

  async approve(id: string, catatan?: string): Promise<ApiResponse<PengajuanIzin>> {
    const response = await api.patch<ApiResponse<PengajuanIzin>>(`/pengajuan-izin/${id}/approve`, {
      catatan,
    });
    return response.data;
  }

  async reject(id: string, catatan?: string): Promise<ApiResponse<PengajuanIzin>> {
    const response = await api.patch<ApiResponse<PengajuanIzin>>(`/pengajuan-izin/${id}/reject`, {
      catatan,
    });
    return response.data;
  }

  async getStatistics(): Promise<ApiResponse<PengajuanIzinStats>> {
    const response = await api.get<ApiResponse<PengajuanIzinStats>>('/pengajuan-izin/statistics');
    return response.data;
  }
}

export default new PengajuanIzinService();