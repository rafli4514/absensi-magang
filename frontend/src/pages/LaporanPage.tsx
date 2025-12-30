import { useState, useEffect } from "react";
import {
  Download,
  ChevronDown,
  FileSpreadsheet,
  FileText,
  File,
  Filter,
  CalendarDays,
  Search,
  Users
} from "lucide-react";
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
  IconButton,
} from "@radix-ui/themes";
import {
  CalendarIcon,
  ClockIcon,
  MixerHorizontalIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  DoubleArrowLeftIcon,
  DoubleArrowRightIcon,
} from "@radix-ui/react-icons";

// Import Library Export
import * as XLSX from "xlsx";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

// Import Assets (Logo)
import LogoPLN from "../assets/64eb562e223ee070362018.png";

// Import services & Components
import dashboardService from "../services/dashboardService";
import pesertaMagangService from "../services/pesertaMagangService";
import absensiService from "../services/absensiService";
import Avatar from "../components/Avatar";

// --- Helper Components ---
const getAttendanceRateBadge = (rate: number) => {
  if (rate >= 95) {
    return (
      <span className="inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full bg-green-100 text-green-800 border border-green-200">
        Sangat Baik
      </span>
    );
  } else if (rate >= 85) {
    return (
      <span className="inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full bg-yellow-100 text-yellow-800 border border-yellow-200">
        Baik
      </span>
    );
  } else {
    return (
      <span className="inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full bg-red-100 text-red-800 border border-red-200">
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

  // --- NEW FILTER LOGIC ---
  const [filterType, setFilterType] = useState<"ALL" | "MONTHLY" | "CUSTOM">("MONTHLY");
  // Default bulan ini
  const [selectedMonth, setSelectedMonth] = useState(new Date().toISOString().slice(0, 7));

  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");

  // dateRange ini yang dikirim ke API
  const [dateRange, setDateRange] = useState({
    startDate: "",
    endDate: "",
  });

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState<string>("20");

  // ============ EFFECT: AUTO CALCULATE DATES ============
  useEffect(() => {
    if (filterType === "ALL") {
      setDateRange({ startDate: "", endDate: "" });
    } else if (filterType === "MONTHLY" && selectedMonth) {
      const [year, month] = selectedMonth.split("-").map(Number);
      const start = new Date(year, month - 1, 1);
      const end = new Date(year, month, 0);

      setDateRange({
         startDate: start.toLocaleDateString('en-CA'),
         endDate: end.toLocaleDateString('en-CA')
      });
    }
  }, [filterType, selectedMonth]);

  // ============ DATA FETCHING ============
  useEffect(() => {
    if (filterType === "MONTHLY" && !dateRange.startDate) return;
    fetchData();
  }, [dateRange]);

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

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, statusFilter, dateRange, itemsPerPage]);

  const totalItems = filteredData.length;
  const pageSize = itemsPerPage === "All" ? totalItems : parseInt(itemsPerPage);
  const totalPages = Math.ceil(totalItems / pageSize);

  const paginatedData = filteredData.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

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

  const getPeriodLabel = () => {
    if (filterType === "ALL") return "Periode: Selama Magang (Keseluruhan)";
    if (dateRange.startDate && dateRange.endDate) {
        if (filterType === "MONTHLY") {
             return `Periode: ${new Date(dateRange.startDate).toLocaleDateString("id-ID", { month: "long", year: "numeric" })}`;
        }
        return `Periode: ${startDateDisplay} - ${endDateDisplay}`;
    }
    return "Periode: -";
  };

  // ============ HELPER: HEADER GENERATOR ============
  const addModernHeader = (doc: jsPDF, title: string, subtitle: string, isLandscape: boolean = false) => {
    const PLN_BLUE = "#0066CC";
    const DARK_GREY = "#333333";
    const pageWidth = doc.internal.pageSize.getWidth();
    const margin = 14;
    const lineEnd = pageWidth - margin;

    const logoWidth = 50;
    const logoHeight = 20;

    try {
      doc.addImage(LogoPLN, "PNG", margin, 10, logoWidth, logoHeight);
    } catch (e) {
      console.warn("Logo load failed", e);
    }

    const textStartX = 70;
    doc.setTextColor(PLN_BLUE);
    doc.setFont("helvetica", "bold");
    doc.setFontSize(16);
    doc.text("PT PLN ICON PLUS", textStartX, 18);

    doc.setTextColor(DARK_GREY);
    doc.setFont("helvetica", "normal");
    doc.setFontSize(10);
    doc.text("Kantor Perwakilan Aceh Jl. Teuku Umar No. 426", textStartX, 24);

    doc.setDrawColor(PLN_BLUE);
    doc.setLineWidth(1);
    doc.line(margin, 38, lineEnd, 38);

    doc.setFont("helvetica", "bold");
    doc.setFontSize(14);
    doc.setTextColor(DARK_GREY);
    doc.text(title, margin, 48);

    doc.setFontSize(10);
    doc.setFont("helvetica", "normal");
    doc.setTextColor(100, 100, 100);
    doc.text(subtitle, margin, 54);

    return 60;
  };

  // ============ EXPORT LOGIC (DETAIL PER PESERTA) ============
  const handleExportDetailForPeserta = async (
    pesertaId: string,
    format: "excel" | "pdf" | "csv"
  ) => {
    try {
      if (format !== "pdf") {
        alert("Saat ini ekspor detail per peserta hanya tersedia dalam format PDF.");
        return;
      }

      const [pesertaRes, absensiRes] = await Promise.all([
        pesertaMagangService.getPesertaMagangById(pesertaId),
        absensiService.getAbsensi({
            pesertaMagangId: pesertaId,
            limit: 1000,
            startDate: dateRange.startDate || undefined,
            endDate: dateRange.endDate || undefined
        })
      ]);

      if (!pesertaRes.data) throw new Error("Data peserta tidak ditemukan");

      const peserta = pesertaRes.data;
      const logs = absensiRes.data || [];

      const groupedLogs: Record<string, { date: Date; masuk?: string; keluar?: string; status: string; masukDate?: Date; keluarDate?: Date; }> = {};
      logs.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

      logs.forEach(log => {
        const dateKey = new Date(log.timestamp).toLocaleDateString("en-CA");
        if (!groupedLogs[dateKey]) {
          groupedLogs[dateKey] = { date: new Date(log.timestamp), status: log.status };
        }
        const timeStr = new Date(log.timestamp).toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' }).replace('.', ':');

        if (log.tipe === "MASUK") {
          groupedLogs[dateKey].masuk = timeStr;
          groupedLogs[dateKey].masukDate = new Date(log.timestamp);
          groupedLogs[dateKey].status = log.status;
        } else if (log.tipe === "KELUAR") {
          groupedLogs[dateKey].keluar = timeStr;
          groupedLogs[dateKey].keluarDate = new Date(log.timestamp);
        }
      });

      const tableRows = Object.values(groupedLogs).map((item, index) => {
        let durasi = "-";
        if (item.masukDate && item.keluarDate) {
          const diffMs = item.keluarDate.getTime() - item.masukDate.getTime();
          const diffHrs = Math.floor(diffMs / 3600000);
          const diffMins = Math.floor((diffMs % 3600000) / 60000);
          durasi = `${diffHrs}j ${diffMins}m`;
        }

        return [
          (index + 1).toString(),
          item.date.toLocaleDateString("id-ID", { day: 'numeric', month: 'numeric', year: 'numeric' }),
          item.date.toLocaleDateString("id-ID", { weekday: 'long' }),
          item.masuk || "-",
          item.keluar || "-",
          durasi,
          item.status
        ];
      });

      const doc = new jsPDF();

      const startYContent = addModernHeader(
        doc,
        "LAPORAN DETAIL ABSENSI",
        getPeriodLabel()
      );

      const PLN_BLUE = "#0066CC";
      const DARK_GREY = "#333333";

      const labelX1 = 14; const valueX1 = 40;
      const labelX2 = 110; const valueX2 = 135;
      const lineY = startYContent + 10;
      const lineHeight = 6;

      doc.setFont("helvetica", "normal"); doc.setFontSize(10); doc.setTextColor(DARK_GREY);

      doc.setFont("helvetica", "bold"); doc.text("Nama", labelX1, lineY);
      doc.setFont("helvetica", "normal"); doc.text(`:  ${peserta.nama}`, valueX1, lineY);
      doc.setFont("helvetica", "bold"); doc.text("Instansi", labelX2, lineY);
      doc.setFont("helvetica", "normal"); doc.text(`:  ${peserta.instansi}`, valueX2, lineY);

      doc.setFont("helvetica", "bold"); doc.text("Divisi", labelX1, lineY + lineHeight);
      doc.setFont("helvetica", "normal"); doc.text(`:  ${peserta.divisi}`, valueX1, lineY + lineHeight);
      doc.setFont("helvetica", "bold"); doc.text("Tanggal Cetak", labelX2, lineY + lineHeight);
      doc.setFont("helvetica", "normal"); doc.text(`:  ${new Date().toLocaleDateString("id-ID")}`, valueX2, lineY + lineHeight);

      autoTable(doc, {
        head: [["No", "Tanggal", "Hari", "Masuk", "Keluar", "Durasi", "Status"]],
        body: tableRows,
        startY: lineY + (lineHeight * 2) + 5,
        theme: 'striped',
        styles: { fontSize: 9, cellPadding: 3, font: "helvetica", textColor: [50, 50, 50], lineWidth: 0 },
        headStyles: { fillColor: [0, 102, 204], textColor: [255, 255, 255], fontStyle: 'bold', halign: 'center' },
        bodyStyles: { halign: 'center' },
        alternateRowStyles: { fillColor: [230, 242, 255] },
        columnStyles: {
            0: { cellWidth: 10 },
            1: { cellWidth: 30 },
            2: { cellWidth: 25 },
            3: { cellWidth: 25 },
            4: { cellWidth: 25 },
            5: { cellWidth: 25 },
            6: { cellWidth: 35, fontStyle: 'bold' }
        },
        didParseCell: (data) => {
          if (data.section === 'body' && data.column.index === 6) {
             const statusText = data.cell.raw as string;
             if (statusText === 'VALID') data.cell.styles.textColor = [34, 197, 94];
             else if (statusText === 'TERLAMBAT') data.cell.styles.textColor = [239, 68, 68];
          }
        }
      });

      const pageCount = doc.getNumberOfPages();
      for(let i = 1; i <= pageCount; i++) {
        doc.setPage(i);
        doc.setFontSize(8);
        doc.setTextColor(150);
        doc.text(`Halaman ${i} dari ${pageCount}`, 196, 290, { align: 'right' });
      }

      const safeName = peserta.nama.replace(/[^a-zA-Z0-9]/g, '_');
      const safePeriod = filterType === "MONTHLY" ? selectedMonth : "custom";
      doc.save(`Laporan_Detail_${safeName}_${safePeriod}.pdf`);

    } catch (err) {
      console.error("Export error:", err);
      alert("Gagal mengexport. Silakan coba lagi.");
    }
  };

  // ============ EXPORT LOGIC (REKAP UTAMA) ============
  const prepareExportData = () => {
    return filteredData.map((item) => ({
      Nama: item.pesertaMagangName,
      Divisi: item.pesertaMagang?.divisi || "-",
      Status: item.pesertaMagang?.status || "-",
      "Total Hari": item.totalHari,
      Hadir: item.hadir,
      "Tidak Hadir": item.tidakHadir,
      Terlambat: item.terlambat,
      "Mulai Magang": item.periode?.mulai ? new Date(item.periode.mulai).toLocaleDateString("id-ID") : "-",
      "Persentase Kehadiran": `${item.tingkatKehadiran}%`,
    }));
  };

  const handleExport = (format: "excel" | "pdf" | "csv") => {
    const fileName = `Laporan_Rekap_Absensi_${new Date().toISOString().split("T")[0]}`;

    if (format === "pdf") {
      const doc = new jsPDF({ orientation: 'landscape' });

      const startYContent = addModernHeader(
        doc,
        "LAPORAN REKAPITULASI ABSENSI",
        getPeriodLabel(),
        true
      );

      const tableColumn = [
        "Nama", "Divisi", "Status", "Total", "Hadir", "Absen", "Telat", "Mulai", "Performa"
      ];

      const tableRows = filteredData.map((item) => [
        item.pesertaMagangName,
        item.pesertaMagang?.divisi || "-",
        item.pesertaMagang?.status || "-",
        item.totalHari,
        item.hadir,
        item.tidakHadir,
        item.terlambat,
        item.periode?.mulai ? new Date(item.periode.mulai).toLocaleDateString("id-ID") : "-",
        `${item.tingkatKehadiran}%`
      ]);

      autoTable(doc, {
        head: [tableColumn],
        body: tableRows,
        startY: startYContent + 10,
        theme: 'striped',
        styles: { fontSize: 9, cellPadding: 3, font: "helvetica", textColor: [50, 50, 50], lineWidth: 0 },
        headStyles: { fillColor: [0, 102, 204], textColor: 255, fontStyle: 'bold', halign: 'center' },
        bodyStyles: { halign: 'center' },
        alternateRowStyles: { fillColor: [230, 242, 255] },
        columnStyles: { 0: { halign: 'left' } },
        didParseCell: (data) => {
           if(data.section === 'body' && data.column.index === 8) {
             const val = parseInt(data.cell.raw as string);
             if(val < 85) data.cell.styles.textColor = [239, 68, 68];
           }
        }
      });

      const pageCount = doc.getNumberOfPages();
      for(let i = 1; i <= pageCount; i++) {
        doc.setPage(i);
        doc.setFontSize(8);
        doc.setTextColor(150);
        doc.text(`Halaman ${i} dari ${pageCount}`, 283, 200, { align: 'right' });
      }

      doc.save(`${fileName}.pdf`);

    } else {
      const dataToExport = prepareExportData();
      const worksheet = XLSX.utils.json_to_sheet(dataToExport);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, "Laporan Absensi");

      if (format === "excel") {
        XLSX.writeFile(workbook, `${fileName}.xlsx`);
      } else if (format === "csv") {
        XLSX.writeFile(workbook, `${fileName}.csv`);
      }
    }
  };

  const renderPaginationButtons = () => {
    const buttons = [];
    const maxVisiblePages = 5;

    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }

    for (let i = startPage; i <= endPage; i++) {
      buttons.push(
        <Button
          key={i}
          size="1"
          variant={currentPage === i ? "solid" : "soft"}
          color={currentPage === i ? "indigo" : "gray"}
          onClick={() => setCurrentPage(i)}
          className="w-8 h-8 p-0 cursor-pointer"
        >
          {i}
        </Button>
      );
    }
    return buttons;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[50vh]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-sm text-gray-600">Memproses data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4 pb-10">

      {/* Page Title */}
      <div>
        <h1 className="text-xl font-bold text-gray-900 tracking-tight">Laporan Absensi</h1>
        <p className="text-xs text-gray-500 mt-0.5">Rekapitulasi dan analisis kehadiran peserta</p>
      </div>

      {/* Statistics Cards (Compact) */}
      <Grid columns={{ initial: "2", md: "4" }} gap="3">
        {[
          { label: "Total Peserta", value: stats.total, color: "text-blue-600", bg: "bg-blue-50/50", border: "border-blue-100" },
          { label: "Sangat Baik", value: stats.sangatBaik, color: "text-green-600", bg: "bg-green-50/50", border: "border-green-100" },
          { label: "Baik", value: stats.baik, color: "text-yellow-600", bg: "bg-yellow-50/50", border: "border-yellow-100" },
          { label: "Perlu Perhatian", value: stats.perluDiperhatikan, color: "text-red-600", bg: "bg-red-50/50", border: "border-red-100" },
        ].map((stat, idx) => (
          <div key={idx} className={`${stat.bg} ${stat.border} border rounded-lg p-3 flex flex-col justify-center`}>
            <span className="text-[10px] font-semibold text-gray-500 uppercase tracking-wider">{stat.label}</span>
            <span className={`text-xl font-bold ${stat.color} mt-0.5`}>{stat.value}</span>
          </div>
        ))}
      </Grid>

      {/* --- NEW & IMPROVED FILTER BAR --- */}
      <Card className="shadow-sm border border-gray-200 overflow-visible" style={{ padding: 0 }}>
        <div className="flex flex-col md:flex-row divide-y md:divide-y-0 md:divide-x divide-gray-100">

          {/* SECTION 1: SEARCH & WHO (Kiri) */}
          <div className="p-3 flex-1 flex flex-wrap gap-2 items-center bg-white">
            <div className="relative flex-1 min-w-[180px]">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-4 w-4 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Cari nama atau divisi..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-9 pr-3 py-1.5 w-full text-sm border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
              />
            </div>

            <Select.Root value={statusFilter} onValueChange={setStatusFilter} size="2">
              <Select.Trigger variant="surface" color="gray" radius="medium" className="min-w-[110px]">
                <Flex gap="2" align="center">
                   <Users className="w-3.5 h-3.5" />
                   {statusFilter === "Semua" ? "Status" : statusFilter}
                </Flex>
              </Select.Trigger>
              <Select.Content>
                <Select.Item value="Semua">Semua Status</Select.Item>
                <Select.Item value="AKTIF">Aktif</Select.Item>
                <Select.Item value="NONAKTIF">Nonaktif</Select.Item>
                <Select.Item value="SELESAI">Selesai</Select.Item>
              </Select.Content>
            </Select.Root>
          </div>

          {/* SECTION 2: TIME & ACTION (Kanan - "The Control Center") */}
          <div className="p-3 bg-gray-50/50 flex flex-wrap items-center gap-3 justify-end">

            {/* Filter Type Toggle (Segmented Look) */}
            <div className="flex bg-gray-200/60 p-1 rounded-lg">
              <button
                onClick={() => setFilterType("MONTHLY")}
                className={`px-3 py-1 text-xs font-medium rounded-md transition-all ${
                  filterType === "MONTHLY" ? "bg-white text-blue-700 shadow-sm" : "text-gray-600 hover:text-gray-900"
                }`}
              >
                Bulanan
              </button>
              <button
                onClick={() => setFilterType("CUSTOM")}
                className={`px-3 py-1 text-xs font-medium rounded-md transition-all ${
                  filterType === "CUSTOM" ? "bg-white text-blue-700 shadow-sm" : "text-gray-600 hover:text-gray-900"
                }`}
              >
                Rentang
              </button>
              <button
                onClick={() => setFilterType("ALL")}
                className={`px-3 py-1 text-xs font-medium rounded-md transition-all ${
                  filterType === "ALL" ? "bg-white text-blue-700 shadow-sm" : "text-gray-600 hover:text-gray-900"
                }`}
              >
                Semua
              </button>
            </div>

            {/* Dynamic Date Input */}
            <div className="flex items-center">
              {filterType === "MONTHLY" && (
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-2.5 flex items-center pointer-events-none">
                    <CalendarDays className="h-3.5 w-3.5 text-blue-600" />
                  </div>
                  <input
                    type="month"
                    value={selectedMonth}
                    onChange={(e) => setSelectedMonth(e.target.value)}
                    className="pl-8 pr-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-md focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer hover:border-blue-300 transition-colors h-8"
                  />
                </div>
              )}

              {filterType === "CUSTOM" && (
                <div className="flex items-center gap-1 bg-white border border-gray-200 rounded-md px-2 py-1 h-8">
                  <input
                    type="date"
                    className="text-xs border-none focus:ring-0 p-0 text-gray-600"
                    value={dateRange.startDate}
                    onChange={(e) => setDateRange((prev) => ({ ...prev, startDate: e.target.value }))}
                  />
                  <span className="text-gray-300">-</span>
                  <input
                    type="date"
                    className="text-xs border-none focus:ring-0 p-0 text-gray-600"
                    value={dateRange.endDate}
                    onChange={(e) => setDateRange((prev) => ({ ...prev, endDate: e.target.value }))}
                  />
                </div>
              )}

              {filterType === "ALL" && (
                <span className="text-xs text-gray-400 font-medium px-2 italic h-8 flex items-center">Semua Data</span>
              )}
            </div>

            <div className="h-6 w-px bg-gray-300 mx-1 hidden md:block"></div>

            {/* Export Action (Centered and Sized Perfectly) */}
            <DropdownMenu.Root>
              <DropdownMenu.Trigger>
                <Button
                  size="2"
                  className="cursor-pointer bg-blue-600 hover:bg-blue-700 text-white shadow-sm transition-all active:scale-95 h-8 px-3 flex items-center justify-center gap-2"
                >
                  <Download className="h-3.5 w-3.5" />
                  <span className="text-xs font-medium">Export</span>
                  <ChevronDown className="h-3 w-3 opacity-70" />
                </Button>
              </DropdownMenu.Trigger>
              <DropdownMenu.Content align="end" variant="soft">
                <Text size="1" color="gray" className="px-3 py-1 block mb-1">Pilih Format</Text>
                <DropdownMenu.Item onClick={() => handleExport("excel")} className="cursor-pointer">
                  <FileSpreadsheet className="w-3.5 h-3.5 mr-2 text-green-600" /> <span className="text-xs">Excel Workbook</span>
                </DropdownMenu.Item>
                <DropdownMenu.Item onClick={() => handleExport("pdf")} className="cursor-pointer">
                  <FileText className="w-3.5 h-3.5 mr-2 text-red-600" /> <span className="text-xs">PDF Document</span>
                </DropdownMenu.Item>
                <DropdownMenu.Item onClick={() => handleExport("csv")} className="cursor-pointer">
                  <File className="w-3.5 h-3.5 mr-2 text-blue-600" /> <span className="text-xs">CSV Data</span>
                </DropdownMenu.Item>
              </DropdownMenu.Content>
            </DropdownMenu.Root>

          </div>
        </div>
      </Card>

      {/* Table Section */}
      <Card className="shadow-sm overflow-hidden border border-gray-200">
        <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-white p-3">
          <Flex align="center" gap="2">
            <div className="bg-blue-50 p-1.5 rounded-md">
              <CalendarIcon className="w-4 h-4 text-blue-600"/>
            </div>
            <Text weight="bold" size="2" className="text-gray-900">
              Data Kehadiran
            </Text>
          </Flex>

          <Text size="1" className="text-gray-500 font-medium">
            {getPeriodLabel()}
          </Text>
        </Flex>

        <Table.Root variant="surface" size="1">
          <Table.Header>
            <Table.Row className="bg-gray-50/50">
              <Table.ColumnHeaderCell className="p-3 text-gray-600">Peserta</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600" align="center">Total</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600" align="center">Hadir</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600" align="center">Absen</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600" align="center">Telat</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600">Performa</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3 text-gray-600" align="center">Aksi</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {paginatedData.map((record, index) => (
              <Table.Row key={`${record.pesertaMagangId}-${index}`} className="hover:bg-blue-50/20 transition-colors group">
                <Table.Cell className="p-3">
                  <div className="flex items-center">
                    <Avatar
                      src={record.pesertaMagang?.avatar}
                      alt={record.pesertaMagangName}
                      name={record.pesertaMagangName}
                      size="sm"
                      showBorder
                      className="border-gray-200 shadow-sm"
                    />
                    <div className="ml-3">
                      <div className="text-xs font-bold text-gray-900 group-hover:text-blue-700 transition-colors">{record.pesertaMagangName}</div>
                      <div className="text-[10px] text-gray-500 font-medium">{record.pesertaMagang?.divisi || "-"}</div>
                    </div>
                  </div>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold tracking-wide ${
                      record.pesertaMagang?.status === "AKTIF" ? "bg-green-100 text-green-700" :
                      record.pesertaMagang?.status === "NONAKTIF" ? "bg-gray-100 text-gray-600" :
                      "bg-blue-100 text-blue-700"
                    }`}>
                    {record.pesertaMagang?.status || "-"}
                  </span>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle" align="center">
                  <span className="font-mono text-xs font-semibold text-gray-700">{record.totalHari}</span>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <span className="font-mono text-xs font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md">{record.hadir}</span>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <span className={`font-mono text-xs font-bold px-2 py-0.5 rounded-md ${record.tidakHadir > 0 ? 'text-red-600 bg-red-50' : 'text-gray-400'}`}>
                    {record.tidakHadir}
                  </span>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <span className={`font-mono text-xs font-bold px-2 py-0.5 rounded-md ${record.terlambat > 0 ? 'text-orange-600 bg-orange-50' : 'text-gray-400'}`}>
                    {record.terlambat}
                  </span>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle">
                  {getAttendanceRateBadge(record.tingkatKehadiran)}
                </Table.Cell>

                <Table.Cell className="p-3 align-middle" align="center">
                  <DropdownMenu.Root>
                    <DropdownMenu.Trigger>
                      <IconButton variant="outline" color="blue" size="1" className="cursor-pointer hover:bg-blue-50 hover:text-blue-600" title="Opsi Lainnya">
                        <Download width="14" height="14" />
                      </IconButton>
                    </DropdownMenu.Trigger>
                    <DropdownMenu.Content align="end">
                      <DropdownMenu.Label className="text-xs text-gray-400">Download Detail</DropdownMenu.Label>
                      <DropdownMenu.Item onClick={() => handleExportDetailForPeserta(record.pesertaMagangId, "pdf")} className="cursor-pointer">
                        <FileText className="w-3.5 h-3.5 mr-2 text-red-600" /> <span className="text-xs">PDF Report</span>
                      </DropdownMenu.Item>
                    </DropdownMenu.Content>
                  </DropdownMenu.Root>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table.Root>

        {/* Empty State */}
        {filteredData.length === 0 && (
          <Box className="text-center py-16 bg-gray-50/30">
            <div className="bg-white p-4 rounded-full inline-block shadow-sm mb-3 border border-gray-100">
              <ClockIcon className="h-8 w-8 text-gray-300" />
            </div>
            <Flex direction="column" justify="center" gap="1">
              <Text size="2" color="gray" weight="bold">Tidak ada data ditemukan</Text>
              <Text size="1" color="gray">Coba ubah filter periode atau kata kunci pencarian</Text>
            </Flex>
          </Box>
        )}

        {/* Pagination Footer */}
        {filteredData.length > 0 && (
          <Flex justify="between" align="center" p="3" className="border-t border-gray-100 bg-gray-50/50">
            <div className="flex items-center gap-2">
               <Text size="1" color="gray">Show:</Text>
               <Select.Root value={itemsPerPage} onValueChange={setItemsPerPage} size="1">
                <Select.Trigger variant="ghost" color="gray" />
                <Select.Content position="popper">
                  <Select.Item value="20">20</Select.Item>
                  <Select.Item value="50">50</Select.Item>
                  <Select.Item value="100">100</Select.Item>
                  <Select.Item value="All">All</Select.Item>
                </Select.Content>
              </Select.Root>
            </div>

            <Flex gap="1" align="center">
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(curr => Math.max(1, curr - 1))} className="cursor-pointer">
                <ChevronLeftIcon width="14" height="14" />
              </Button>
              <span className="text-xs text-gray-500 font-medium px-2">Page {currentPage} of {totalPages}</span>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(curr => Math.min(totalPages, curr + 1))} className="cursor-pointer">
                <ChevronRightIcon width="14" height="14" />
              </Button>
            </Flex>
          </Flex>
        )}
      </Card>
    </div>
  );
}