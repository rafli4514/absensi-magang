import {
  Users,
  Clock,
  CheckCircle,
  XCircle,
  TrendingUp,
  Calendar,
  AlertCircle,
} from "lucide-react";
import type { DashboardStats } from "../types";

// Mock data - replace with actual API calls
const mockStats: DashboardStats = {
  totalPesertaMagang: 25,
  pesertaMagangAktif: 23,
  AbsensiMasukHariIni: 20,
  AbsensiKeluarHariIni: 3,
  tingkatKehadiran: 87.5,
  aktivitasBaruBaruIni: [
    {
      id: "1",
      pesertaMagangId: "1",
      pesertaMagang: {
        id: "1",
        nama: "Mamad Supratman",
        username: "Mamad",
        divisi: "IT",
        universitas: "Universitas Apa Coba",
        nomorHp: "08123456789",
        TanggalMulai: "2025-09-04",
        TanggalSelesai: "2026-01-04",
        status: "Aktif",
        createdAt: "2025-08-01",
        updatedAt: "2025-08-01",
      },
      tipe: "Masuk",
      timestamp: new Date().toISOString(),
      lokasi: {
        latitude: -6.2088,
        longitude: 106.8456,
        alamat: "Jakarta, Indonesia",
      },
      selfieUrl: "/api/selfies/1.jpg",
      qrCodeData: "QR123",
      status: "valid",
      createdAt: new Date().toISOString(),
    },
  ],
};

const StatCard = ({
  title,
  value,
  icon: Icon,
  color,
  change,
}: {
  title: string;
  value: string | number;
  icon: React.ComponentType<{ className?: string }>;
  color: string;
  change?: string;
}) => (
  <div className="card">
    <div className="flex items-center">
      <div className={`p-3 rounded-lg ${color}`}>
        <Icon className="h-6 w-6 text-white" />
      </div>
      <div className="ml-4">
        <p className="text-sm font-medium text-gray-600">{title}</p>
        <p className="text-2xl font-bold text-gray-900">{value}</p>
        {change && (
          <p className="text-sm text-green-600 flex items-center">
            <TrendingUp className="h-4 w-4 mr-1" />
            {change}
          </p>
        )}
      </div>
    </div>
  </div>
);

export default function Dashboard() {
  const stats = mockStats;

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600">
          Selamat datang di sistem absensi Iconnet
        </p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Peserta Magang"
          value={stats.totalPesertaMagang}
          icon={Users}
          color="bg-primary-500"
        />
        <StatCard
          title="Peserta Magang Aktif"
          value={stats.pesertaMagangAktif}
          icon={CheckCircle}
          color="bg-success-500"
        />
        <StatCard
          title="Hadir Hari Ini"
          value={stats.AbsensiMasukHariIni}
          icon={Clock}
          color="bg-warning-500"
        />
        <StatCard
          title="Tidak Hadir"
          value={stats.AbsensiKeluarHariIni}
          icon={XCircle}
          color="bg-danger-500"
        />
      </div>

      {/* Attendance rate */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Tingkat Kehadiran Hari Ini
        </h3>
        <div className="flex items-center">
          <div className="flex-1">
            <div className="flex items-center justify-between text-sm text-gray-600 mb-2">
              <span>Kehadiran</span>
              <span>{stats.tingkatKehadiran}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-primary-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${stats.tingkatKehadiran}%` }}
              />
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent activities */}
        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Aktivitas Terbaru
          </h3>
          <div className="space-y-4">
            {stats.aktivitasBaruBaruIni.map((activity) => (
              <div key={activity.id} className="flex items-center space-x-3">
                <div
                  className={`p-2 rounded-full ${
                    activity.status === "valid"
                      ? "bg-success-100"
                      : activity.status === "late"
                      ? "bg-warning-100"
                      : "bg-danger-100"
                  }`}
                >
                  {activity.status === "valid" ? (
                    <CheckCircle className="h-4 w-4 text-success-600" />
                  ) : activity.status === "late" ? (
                    <AlertCircle className="h-4 w-4 text-warning-600" />
                  ) : (
                    <XCircle className="h-4 w-4 text-danger-600" />
                  )}
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-900">
                    {activity.pesertaMagang.nama}
                  </p>
                  <p className="text-sm text-gray-600">
                    {activity.tipe === "Masuk" ? "Masuk" : "Pulang"} -{" "}
                    {new Date(activity.timestamp).toLocaleTimeString("id-ID")}
                  </p>
                </div>
                <span
                  className={`text-xs px-2 py-1 rounded-full ${
                    activity.status === "valid"
                      ? "bg-success-100 text-success-800"
                      : activity.status === "late"
                      ? "bg-warning-100 text-warning-800"
                      : "bg-danger-100 text-danger-800"
                  }`}
                >
                  {activity.status === "valid"
                    ? "Tepat waktu"
                    : activity.status === "late"
                    ? "Terlambat"
                    : "Tidak valid"}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Quick actions */}
        <div className="card">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Aksi Cepat
          </h3>
          <div className="space-y-3">
            <button className="w-full btn-primary text-left">
              <Users className="inline h-4 w-4 mr-2" />
              Tambah Siswa Baru
            </button>
            <button className="w-full btn-secondary text-left">
              <Calendar className="inline h-4 w-4 mr-2" />
              Atur Jadwal Kerja
            </button>
            <button className="w-full btn-secondary text-left">
              <Clock className="inline h-4 w-4 mr-2" />
              Lihat Laporan Absensi
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
