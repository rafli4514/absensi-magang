import { useState } from "react";
import {
  Search,
  Eye,
  Download,
  Clock,
  MapPin,
  Camera,
  CheckCircle,
  XCircle,
  AlertCircle,
} from "lucide-react";
import type { Absensi } from "../types";
import { formatDateTime } from "../lib/utils";

// Mock data - replace with actual API calls
const mockAbsensi: Absensi[] = [
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
];

const StatusIcon = ({ status }: { status: Absensi["status"] }) => {
  switch (status) {
    case "valid":
      return <CheckCircle className="h-5 w-5 text-success-600" />;
    case "late":
      return <AlertCircle className="h-5 w-5 text-warning-600" />;
    case "invalid":
      return <XCircle className="h-5 w-5 text-danger-600" />;
    default:
      return <Clock className="h-5 w-5 text-gray-600" />;
  }
};

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig = {
    valid: { color: "bg-success-100 text-success-800", label: "Valid" },
    late: { color: "bg-warning-100 text-warning-800", label: "Terlambat" },
    invalid: { color: "bg-danger-100 text-danger-800", label: "Tidak Valid" },
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

export default function AbsensiPage() {
  const [Absensi] = useState<Absensi[]>(mockAbsensi);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [typeFilter, setTypeFilter] = useState<string>("all");
  const [dateFilter, setDateFilter] = useState("");

  const filteredAbsensi = Absensi.filter((record) => {
    const matchesSearch =
      record.pesertaMagang.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      record.pesertaMagang.username.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "all" || record.status === statusFilter;
    const matchesType = typeFilter === "all" || record.tipe === typeFilter;

    const matchesDate =
      !dateFilter ||
      new Date(record.timestamp).toDateString() ===
        new Date(dateFilter).toDateString();

    return matchesSearch && matchesStatus && matchesType && matchesDate;
  });

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Monitoring Absensi
          </h1>
          <p className="text-gray-600">
            Pantau kehadiran siswa secara real-time
          </p>
        </div>
        <button className="btn-primary flex items-center">
          <Download className="h-4 w-4 mr-2" />
          Export Data
        </button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <div>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Cari siswa..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input-field pl-10"
              />
            </div>
          </div>
          <div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="input-field"
            >
              <option value="all">Semua Status</option>
              <option value="valid">Valid</option>
              <option value="late">Terlambat</option>
              <option value="invalid">Tidak Valid</option>
            </select>
          </div>
          <div>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="input-field"
            >
              <option value="all">Semua Tipe</option>
              <option value="checkin">Masuk</option>
              <option value="checkout">Pulang</option>
            </select>
          </div>
          <div>
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="input-field"
            />
          </div>
        </div>
      </div>

      {/* Absensi records */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Siswa
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipe
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Waktu
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Lokasi
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Verifikasi
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredAbsensi.map((record) => (
                <tr key={record.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="h-10 w-10 flex-shrink-0">
                        <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center">
                          <span className="text-sm font-medium text-primary-600">
                            {record.pesertaMagang.nama
                              .split(" ")
                              .map((n) => n[0])
                              .join("")}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {record.pesertaMagang.nama}
                        </div>
                        <div className="text-sm text-gray-500">
                          {record.pesertaMagang.username}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                        record.tipe === "Masuk"
                          ? "bg-primary-100 text-primary-800"
                          : "bg-gray-100 text-gray-800"
                      }`}
                    >
                      {record.tipe === "Masuk" ? "Masuk" : "Pulang"}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {formatDateTime(record.timestamp)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center text-sm text-gray-600">
                      <MapPin className="h-4 w-4 mr-1" />
                      {record.lokasi?.alamat || "Tidak tersedia"}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <StatusIcon status={record.status} />
                      <StatusBadge status={record.status} />
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center space-x-2">
                      {record.selfieUrl && (
                        <button className="text-primary-600 hover:text-primary-900">
                          <Camera className="h-4 w-4" />
                        </button>
                      )}
                      <button className="text-gray-600 hover:text-gray-900">
                        <Eye className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredAbsensi.length === 0 && (
          <div className="text-center py-8">
            <p className="text-gray-500">
              Tidak ada data absensi yang ditemukan
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
