import { useState } from "react";
import { Download, Calendar, FileText, BarChart3 } from "lucide-react";

export default function Laporan() {
  const [selectedPeriod, setSelectedPeriod] = useState("month");
  const [selectedFormat, setSelectedFormat] = useState("excel");

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Laporan Absensi</h1>
        <p className="text-gray-600">
          Generate dan export laporan kehadiran siswa
        </p>
      </div>

      {/* Report filters */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Filter Laporan
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Periode
            </label>
            <select
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
              className="input-field"
            >
              <option value="week">Minggu ini</option>
              <option value="month">Bulan ini</option>
              <option value="quarter">Kuartal ini</option>
              <option value="year">Tahun ini</option>
              <option value="custom">Periode Kustom</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Format Export
            </label>
            <select
              value={selectedFormat}
              onChange={(e) => setSelectedFormat(e.target.value)}
              className="input-field"
            >
              <option value="excel">Excel (.xlsx)</option>
              <option value="pdf">PDF</option>
              <option value="csv">CSV</option>
            </select>
          </div>
          <div className="flex items-end">
            <button className="btn-primary w-full flex items-center justify-center">
              <Download className="h-4 w-4 mr-2" />
              Generate Laporan
            </button>
          </div>
        </div>
      </div>

      {/* Report templates */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="card">
          <div className="flex items-center mb-4">
            <div className="p-3 bg-primary-100 rounded-lg">
              <FileText className="h-6 w-6 text-primary-600" />
            </div>
            <div className="ml-4">
              <h3 className="text-lg font-semibold text-gray-900">
                Laporan Harian
              </h3>
              <p className="text-sm text-gray-600">Kehadiran per hari</p>
            </div>
          </div>
          <button className="btn-secondary w-full">
            Generate Laporan Harian
          </button>
        </div>

        <div className="card">
          <div className="flex items-center mb-4">
            <div className="p-3 bg-success-100 rounded-lg">
              <BarChart3 className="h-6 w-6 text-success-600" />
            </div>
            <div className="ml-4">
              <h3 className="text-lg font-semibold text-gray-900">
                Laporan Bulanan
              </h3>
              <p className="text-sm text-gray-600">
                Statistik kehadiran bulanan
              </p>
            </div>
          </div>
          <button className="btn-secondary w-full">
            Generate Laporan Bulanan
          </button>
        </div>

        <div className="card">
          <div className="flex items-center mb-4">
            <div className="p-3 bg-warning-100 rounded-lg">
              <Calendar className="h-6 w-6 text-warning-600" />
            </div>
            <div className="ml-4">
              <h3 className="text-lg font-semibold text-gray-900">
                Laporan Periode
              </h3>
              <p className="text-sm text-gray-600">
                Kehadiran periode tertentu
              </p>
            </div>
          </div>
          <button className="btn-secondary w-full">
            Generate Laporan Periode
          </button>
        </div>
      </div>

      {/* Recent reports */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Laporan Terbaru
        </h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Nama Laporan
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Periode
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Format
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Dibuat
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Aksi
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              <tr>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  Laporan Absensi Januari 2024
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                  1 Jan - 31 Jan 2024
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-success-100 text-success-800">
                    Excel
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                  1 Feb 2024, 10:30
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button className="text-primary-600 hover:text-primary-900">
                    Download
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
