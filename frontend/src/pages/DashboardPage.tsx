
// UI Components
import {
  Card,
  Flex,
  Grid,
  Text,
  Progress,
} from "@radix-ui/themes";

// Icons
import {
  Users,
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle,
  BarChart3,
} from "lucide-react";

// Types
import type { DashboardStats, Absensi } from "../types";

// =====================================
// Mock Data - Replace with API calls
// =====================================

const mockStats: DashboardStats = {
  totalPesertaMagang: 25,
  pesertaMagangAktif: 23,
  absensiMasukHariIni: 20,
  absensiKeluarHariIni: 3,
  tingkatKehadiran: 87.5,
  aktivitasBaruBaruIni: [
    {
      id: "1",
      pesertaMagangId: "1",
      pesertaMagang: {
        id: "1",
        nama: "Ahmad Rizki Pratama",
        username: "ahmad",
        divisi: "IT",
        universitas: "Universitas Indonesia",
        nomorHp: "08123456789",
        tanggalMulai: "2024-01-01",
        tanggalSelesai: "2024-06-30",
        status: "Aktif",
        createdAt: "2024-01-01",
        updatedAt: "2024-01-01",
      },
      tipe: "Masuk",
      timestamp: new Date().toISOString(),
      lokasi: {
        latitude: -6.2088,
        longitude: 106.8456,
        alamat: "Jakarta, Indonesia",
      },
      selfieUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      qrCodeData: "QR123",
      status: "valid",
      createdAt: new Date().toISOString(),
    },
    {
      id: "2",
      pesertaMagangId: "2",
      pesertaMagang: {
        id: "2",
        nama: "Siti Nurhaliza",
        username: "siti",
        divisi: "HR",
        universitas: "Universitas Gadjah Mada",
        nomorHp: "08198765432",
        tanggalMulai: "2024-01-01",
        tanggalSelesai: "2024-06-30",
        status: "Aktif",
        createdAt: "2024-01-01",
        updatedAt: "2024-01-01",
      },
      tipe: "Masuk",
      timestamp: new Date().toISOString(),
      qrCodeData: "QR456",
      status: "Terlambat",
      createdAt: new Date().toISOString(),
    },
    {
      id: "3",
      pesertaMagangId: "3",
      pesertaMagang: {
        id: "3",
        nama: "Budi Santoso",
        username: "budi",
        divisi: "Finance",
        universitas: "Institut Teknologi Bandung",
        nomorHp: "08134567890",
        tanggalMulai: "2024-01-01",
        tanggalSelesai: "2024-06-30",
        status: "Aktif",
        createdAt: "2024-01-01",
        updatedAt: "2024-01-01",
      },
      tipe: "Izin",
      timestamp: new Date().toISOString(),
      qrCodeData: "QR789",
      status: "valid",
      createdAt: new Date().toISOString(),
    },
  ],
};

// =====================================
// Helper Components
// =====================================

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig = {
    valid: { color: "bg-green-100 text-green-800", label: "Tepat Waktu" },
    Terlambat: { color: "bg-yellow-100 text-yellow-800", label: "Terlambat" },
    invalid: { color: "bg-red-100 text-red-800", label: "Tidak Valid" },
  };

  const config = statusConfig[status];

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

const TypeBadge = ({ tipe }: { tipe: Absensi["tipe"] }) => {
  const typeConfig = {
    Masuk: { color: "bg-blue-100 text-blue-800", label: "Masuk" },
    Keluar: { color: "bg-purple-100 text-purple-800", label: "Keluar" },
    Izin: { color: "bg-orange-100 text-orange-800", label: "Izin" },
    Sakit: { color: "bg-red-100 text-red-800", label: "Sakit" },
    Cuti: { color: "bg-green-100 text-green-800", label: "Cuti" },
  };

  const config = typeConfig[tipe] || { color: "bg-gray-100 text-gray-800", label: tipe };

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

// =====================================
// Custom Hooks
// =====================================

const useDashboardData = () => {
  // TODO: Replace with actual API calls
  return { stats: mockStats };
};

// =====================================
// Main Component
// =====================================

export default function DashboardPage() {
  // ============ Data ============
  const { stats } = useDashboardData();

  // ============ Render ============
  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600">
            Selamat datang di sistem absensi Iconnet
          </p>
        </div>
        <Text size="2" color="gray">
          {new Date().toLocaleDateString('id-ID', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          })}
        </Text>
      </div>

      {/* Statistics Cards */}
      <Grid columns={{ initial: "1", md: "2", lg: "4" }} gap="4">
        <Card className="p-6">
          <Flex direction="column" gap="3">
            <div className="p-3 bg-blue-100 rounded-lg w-fit">
              <Users className="h-6 w-6 text-blue-600" />
            </div>
            <Flex gap="2" justify="start" align="center">
              <Text size="5" weight="bold" className="text-gray-900">
                {stats.totalPesertaMagang}
              </Text>
              <Text size="2" color="gray">
                Total Peserta Magang
              </Text>
            </Flex>
          </Flex>
        </Card>

        <Card className="p-6">
          <Flex direction="column" gap="3">
            <div className="p-3 bg-green-100 rounded-lg w-fit">
              <CheckCircle className="h-6 w-6 text-green-600" />
            </div>
            <Flex gap="2" justify="start" align="center">
              <Text size="5" weight="bold" className="text-gray-900">
                {stats.pesertaMagangAktif}
              </Text>
              <Text size="2" color="gray">
                Peserta Aktif
              </Text>
            </Flex>
          </Flex>
        </Card>

        <Card className="p-6">
          <Flex direction="column" gap="3">
            <div className="p-3 bg-orange-100 rounded-lg w-fit">
              <Clock className="h-6 w-6 text-orange-600" />
            </div>
            <Flex gap="2" justify="start" align="center">
              <Text size="5" weight="bold" className="text-gray-900">
                {stats.absensiMasukHariIni}
              </Text>
              <Text size="2" color="gray">
                Hadir Hari Ini
              </Text>
            </Flex>
          </Flex>
        </Card>

        <Card className="p-6">
          <Flex direction="column" gap="3">
            <div className="p-3 bg-red-100 rounded-lg w-fit">
              <XCircle className="h-6 w-6 text-red-600" />
            </div>
            <Flex gap="2" justify="start" align="center">
              <Text size="5" weight="bold" className="text-gray-900">
                {stats.absensiKeluarHariIni}
              </Text>
              <Text size="2" color="gray">
                Belum Absen
              </Text>
            </Flex>
          </Flex>
        </Card>
      </Grid>

      {/* Attendance Rate Chart */}
      <Card className="p-6">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="3">
            <div className="p-3 bg-purple-100 rounded-lg">
              <BarChart3 className="h-6 w-6 text-purple-600" />
            </div>
            <Text size="4" weight="bold">
              Tingkat Kehadiran Hari Ini
            </Text>
          </Flex>

          <div>
            <Flex justify="between" mb="2">
              <Text size="2" color="gray">Kehadiran</Text>
              <Text size="3" weight="bold">{stats.tingkatKehadiran}%</Text>
            </Flex>
            <Progress value={stats.tingkatKehadiran} className="h-3" />
          </div>

          <Flex gap="4" wrap="wrap">
            <Flex align="center" gap="2">
              <div className="w-3 h-3 bg-green-500 rounded-full"></div>
              <Text size="2" color="gray">Tepat waktu: {Math.round(stats.tingkatKehadiran * 0.8)}%</Text>
            </Flex>
            <Flex align="center" gap="2">
              <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
              <Text size="2" color="gray">Terlambat: {Math.round(stats.tingkatKehadiran * 0.15)}%</Text>
            </Flex>
            <Flex align="center" gap="2">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>
              <Text size="2" color="gray">Tidak hadir: {Math.round(100 - stats.tingkatKehadiran)}%</Text>
            </Flex>
          </Flex>
        </Flex>
      </Card>

      {/* Dashboard Sections */}
      <Grid columns={{ initial: "1" }} gap="4">
      {/* Recent Activities */}
      <Card className="p-6">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="3">
            <div className="p-3 bg-blue-100 rounded-lg">
              <Clock className="h-6 w-6 text-blue-600" />
            </div>
            <Text size="4" weight="bold">
              Aktivitas Terbaru
            </Text>
          </Flex>

          <Flex direction="column" gap="3">
            {stats.aktivitasBaruBaruIni.map((activity) => (
              <Flex key={activity.id} align="center" gap="4" className="p-4 bg-gray-50 rounded-lg">
                <div className={`p-2 rounded-lg ${
                  activity.status === "valid"
                    ? "bg-green-100"
                    : activity.status === "Terlambat"
                    ? "bg-yellow-100"
                    : "bg-red-100"
                }`}>
                  {activity.status === "valid" ? (
                    <CheckCircle className="h-4 w-4 text-green-600" />
                  ) : activity.status === "Terlambat" ? (
                    <AlertCircle className="h-4 w-4 text-yellow-600" />
                  ) : (
                    <XCircle className="h-4 w-4 text-red-600" />
                  )}
                </div>

                <Flex direction="column" flexGrow="1" gap="1">
                  <Text size="3" weight="bold">
                    {activity.pesertaMagang?.nama}
                  </Text>
                  <Flex align="center" gap="2">
                    <TypeBadge tipe={activity.tipe} />
                    <Text size="1" color="gray">
                      • {new Date(activity.timestamp).toLocaleTimeString("id-ID")}
                    </Text>
                  </Flex>
                </Flex>

                <StatusBadge status={activity.status} />
              </Flex>
            ))}
          </Flex>
        </Flex>
      </Card>

      </Grid>
    </div>
  );
}
