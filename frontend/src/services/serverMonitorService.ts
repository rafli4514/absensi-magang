import api from '../lib/api'; // Pastikan path import api ini benar
import type { ServerSpecs, ResourceUsage, CpuNetworkStatus } from "../types/server";

// Definisikan interface response agar TypeScript tidak error
interface ServerStatsResponse {
resources: ResourceUsage;
status: CpuNetworkStatus;
}

interface ApiResponse<T> {
success: boolean;
data: T;
message?: string;
}

class ServerMonitorService {

// Ambil Spesifikasi Server (Sekali saja saat load)
async getServerSpecs(): Promise<ServerSpecs> {
    try {
      // Sesuaikan URL dengan route backend Anda
      const response = await api.get<ApiResponse<ServerSpecs>>('/server/specs');
      return response.data.data;
    } catch (error) {
      console.error("Gagal mengambil specs server:", error);
      // Fallback data jika backend mati, supaya tidak blank
      return {
        hostname: "Disconnected",
        os: "-",
        cpuModel: "-",
        cpuCores: 0,
        totalRam: "0 GB",
        totalStorage: "0 GB",
        uptime: "-"
      };
    }
  }

  // Ambil Statistik Real-time (Polling)
  async getRealtimeStats(): Promise<{ resources: ResourceUsage; status: CpuNetworkStatus }> {
    try {
      const response = await api.get<ApiResponse<ServerStatsResponse>>('/server/stats');
      return response.data.data;
    } catch (error) {
      // Return data kosong/nol agar UI tidak crash
      return {
        resources: {
          memory: { used: 0, total: 0, percentage: 0 },
          swap: { used: 0, total: 0, percentage: 0 },
          storage: { used: 0, total: 0, percentage: 0 }
        },
        status: {
          cpuLoad: 0,
          loadAverage: [0, 0, 0],
          network: { received: "0 MB", sent: "0 MB" },
          diskIo: { read: "0", write: "0" }
        }
      };
    }
  }
}

export default new ServerMonitorService();