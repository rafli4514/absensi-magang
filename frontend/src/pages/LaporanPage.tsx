import { useState, useEffect } from "react";
import { Download, ChevronDown } from "lucide-react";
import type { LaporanAbsensi, PesertaMagang } from "../types";
import {
  Box,
  Button,
  Card,
  DropdownMenu,
  Flex,
  Grid,
  Select,
  Table,
  Text,
  TextField,
} from "@radix-ui/themes";
import {
  CalendarIcon,
  ClockIcon,
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";

// Import services
import dashboardService from "../services/dashboardService";
import pesertaMagangService from "../services/pesertaMagangService";
import absensiService from "../services/absensiService";
import Avatar from "../components/Avatar";
import type { Absensi } from "../types";

const getAttendanceRateBadge = (rate: number) => {
  if (rate >= 95) {
    return (
      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800">
        Sangat Baik
      </span>
    );
  } else if (rate >= 85) {
    return (
      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-800">
        Baik
      </span>
    );
  } else {
    return (
      <span className="inline-flex px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-800">
        Perlu Diperhatikan
      </span>
    );
  }
};

export default function LaporanPage() {
  const [attendanceReports, setAttendanceReports] = useState<LaporanAbsensi[]>(
    []
  );
  const [pesertaMagangData, setPesertaMagangData] = useState<PesertaMagang[]>(
    []
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [dateRange, setDateRange] = useState({
    startDate: "",
    endDate: "",
  });
  const [selectedPesertaId, setSelectedPesertaId] = useState<string>("");

  // Fetch data on component mount
  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch attendance report and peserta magang data in parallel
      const [attendanceResponse, pesertaResponse] = await Promise.all([
        dashboardService.getAttendanceReport({
          startDate: dateRange.startDate || undefined,
          endDate: dateRange.endDate || undefined,
        }),
        pesertaMagangService.getPesertaMagang(),
      ]);

      if (attendanceResponse.success && attendanceResponse.data) {
        setAttendanceReports(attendanceResponse.data);
      }

      if (pesertaResponse.success && pesertaResponse.data) {
        setPesertaMagangData(pesertaResponse.data);
      }
    } catch (error: unknown) {
      console.error("Fetch laporan data error:", error);
      setError("Failed to fetch laporan data");
    } finally {
      setLoading(false);
    }
  };

  const handleDateRangeChange = () => {
    fetchData();
  };

  // Combine attendance reports with peserta magang data for filtering
  const combinedData = attendanceReports.map((report) => {
    const peserta = pesertaMagangData.find(
      (p) => p.id === report.pesertaMagangId
    );
    return {
      ...report,
      pesertaMagang: peserta,
    };
  });

  const filteredData = combinedData.filter((report) => {
    const matchesSearch =
      report.pesertaMagangName
        .toLowerCase()
        .includes(searchTerm.toLowerCase()) ||
      report.pesertaMagang?.divisi
        .toLowerCase()
        .includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || report.pesertaMagang?.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  // Statistics for reports
  const stats = {
    total: attendanceReports.length,
    sangatBaik: attendanceReports.filter((r) => r.tingkatKehadiran >= 95)
      .length,
    baik: attendanceReports.filter(
      (r) => r.tingkatKehadiran >= 85 && r.tingkatKehadiran < 95
    ).length,
    perluDiperhatikan: attendanceReports.filter((r) => r.tingkatKehadiran < 85)
      .length,
  };

  const startDate = dateRange.startDate
    ? new Date(dateRange.startDate).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
      })
    : "Semua";

  const endDate = dateRange.endDate
    ? new Date(dateRange.endDate).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
      })
    : "Semua";

  const handleExportDetail = async (format: "excel" | "pdf" | "csv") => {
    if (!selectedPesertaId) {
      alert("Silakan pilih peserta terlebih dahulu.");
      return;
    }

    return handleExportDetailForPeserta(selectedPesertaId, format);
  };

  const handleExportDetailForPeserta = async (
    pesertaId: string,
    format: "excel" | "pdf" | "csv"
  ) => {
    try {
      // Fetch detail absensi untuk peserta yang dipilih
      const response = await absensiService.getAbsensi({
        pesertaMagangId: pesertaId,
        limit: 1000, // Get all records
      });

      if (!response.success || !response.data || response.data.length === 0) {
        alert("Tidak ada data absensi untuk peserta ini pada periode yang dipilih.");
        return;
      }

      const absensiData = response.data;
      const selectedPeserta = pesertaMagangData.find(p => p.id === pesertaId);

      // Jika tanggal kosong, export semua data absensi peserta.
      // Jika tanggal diisi lengkap (start & end), filter sesuai range.
      let filteredAbsensi = absensiData;
      if (dateRange.startDate && dateRange.endDate) {
        const startDateFilter = new Date(dateRange.startDate);
        const endDateFilter = new Date(dateRange.endDate);
        endDateFilter.setHours(23, 59, 59, 999);

        filteredAbsensi = absensiData.filter((abs) => {
          const absDate = new Date(abs.timestamp);
          return absDate >= startDateFilter && absDate <= endDateFilter;
        });
      }

      filteredAbsensi = filteredAbsensi.sort((a, b) => {
        return new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime();
      });

      if (filteredAbsensi.length === 0) {
        alert("Tidak ada data absensi untuk peserta ini pada periode yang dipilih.");
        return;
      }

      // Group by date and combine MASUK and KELUAR
      const dailyData: Record<string, { masuk?: Absensi; keluar?: Absensi }> = {};
      
      filteredAbsensi.forEach((abs) => {
        const dateStr = new Date(abs.timestamp).toISOString().split('T')[0];
        if (!dailyData[dateStr]) {
          dailyData[dateStr] = {};
        }
        if (abs.tipe === 'MASUK') {
          dailyData[dateStr].masuk = abs;
        } else if (abs.tipe === 'KELUAR') {
          dailyData[dateStr].keluar = abs;
        }
      });

      // Filename: jika tidak ada tanggal, tandai ALL
      const fileNameStartDate = dateRange.startDate ? dateRange.startDate.replace(/-/g, '') : 'ALL';
      const fileNameEndDate = dateRange.endDate ? dateRange.endDate.replace(/-/g, '') : 'ALL';
      const fileName = `Laporan_Detail_${selectedPeserta?.nama?.replace(/\s+/g, '_') || 'Peserta'}_${fileNameStartDate}_${fileNameEndDate}_${new Date().toISOString().split('T')[0]}`;
      
      // Format dates for display
      const startDateFormatted = dateRange.startDate
        ? new Date(dateRange.startDate).toLocaleDateString("id-ID", {
            day: "numeric",
            month: "long",
            year: "numeric",
          })
        : "Semua";
      const endDateFormatted = dateRange.endDate
        ? new Date(dateRange.endDate).toLocaleDateString("id-ID", {
            day: "numeric",
            month: "long",
            year: "numeric",
          })
        : "Semua";

      if (format === "csv" || format === "excel") {
        const headers = [
          "Tanggal",
          "Hari",
          "Jam Masuk",
          "Status Masuk",
          "Jam Keluar",
          "Lokasi Masuk",
          "Lokasi Keluar",
          "Durasi Kerja",
        ];

        const rows = Object.keys(dailyData)
          .sort()
          .map((dateStr) => {
            const dayData = dailyData[dateStr];
            const date = new Date(dateStr);
            const dayName = date.toLocaleDateString("id-ID", { weekday: "long" });
            
            const jamMasuk = dayData.masuk
              ? new Date(dayData.masuk.timestamp).toLocaleTimeString("id-ID", {
                  hour: "2-digit",
                  minute: "2-digit",
                })
              : "-";
            
            const statusMasuk = dayData.masuk?.status || "-";
            
            const jamKeluar = dayData.keluar
              ? new Date(dayData.keluar.timestamp).toLocaleTimeString("id-ID", {
                  hour: "2-digit",
                  minute: "2-digit",
                })
              : "-";
            
            const lokasiMasuk = dayData.masuk?.lokasi?.alamat || "-";
            const lokasiKeluar = dayData.keluar?.lokasi?.alamat || "-";
            
            let durasiKerja = "-";
            if (dayData.masuk && dayData.keluar) {
              const masukTime = new Date(dayData.masuk.timestamp).getTime();
              const keluarTime = new Date(dayData.keluar.timestamp).getTime();
              const diffMs = keluarTime - masukTime;
              const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
              const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
              durasiKerja = `${diffHours} jam ${diffMinutes} menit`;
            }

            return [
              new Date(dateStr).toLocaleDateString("id-ID"),
              dayName,
              jamMasuk,
              statusMasuk,
              jamKeluar,
              lokasiMasuk,
              lokasiKeluar,
              durasiKerja,
            ];
          });

        const csvContent = [
          `Nama Peserta,${selectedPeserta?.nama || "-"}`,
          `Divisi,${selectedPeserta?.divisi || "-"}`,
          `Periode,${startDateFormatted} - ${endDateFormatted}`,
          "",
          headers.join(","),
          ...rows.map((row) =>
            row.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(",")
          ),
        ].join("\n");

        const BOM = "\uFEFF";
        const blob = new Blob([BOM + csvContent], {
          type: format === "csv" ? "text/csv;charset=utf-8;" : "application/vnd.ms-excel;charset=utf-8;",
        });

        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", `${fileName}.${format === "csv" ? "csv" : "xls"}`);
        link.style.visibility = "hidden";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      } else if (format === "pdf") {
        const printWindow = window.open("", "_blank");
        if (!printWindow) {
          alert("Tolong izinkan popup untuk generate PDF.");
          return;
        }

        const htmlContent = `
          <!DOCTYPE html>
          <html>
            <head>
              <title>${fileName}</title>
              <style>
                body {
                  font-family: Arial, sans-serif;
                  padding: 20px;
                }
                h1 {
                  text-align: center;
                  color: #1f2937;
                  margin-bottom: 10px;
                }
                .info {
                  text-align: center;
                  color: #6b7280;
                  margin-bottom: 20px;
                }
                .participant-info {
                  background-color: #f3f4f6;
                  padding: 15px;
                  border-radius: 8px;
                  margin-bottom: 20px;
                }
                .participant-info p {
                  margin: 5px 0;
                }
                table {
                  width: 100%;
                  border-collapse: collapse;
                  margin-top: 20px;
                }
                th, td {
                  border: 1px solid #d1d5db;
                  padding: 8px;
                  text-align: left;
                  font-size: 12px;
                }
                th {
                  background-color: #f3f4f6;
                  font-weight: bold;
                }
                tr:nth-child(even) {
                  background-color: #f9fafb;
                }
                .status-valid {
                  color: #065f46;
                  font-weight: 600;
                }
                .status-terlambat {
                  color: #92400e;
                  font-weight: 600;
                }
                .status-invalid {
                  color: #991b1b;
                  font-weight: 600;
                }
                @media print {
                  body {
                    padding: 0;
                  }
                  @page {
                    margin: 1cm;
                  }
                }
              </style>
            </head>
            <body>
              <h1>Laporan Detail Absensi</h1>
              <div class="info">
                <p>Periode: ${startDateFormatted} - ${endDateFormatted}</p>
                <p>Dibuat pada: ${new Date().toLocaleDateString("id-ID", {
                  day: "numeric",
                  month: "long",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}</p>
              </div>
              <div class="participant-info">
                <p><strong>Nama Peserta:</strong> ${selectedPeserta?.nama || "-"}</p>
                <p><strong>Divisi:</strong> ${selectedPeserta?.divisi || "-"}</p>
                <p><strong>Instansi:</strong> ${selectedPeserta?.instansi || "-"}</p>
              </div>
              <table>
                <thead>
                  <tr>
                    <th>No</th>
                    <th>Tanggal</th>
                    <th>Hari</th>
                    <th>Jam Masuk</th>
                    <th>Status Masuk</th>
                    <th>Jam Keluar</th>
                    <th>Durasi Kerja</th>
                  </tr>
                </thead>
                <tbody>
                  ${Object.keys(dailyData)
                    .sort()
                    .map((dateStr, index) => {
                      const dayData = dailyData[dateStr];
                      const date = new Date(dateStr);
                      const dayName = date.toLocaleDateString("id-ID", { weekday: "long" });
                      
                      const jamMasuk = dayData.masuk
                        ? new Date(dayData.masuk.timestamp).toLocaleTimeString("id-ID", {
                            hour: "2-digit",
                            minute: "2-digit",
                          })
                        : "-";
                      
                      const statusMasuk = dayData.masuk?.status || "-";
                      const statusClass = statusMasuk === "VALID" ? "status-valid" 
                        : statusMasuk === "TERLAMBAT" ? "status-terlambat"
                        : statusMasuk === "INVALID" ? "status-invalid" : "";
                      
                      const jamKeluar = dayData.keluar
                        ? new Date(dayData.keluar.timestamp).toLocaleTimeString("id-ID", {
                            hour: "2-digit",
                            minute: "2-digit",
                          })
                        : "-";
                      
                      let durasiKerja = "-";
                      if (dayData.masuk && dayData.keluar) {
                        const masukTime = new Date(dayData.masuk.timestamp).getTime();
                        const keluarTime = new Date(dayData.keluar.timestamp).getTime();
                        const diffMs = keluarTime - masukTime;
                        const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
                        const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
                        durasiKerja = `${diffHours} jam ${diffMinutes} menit`;
                      }

                      return `
                        <tr>
                          <td>${index + 1}</td>
                          <td>${date.toLocaleDateString("id-ID")}</td>
                          <td>${dayName}</td>
                          <td>${jamMasuk}</td>
                          <td class="${statusClass}">${statusMasuk}</td>
                          <td>${jamKeluar}</td>
                          <td>${durasiKerja}</td>
                        </tr>
                      `;
                    })
                    .join("")}
                </tbody>
              </table>
            </body>
          </html>
        `;

        printWindow.document.write(htmlContent);
        printWindow.document.close();
        
        printWindow.onload = () => {
          setTimeout(() => {
            printWindow.print();
          }, 250);
        };
      }
    } catch (error) {
      console.error("Error exporting detail:", error);
      alert("Terjadi kesalahan saat mengekspor data. Silakan coba lagi.");
    }
  };

  const handleExport = (format: "excel" | "pdf" | "csv") => {
    if (filteredData.length === 0) {
      alert("Tidak ada data untuk diekspor. Silakan pilih filter atau tanggal yang sesuai.");
      return;
    }

    const fileName = `Laporan_Absensi_${dateRange.startDate || 'all'}_${dateRange.endDate || 'all'}_${new Date().toISOString().split('T')[0]}`;

    if (format === "csv" || format === "excel") {
      // Generate CSV content
      const headers = [
        "Nama Peserta",
        "Divisi",
        "Status",
        "Total Hari",
        "Hadir",
        "Tidak Hadir",
        "Terlambat",
        "Tingkat Kehadiran (%)",
        "Periode Mulai",
      ];

      const rows = filteredData.map((record) => [
        record.pesertaMagangName,
        record.pesertaMagang?.divisi || "Tidak tersedia",
        record.pesertaMagang?.status || "Unknown",
        record.totalHari.toString(),
        record.hadir.toString(),
        record.tidakHadir.toString(),
        record.terlambat.toString(),
        record.tingkatKehadiran.toString(),
        record.periode.mulai
          ? new Date(record.periode.mulai).toLocaleDateString("id-ID")
          : "-",
      ]);

      // Combine headers and rows
      const csvContent = [
        headers.join(","),
        ...rows.map((row) =>
          row.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(",")
        ),
      ].join("\n");

      // Add BOM for UTF-8 to support Indonesian characters in Excel
      const BOM = "\uFEFF";
      const blob = new Blob([BOM + csvContent], {
        type: format === "csv" ? "text/csv;charset=utf-8;" : "application/vnd.ms-excel;charset=utf-8;",
      });

      // Create download link
      const link = document.createElement("a");
      const url = URL.createObjectURL(blob);
      link.setAttribute("href", url);
      link.setAttribute("download", `${fileName}.${format === "csv" ? "csv" : "xls"}`);
      link.style.visibility = "hidden";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } else if (format === "pdf") {
      // For PDF, we'll create a simple HTML table and use browser's print-to-PDF
      // This is a simple approach without external libraries
      const printWindow = window.open("", "_blank");
      if (!printWindow) {
        alert("Tolong izinkan popup untuk generate PDF.");
        return;
      }

      const htmlContent = `
        <!DOCTYPE html>
        <html>
          <head>
            <title>${fileName}</title>
            <style>
              body {
                font-family: Arial, sans-serif;
                padding: 20px;
              }
              h1 {
                text-align: center;
                color: #1f2937;
                margin-bottom: 10px;
              }
              .info {
                text-align: center;
                color: #6b7280;
                margin-bottom: 30px;
              }
              table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
              }
              th, td {
                border: 1px solid #d1d5db;
                padding: 8px;
                text-align: left;
              }
              th {
                background-color: #f3f4f6;
                font-weight: bold;
              }
              tr:nth-child(even) {
                background-color: #f9fafb;
              }
              .badge {
                padding: 4px 8px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: 600;
              }
              .sangat-baik {
                background-color: #d1fae5;
                color: #065f46;
              }
              .baik {
                background-color: #fef3c7;
                color: #92400e;
              }
              .perlu-diperhatikan {
                background-color: #fee2e2;
                color: #991b1b;
              }
              @media print {
                body {
                  padding: 0;
                }
                @page {
                  margin: 1cm;
                }
              }
            </style>
          </head>
          <body>
            <h1>Laporan Absensi Peserta Magang</h1>
            <div class="info">
              <p>Periode: ${startDate || "Semua"} - ${endDate || "Semua"}</p>
              <p>Dibuat pada: ${new Date().toLocaleDateString("id-ID", {
                day: "numeric",
                month: "long",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit",
              })}</p>
            </div>
            <table>
              <thead>
                <tr>
                  <th>No</th>
                  <th>Nama Peserta</th>
                  <th>Divisi</th>
                  <th>Status</th>
                  <th>Total Hari</th>
                  <th>Hadir</th>
                  <th>Tidak Hadir</th>
                  <th>Terlambat</th>
                  <th>Tingkat Kehadiran</th>
                  <th>Periode Mulai</th>
                </tr>
              </thead>
              <tbody>
                ${filteredData
                  .map(
                    (record, index) => `
                  <tr>
                    <td>${index + 1}</td>
                    <td>${record.pesertaMagangName}</td>
                    <td>${record.pesertaMagang?.divisi || "Tidak tersedia"}</td>
                    <td>${record.pesertaMagang?.status || "Unknown"}</td>
                    <td>${record.totalHari}</td>
                    <td>${record.hadir}</td>
                    <td>${record.tidakHadir}</td>
                    <td>${record.terlambat}</td>
                    <td>
                      <span class="badge ${
                        record.tingkatKehadiran >= 95
                          ? "sangat-baik"
                          : record.tingkatKehadiran >= 85
                          ? "baik"
                          : "perlu-diperhatikan"
                      }">
                        ${record.tingkatKehadiran}%
                      </span>
                    </td>
                    <td>${
                      record.periode.mulai
                        ? new Date(record.periode.mulai).toLocaleDateString(
                            "id-ID"
                          )
                        : "-"
                    }</td>
                  </tr>
                `
                  )
                  .join("")}
              </tbody>
            </table>
            <div style="margin-top: 30px; text-align: center; color: #6b7280; font-size: 12px;">
              <p>Total: ${filteredData.length} peserta magang</p>
              <p>Sangat Baik (≥95%): ${stats.sangatBaik} | Baik (85-94%): ${stats.baik} | Perlu Diperhatikan (&lt;85%): ${stats.perluDiperhatikan}</p>
            </div>
          </body>
        </html>
      `;

      printWindow.document.write(htmlContent);
      printWindow.document.close();
      
      // Wait for content to load, then trigger print dialog
      printWindow.onload = () => {
        setTimeout(() => {
          printWindow.print();
          // Optional: close window after print
          // printWindow.close();
        }, 250);
      };
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading laporan...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <p className="text-red-600 mb-2">Error: {error}</p>
          <button
            onClick={fetchData}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Laporan Absensi</h1>
          <p className="text-gray-600">
            Generate dan export laporan kehadiran siswa
          </p>
        </div>
        {/* Generate Report Button */}
        <div className="flex justify-end gap-2">
          <DropdownMenu.Root>
            <DropdownMenu.Trigger>
              <Button className="flex items-center bg-blue-600 hover:bg-blue-700 text-white">
                <Download className="h-4 w-4 mr-2" />
                Generate Laporan (Keseluruhan)
                <ChevronDown className="h-4 w-4 ml-2" />
              </Button>
            </DropdownMenu.Trigger>
            <DropdownMenu.Content>
              <DropdownMenu.Item onClick={() => handleExport("excel")}>
                <Download className="h-4 w-4 mr-2" />
                Excel (.xlsx)
              </DropdownMenu.Item>
              <DropdownMenu.Item onClick={() => handleExport("pdf")}>
                <Download className="h-4 w-4 mr-2" />
                PDF
              </DropdownMenu.Item>
              <DropdownMenu.Item onClick={() => handleExport("csv")}>
                <Download className="h-4 w-4 mr-2" />
                CSV
              </DropdownMenu.Item>
            </DropdownMenu.Content>
          </DropdownMenu.Root>
        </div>
      </div>

      {/* Statistics Cards */}
      <Grid columns={{ initial: "1", md: "4" }} gap="4">
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Total Laporan
            </Text>
            <Text size="6" weight="bold">
              {stats.total}
            </Text>
            <Text size="1" color="gray">
              Total peserta magang
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Sangat Baik
            </Text>
            <Text size="6" weight="bold" color="green">
              {stats.sangatBaik}
            </Text>
            <Text size="1" color="gray">
              ≥95% kehadiran
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Baik
            </Text>
            <Text size="6" weight="bold" color="orange">
              {stats.baik}
            </Text>
            <Text size="1" color="gray">
              85-94% kehadiran
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Perlu Diperhatikan
            </Text>
            <Text size="6" weight="bold" color="red">
              {stats.perluDiperhatikan}
            </Text>
            <Text size="1" color="gray">
              &lt;85% kehadiran
            </Text>
          </Flex>
        </Card>
      </Grid>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <Text weight="bold">Filter Laporan</Text>
          </Flex>
          <Flex gap="4" wrap="wrap">
            <Flex className="flex items-center w-full relative">
              <TextField.Root
                color="indigo"
                placeholder="Cari laporan absensi…"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full"
              />
            </Flex>
            <div className="flex items-center gap-2">
              <Select.Root
                size="2"
                defaultValue="Semua"
                value={statusFilter}
                onValueChange={(value) => setStatusFilter(value)}
              >
                <Select.Trigger color="indigo" radius="large" />
                <Select.Content color="indigo">
                  <Select.Item value="Semua">Semua Status</Select.Item>
                  <Select.Item value="AKTIF">Aktif</Select.Item>
                  <Select.Item value="NONAKTIF">Nonaktif</Select.Item>
                  <Select.Item value="SELESAI">Selesai</Select.Item>
                </Select.Content>
              </Select.Root>
            </div>
          </Flex>
        </Flex>
      </Box>

      {/* Detailed Attendance Report */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="2">
            <Flex align="center" gap="2">
              <CalendarIcon width="18" height="18" />
              <Text weight="bold">Laporan Detail Kehadiran</Text>
            </Flex>
            <Text size="2" color="gray">
              Data kehadiran detail untuk periode {startDate} - {endDate}
            </Text>
          </Flex>
          <Table.Root variant="ghost">
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeaderCell>
                  Nama Peserta Magang
                </Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Total Hari</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Hadir</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Tidak Hadir</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Terlambat</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Periode Mulai</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>
                  Persentase Kehadiran
                </Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>
                  Aksi
                </Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {filteredData.map((record, index) => (
                <Table.Row
                  key={`${record.pesertaMagangId}-${index}`}
                  className="hover:bg-gray-50"
                >
                  <Table.Cell>
                    <div className="flex items-center">
                      <Avatar
                        src={record.pesertaMagang?.avatar}
                        alt={record.pesertaMagangName}
                        name={record.pesertaMagangName}
                        size="md"
                        showBorder={true}
                        showHover={true}
                        className="border-gray-200"
                      />
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {record.pesertaMagangName}
                        </div>
                        <div className="text-sm text-gray-500">
                          {record.pesertaMagang?.divisi || "Tidak tersedia"}
                        </div>
                      </div>
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                        record.pesertaMagang?.status === "AKTIF"
                          ? "bg-green-100 text-green-800"
                          : record.pesertaMagang?.status === "NONAKTIF"
                          ? "bg-gray-100 text-gray-800"
                          : "bg-blue-100 text-blue-800"
                      }`}
                    >
                      {record.pesertaMagang?.status || "Unknown"}
                    </span>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center">
                      {record.totalHari}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="green">
                      {record.hadir}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="red">
                      {record.tidakHadir}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="orange">
                      {record.terlambat}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="gray">
                      {record.periode?.mulai
                        ? new Date(record.periode.mulai).toLocaleDateString("id-ID")
                        : "-"}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    {getAttendanceRateBadge(record.tingkatKehadiran)}
                  </Table.Cell>
                  <Table.Cell>
                    <DropdownMenu.Root>
                      <DropdownMenu.Trigger>
                        <Button
                          size="1"
                          variant="soft"
                          color="green"
                          className="flex items-center"
                          title="Generate laporan detail (jam masuk & jam keluar)"
                        >
                          <Download className="h-3 w-3 mr-1" />
                          Detail
                          <ChevronDown className="h-3 w-3 ml-1" />
                        </Button>
                      </DropdownMenu.Trigger>
                      <DropdownMenu.Content>
                        <DropdownMenu.Item
                          onClick={() =>
                            handleExportDetailForPeserta(record.pesertaMagangId, "excel")
                          }
                        >
                          <Download className="h-4 w-4 mr-2" />
                          Excel (.xls)
                        </DropdownMenu.Item>
                        <DropdownMenu.Item
                          onClick={() =>
                            handleExportDetailForPeserta(record.pesertaMagangId, "pdf")
                          }
                        >
                          <Download className="h-4 w-4 mr-2" />
                          PDF
                        </DropdownMenu.Item>
                        <DropdownMenu.Item
                          onClick={() =>
                            handleExportDetailForPeserta(record.pesertaMagangId, "csv")
                          }
                        >
                          <Download className="h-4 w-4 mr-2" />
                          CSV
                        </DropdownMenu.Item>
                      </DropdownMenu.Content>
                    </DropdownMenu.Root>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table.Root>
          {filteredData.length === 0 && (
            <Box className="text-center py-12">
              <ClockIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <Flex direction="column" justify="center">
                <Text size="3" color="gray" weight="medium">
                  Tidak ada data Peserta yang ditemukan
                </Text>
                <Text size="2" color="gray" className="mt-2">
                  {searchTerm
                    ? "Coba ubah kata kunci pencarian"
                    : "Belum ada riwayat Laporan"}
                </Text>
              </Flex>
            </Box>
          )}
        </Card>
      </Box>
    </div>
  );
}
