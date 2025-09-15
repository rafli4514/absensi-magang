import api from '../lib/api';
import type { DashboardStats, LaporanAbsensi } from '../types';

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
}

class DashboardService {
  async getStats(): Promise<ApiResponse<DashboardStats>> {
    const response = await api.get<ApiResponse<DashboardStats>>('/dashboard/stats');
    return response.data;
  }

  async getAttendanceReport(params?: {
    startDate?: string;
    endDate?: string;
    pesertaMagangId?: string;
  }): Promise<ApiResponse<LaporanAbsensi[]>> {
    const response = await api.get<ApiResponse<LaporanAbsensi[]>>('/dashboard/attendance-report', {
      params,
    });
    return response.data;
  }

  async getMonthlyStats(params?: {
    year?: number;
    month?: number;
  }): Promise<ApiResponse<any>> {
    const response = await api.get<ApiResponse<any>>('/dashboard/monthly-stats', {
      params,
    });
    return response.data;
  }
}

export default new DashboardService();
