import api from '../lib/api';
import type { PesertaMagang } from '../types';

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

export interface CreatePesertaMagangRequest {
  nama: string;
  username: string;
  divisi: string;
  universitas: string;
  nomorHp: string;
  tanggalMulai: string;
  tanggalSelesai: string;
  status?: string;
  avatar?: string;
}

class PesertaMagangService {
  async getPesertaMagang(params?: {
    page?: number;
    limit?: number;
    status?: string;
  }): Promise<PaginatedResponse<PesertaMagang>> {
    const response = await api.get<PaginatedResponse<PesertaMagang>>('/peserta-magang', {
      params,
    });
    return response.data;
  }

  async getPesertaMagangById(id: string): Promise<ApiResponse<PesertaMagang>> {
    const response = await api.get<ApiResponse<PesertaMagang>>(`/peserta-magang/${id}`);
    return response.data;
  }

  async createPesertaMagang(data: CreatePesertaMagangRequest): Promise<ApiResponse<PesertaMagang>> {
    const response = await api.post<ApiResponse<PesertaMagang>>('/peserta-magang', data);
    return response.data;
  }

  async updatePesertaMagang(id: string, data: Partial<CreatePesertaMagangRequest>): Promise<ApiResponse<PesertaMagang>> {
    const response = await api.put<ApiResponse<PesertaMagang>>(`/peserta-magang/${id}`, data);
    return response.data;
  }

  async deletePesertaMagang(id: string): Promise<ApiResponse<void>> {
    const response = await api.delete<ApiResponse<void>>(`/peserta-magang/${id}`);
    return response.data;
  }
}

export default new PesertaMagangService();
