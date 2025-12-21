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

// Import Library Export
import * as XLSX from "xlsx";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

// Import services & Components
import dashboardService from "../services/dashboardService";
import pesertaMagangService from "../services/pesertaMagangService";
import Avatar from "../components/Avatar";

// --- Helper Components ---
const getAttendanceRateBadge = (rate: number) => {
  if (rate >= 95) {
    return (
      <span className="inline-flex px-2.5 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800 border border-green-200">
        Sangat Baik
      </span>
    );
  } else if (rate >= 85) {
    return (
      <span className="inline-flex px-2.5 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800 border border-yellow-200">
        Baik
      </span>
    );
  } else {
    return (
      <span className="inline-flex px-2.5 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800 border border-red-200">
        Perlu Diperhatikan
      </span>
    );
  }
};

export default function LaporanPage() {
  // ============ STATE MANAGEMENT ============
  const [attendanceReports, setAttendanceReports] = useState<LaporanAbsensi[]>([]);
  const [pesertaMagangData, setPesertaMagangData] = useState<PesertaMagang[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [dateRange, setDateRange] = useState({
    startDate: "",
    endDate: "",
  });

  // ============ DATA FETCHING ============
  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

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

  // ============ DATA PROCESSING ============
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
      report.pesertaMagangName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.pesertaMagang?.divisi.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || report.pesertaMagang?.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const stats = {
    total: attendanceReports.length,
    sangatBaik: attendanceReports.filter((r) => r.tingkatKehadiran >= 95).length,
    baik: attendanceReports.filter((r) => r.tingkatKehadiran >= 85 && r.tingkatKehadiran < 95).length,
    perluDiperhatikan: attendanceReports.filter((r) => r.tingkatKehadiran < 85).length,
  };

  const startDateDisplay = dateRange.startDate
    ? new Date(dateRange.startDate).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" })
    : "";

  const endDateDisplay = dateRange.endDate
    ? new Date(dateRange.endDate).toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric" })
    : "";

  // ============ EXPORT LOGIC ============

  const prepareExportData = () => {
    return filteredData.map((item) => {
      // Safety check untuk tanggal agar tidak muncul "Invalid Date"
      let periodeMulai = "-";
      try {
        if (item.periode && item.periode.mulai) {
          periodeMulai = new Date(item.periode.mulai).toLocaleDateString("id-ID");
        }
      } catch (e) { periodeMulai = "-" }

      return {
        Nama: item.pesertaMagangName,
        Divisi: item.pesertaMagang?.divisi || "-",
        Status: item.pesertaMagang?.status || "-",
        "Total": item.totalHari,
        Hadir: item.hadir,
        "Absen": item.tidakHadir, // Ganti label biar pendek
        Telat: item.terlambat,
        "Mulai Magang": periodeMulai,
        "Persentase": `${item.tingkatKehadiran}%`,
      };
    });
  };

  // --- MODERN EXPORT FUNCTION (FIXED LAYOUT) ---
  const handleExport = (format: "excel" | "pdf" | "csv") => {
    const dataToExport = prepareExportData();
    const timestamp = new Date().toISOString().slice(0, 10);
    const fileName = `Laporan_Absensi_${timestamp}`;

    // --- 1. EXCEL ---
    if (format === "excel") {
      const worksheet = XLSX.utils.json_to_sheet(dataToExport);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, "Laporan Absensi");
      XLSX.writeFile(workbook, `${fileName}.xlsx`);
    }

    // --- 2. CSV ---
    else if (format === "csv") {
      const worksheet = XLSX.utils.json_to_sheet(dataToExport);
      const csvOutput = XLSX.utils.sheet_to_csv(worksheet);
      const blob = new Blob([csvOutput], { type: "text/csv;charset=utf-8;" });
      const link = document.createElement("a");
      const url = URL.createObjectURL(blob);
      link.setAttribute("href", url);
      link.setAttribute("download", `${fileName}.csv`);
      link.style.visibility = "hidden";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }

    // --- 3. PDF (LAYOUT RAPI & LEGA) ---
    else if (format === "pdf") {
      const doc = new jsPDF({
        orientation: "portrait", // Gunakan 'landscape' jika kolom terlalu banyak
        unit: "mm",
        format: "a4"
      });

      const pageWidth = doc.internal.pageSize.getWidth();
      const pageHeight = doc.internal.pageSize.getHeight();

      // Definisi Warna PLN
      const colorPrimary = [0, 162, 233]; // Cyan PLN
      const colorSecondary = [17, 68, 93]; // Dark Blue PLN
      const colorGray = [100, 100, 100];

      const marginX = 15;
      let currentY = 15;

      // --- 1. HEADER (KOP) ---
      // Logo (Placeholder)
      const logoBase64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
      try {
        doc.addImage(logoBase64, 'PNG', marginX, currentY, 12, 12);
      } catch (e) { /* ignore */ }

      // Teks KOP
      const textX = marginX + 16;
      doc.setFont("helvetica", "bold");
      doc.setFontSize(14);
      doc.setTextColor(colorPrimary[0], colorPrimary[1], colorPrimary[2]);
      doc.text("PT PLN ICON PLUS", textX, currentY + 5);

      doc.setFont("helvetica", "normal");
      doc.setFontSize(9);
      doc.setTextColor(colorGray[0], colorGray[1], colorGray[2]);
      doc.text("Kantor Perwakilan Aceh - Jl. Teuku Umar No. 426", textX, currentY + 10);

      // Garis
      currentY += 16;
      doc.setDrawColor(colorPrimary[0], colorPrimary[1], colorPrimary[2]);
      doc.setLineWidth(0.5);
      doc.line(marginX, currentY, pageWidth - marginX, currentY);

      // --- 2. JUDUL LAPORAN ---
      currentY += 10;
      doc.setFont("helvetica", "bold");
      doc.setFontSize(16);
      doc.setTextColor(colorSecondary[0], colorSecondary[1], colorSecondary[2]);
      doc.text("LAPORAN ABSENSI", marginX, currentY);

      // Info Periode
      currentY += 6;
      doc.setFont("helvetica", "normal");
      doc.setFontSize(10);
      doc.setTextColor(colorGray[0], colorGray[1], colorGray[2]);

      const periodText = (startDateDisplay && endDateDisplay)
        ? `${startDateDisplay} - ${endDateDisplay}`
        : "Semua Periode";
      doc.text(`Periode: ${periodText}`, marginX, currentY);

      // Tanggal Cetak (Kanan)
      const printDate = new Date().toLocaleDateString("id-ID", {
          day: 'numeric', month: 'long', year: 'numeric',
          hour: '2-digit', minute: '2-digit'
      });
      doc.setFontSize(8);
      doc.text(`Dicetak: ${printDate}`, pageWidth - marginX, currentY, { align: "right" });

      // --- 3. TABEL DATA (Y = 55mm agar tidak mepet) ---
      autoTable(doc, {
        startY: currentY + 10,
        head: [Object.keys(dataToExport[0])],
        body: dataToExport.map(obj => Object.values(obj)),
        theme: 'grid',
        styles: {
          fontSize: 8, // Font lebih kecil agar muat
          cellPadding: 3,
          valign: 'middle',
          halign: 'center', // Default rata tengah
          font: 'helvetica',
          lineColor: [220, 220, 220],
          lineWidth: 0.1,
        },
        headStyles: {
          fillColor: colorPrimary,
          textColor: 255,
          fontStyle: 'bold',
          minCellHeight: 10,
          valign: 'middle',
          halign: 'center'
        },
        // Kustomisasi Lebar Kolom (Total Width A4 Portrait ~180mm usable)
        columnStyles: {
          0: { cellWidth: 35, halign: 'left', fontStyle: 'bold' }, // Nama (Lebar, rata kiri)
          1: { cellWidth: 25, halign: 'left' }, // Divisi
          2: { cellWidth: 20 }, // Status
          3: { cellWidth: 12 }, // Total
          4: { cellWidth: 12 }, // Hadir
          5: { cellWidth: 12 }, // Absen (Tidak Hadir)
          6: { cellWidth: 12 }, // Telat
          7: { cellWidth: 25 }, // Mulai Magang
          8: { cellWidth: 20, fontStyle: 'bold', textColor: colorPrimary } // Persentase
        },
        alternateRowStyles: {
          fillColor: [249, 252, 255]
        },
        didDrawPage: function (data) {
          const str = "Halaman " + doc.internal.getNumberOfPages();
          doc.setFontSize(8);
          doc.setTextColor(150, 150, 150);
          doc.text(str, pageWidth - marginX, pageHeight - 10, { align: "right" });
        }
      });

      doc.save(`${fileName}.pdf`);
    }
  };

  // ============ RENDER UI ============
  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 font-medium">Memproses data laporan...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center p-6 bg-red-50 rounded-xl border border-red-100">
          <p className="text-red-600 mb-4 font-medium">Terjadi kesalahan: {error}</p>
          <button onClick={fetchData} className="px-5 py-2.5 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
            Coba Lagi
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8 pb-10">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Laporan Absensi</h1>
          <p className="text-gray-500 mt-1">
            Rekapitulasi kehadiran dan statistik peserta magang
          </p>
        </div>

        {/* Export Button */}
        <DropdownMenu.Root>
          <DropdownMenu.Trigger>
            <Button size="3" className="cursor-pointer bg-blue-600 hover:bg-blue-700 text-white shadow-sm hover:shadow transition-all">
              <Download className="h-4 w-4 mr-2" />
              Download Laporan
              <ChevronDown className="h-4 w-4 ml-2 opacity-70" />
            </Button>
          </DropdownMenu.Trigger>
          <DropdownMenu.Content align="end" variant="soft">
            <DropdownMenu.Item onClick={() => handleExport("excel")} className="cursor-pointer">
              <span className="flex-1">Excel (.xlsx)</span>
            </DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => handleExport("pdf")} className="cursor-pointer">
              <span className="flex-1">PDF (Resmi)</span>
            </DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => handleExport("csv")} className="cursor-pointer">
              <span className="flex-1">CSV</span>
            </DropdownMenu.Item>
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </div>

      {/* Statistics Cards */}
      <Grid columns={{ initial: "1", sm: "2", lg: "4" }} gap="5">
        {[
          { label: "Total Peserta", value: stats.total, sub: "Data terdaftar", color: "text-gray-900", bg: "bg-white" },
          { label: "Sangat Baik", value: stats.sangatBaik, sub: "≥95% kehadiran", color: "text-green-600", bg: "bg-green-50/30" },
          { label: "Baik", value: stats.baik, sub: "85-94% kehadiran", color: "text-yellow-600", bg: "bg-yellow-50/30" },
          { label: "Perlu Perhatian", value: stats.perluDiperhatikan, sub: "<85% kehadiran", color: "text-red-600", bg: "bg-red-50/30" },
        ].map((stat, idx) => (
          <Card key={idx} className={`${stat.bg} shadow-sm hover:shadow-md transition-shadow`}>
            <Flex direction="column" p="5">
              <Text size="2" weight="medium" color="gray" className="uppercase tracking-wider text-xs">
                {stat.label}
              </Text>
              <Text size="8" weight="bold" className={`my-1 ${stat.color}`}>
                {stat.value}
              </Text>
              <Text size="1" color="gray">
                {stat.sub}
              </Text>
            </Flex>
          </Card>
        ))}
      </Grid>

      {/* Filters Section */}
      <Card className="shadow-sm">
        <Box p="5">
          <Flex direction="column" gap="5">
            <Flex align="center" gap="2" className="text-gray-900">
              <MixerHorizontalIcon width="20" height="20" />
              <Text weight="bold" size="4">Filter & Pencarian</Text>
            </Flex>

            <Flex gap="4" wrap="wrap" align="center" justify="between">
              {/* Search */}
              <div className="flex-1 min-w-[280px]">
                <TextField.Root
                  size="3"
                  color="indigo"
                  placeholder="Cari nama atau divisi..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full"
                  radius="large"
                />
              </div>

              {/* Filters Right Side */}
              <Flex gap="3" align="center" wrap="wrap" className="justify-end flex-1 sm:flex-none">
                <div className="w-full sm:w-auto">
                  <Select.Root
                    size="3"
                    defaultValue="Semua"
                    value={statusFilter}
                    onValueChange={(value) => setStatusFilter(value)}
                  >
                    <Select.Trigger color="indigo" radius="large" className="w-full sm:min-w-[160px]" placeholder="Status" />
                    <Select.Content color="indigo">
                      <Select.Item value="Semua">Semua Status</Select.Item>
                      <Select.Item value="AKTIF">Aktif</Select.Item>
                      <Select.Item value="NONAKTIF">Nonaktif</Select.Item>
                      <Select.Item value="SELESAI">Selesai</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </div>

                <div className="flex items-center gap-2 bg-gray-50 p-1.5 rounded-lg border border-gray-200 w-full sm:w-auto">
                  <input
                    type="date"
                    className="bg-transparent border-none text-sm text-gray-700 focus:ring-0 cursor-pointer p-1"
                    value={dateRange.startDate}
                    onChange={(e) => setDateRange((prev) => ({ ...prev, startDate: e.target.value }))}
                  />
                  <span className="text-gray-400 text-sm">-</span>
                  <input
                    type="date"
                    className="bg-transparent border-none text-sm text-gray-700 focus:ring-0 cursor-pointer p-1"
                    value={dateRange.endDate}
                    onChange={(e) => setDateRange((prev) => ({ ...prev, endDate: e.target.value }))}
                  />
                  <Button onClick={handleDateRangeChange} size="2" color="indigo" radius="medium" className="ml-2 cursor-pointer">
                    Terapkan
                  </Button>
                </div>
              </Flex>
            </Flex>
          </Flex>
        </Box>
      </Card>

      {/* Table Data */}
      <Card className="shadow-sm overflow-hidden">
        <Flex direction="column" className="border-b border-gray-100 bg-gray-50/50" p="5">
          <Flex align="center" gap="2" mb="1">
            <CalendarIcon width="18" height="18" className="text-gray-700"/>
            <Text weight="bold" size="3" className="text-gray-900">Detail Kehadiran</Text>
          </Flex>
          <Text size="2" color="gray">
            Menampilkan data untuk periode: <span className="font-medium text-gray-700">{startDateDisplay || "Awal"}</span> s/d <span className="font-medium text-gray-700">{endDateDisplay || "Sekarang"}</span>
          </Text>
        </Flex>

        <Table.Root variant="surface">
          <Table.Header>
            <Table.Row className="bg-gray-50">
              <Table.ColumnHeaderCell className="p-4">Peserta</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4" align="center">Total</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4" align="center">Hadir</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4" align="center">Absen</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4" align="center">Telat</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4">Mulai Magang</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-4">Performa</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {filteredData.map((record, index) => (
              <Table.Row key={`${record.pesertaMagangId}-${index}`} className="hover:bg-blue-50/30 transition-colors">
                <Table.Cell className="p-4">
                  <div className="flex items-center">
                    <Avatar
                      src={record.pesertaMagang?.avatar}
                      alt={record.pesertaMagangName}
                      name={record.pesertaMagangName}
                      size="md"
                      showBorder
                      className="border-gray-200 shadow-sm"
                    />
                    <div className="ml-4">
                      <div className="text-sm font-semibold text-gray-900">{record.pesertaMagangName}</div>
                      <div className="text-xs text-gray-500 font-medium">{record.pesertaMagang?.divisi || "-"}</div>
                    </div>
                  </div>
                </Table.Cell>

                <Table.Cell className="p-4 align-middle">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      record.pesertaMagang?.status === "AKTIF" ? "bg-green-100 text-green-800" :
                      record.pesertaMagang?.status === "NONAKTIF" ? "bg-gray-100 text-gray-800" :
                      "bg-blue-100 text-blue-800"
                    }`}>
                    {record.pesertaMagang?.status || "-"}
                  </span>
                </Table.Cell>

                <Table.Cell className="p-4 align-middle" align="center">
                  <span className="font-mono text-sm font-medium">{record.totalHari}</span>
                </Table.Cell>
                <Table.Cell className="p-4 align-middle" align="center">
                  <span className="font-mono text-sm font-bold text-green-600 bg-green-50 px-2 py-1 rounded">{record.hadir}</span>
                </Table.Cell>
                <Table.Cell className="p-4 align-middle" align="center">
                  <span className={`font-mono text-sm font-bold px-2 py-1 rounded ${record.tidakHadir > 0 ? 'text-red-600 bg-red-50' : 'text-gray-400'}`}>
                    {record.tidakHadir}
                  </span>
                </Table.Cell>
                <Table.Cell className="p-4 align-middle" align="center">
                  <span className={`font-mono text-sm font-bold px-2 py-1 rounded ${record.terlambat > 0 ? 'text-orange-600 bg-orange-50' : 'text-gray-400'}`}>
                    {record.terlambat}
                  </span>
                </Table.Cell>

                <Table.Cell className="p-4 align-middle">
                  <Text size="2" color="gray">
                    {new Date(record.periode.mulai).toLocaleDateString("id-ID", { day: 'numeric', month: 'short', year: 'numeric' })}
                  </Text>
                </Table.Cell>

                <Table.Cell className="p-4 align-middle">
                  {getAttendanceRateBadge(record.tingkatKehadiran)}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table.Root>

        {filteredData.length === 0 && (
          <Box className="text-center py-16 bg-gray-50/30">
            <div className="bg-white p-4 rounded-full inline-block shadow-sm mb-4">
              <ClockIcon className="h-8 w-8 text-gray-300" />
            </div>
            <Flex direction="column" justify="center">
              <Text size="3" color="gray" weight="medium">Tidak ada data ditemukan</Text>
              <Text size="2" color="gray" className="mt-1">
                {searchTerm ? `Tidak ada hasil untuk "${searchTerm}"` : "Belum ada riwayat laporan absensi"}
              </Text>
            </Flex>
          </Box>
        )}
      </Card>
    </div>
  );
}