import { useState, useEffect } from "react";
import {
  Download,
  ChevronDown,
  FileSpreadsheet,
  FileText,
  Search,
  Users
} from "lucide-react";
import type { LaporanAbsensi, PesertaMagang } from "../types";

// Import Components Radix UI Themes
import {
  Box as RBox,
  Button as RButton,
  Card as RCard,
  DropdownMenu as RDropdownMenu,
  Flex as RFlex,
  Grid as RGrid,
  Select as RSelect,
  Table as RTable,
  Text as RText,
  IconButton as RIconButton
} from "@radix-ui/themes";

// Import Icons dari Radix UI React Icons
import {
  CalendarIcon,
  ClockIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
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

// --- FIX: Definisi Interface Eksplisit ---
interface GroupedLogItem {
  date: Date;
  status: string;
  masuk?: string;
  masukDate?: Date;
  keluar?: string;
  keluarDate?: Date;
}

const getAttendanceRateBadge = (rate: number) => {
  if (rate >= 95) {
    return <span className="inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full bg-green-100 text-green-800 border border-green-200">Sangat Baik</span>;
  } else if (rate >= 85) {
    return <span className="inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full bg-yellow-100 text-yellow-800 border border-yellow-200">Baik</span>;
  } else {
    return <span className="inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full bg-red-100 text-red-800 border border-red-200">Perlu Diperhatikan</span>;
  }
};

export default function LaporanPage() {
  const [attendanceReports, setAttendanceReports] = useState<LaporanAbsensi[]>([]);
  const [pesertaMagangData, setPesertaMagangData] = useState<PesertaMagang[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [filterType, setFilterType] = useState<"ALL" | "MONTHLY" | "CUSTOM">("MONTHLY");
  const [selectedMonth, setSelectedMonth] = useState(new Date().toISOString().slice(0, 7));
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");

  const [dateRange, setDateRange] = useState({ startDate: "", endDate: "" });
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState<string>("20");

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

      if (attendanceResponse.success && attendanceResponse.data) setAttendanceReports(attendanceResponse.data);
      if (pesertaResponse.success && pesertaResponse.data) setPesertaMagangData(pesertaResponse.data);
    } catch (err: unknown) {
      console.error("Fetch laporan data error:", err);
      setError("Failed to fetch laporan data");
    } finally {
      setLoading(false);
    }
  };

  const combinedData = attendanceReports.map((report) => {
    const peserta = pesertaMagangData.find((p) => p.id === report.pesertaMagangId);
    return { ...report, pesertaMagang: peserta };
  });

  const filteredData = combinedData.filter((report) => {
    const matchesSearch = report.pesertaMagangName.toLowerCase().includes(searchTerm.toLowerCase()) || report.pesertaMagang?.divisi.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === "Semua" || report.pesertaMagang?.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  useEffect(() => { setCurrentPage(1); }, [searchTerm, statusFilter, dateRange, itemsPerPage]);

  const totalItems = filteredData.length;
  const pageSize = itemsPerPage === "All" ? totalItems : parseInt(itemsPerPage);
  const totalPages = Math.ceil(totalItems / pageSize);
  const paginatedData = filteredData.slice((currentPage - 1) * pageSize, currentPage * pageSize);

  const stats = {
    total: attendanceReports.length,
    sangatBaik: attendanceReports.filter((r) => r.tingkatKehadiran >= 95).length,
    baik: attendanceReports.filter((r) => r.tingkatKehadiran >= 85 && r.tingkatKehadiran < 95).length,
    perluDiperhatikan: attendanceReports.filter((r) => r.tingkatKehadiran < 85).length,
  };

  const getPeriodLabel = () => {
    if (filterType === "ALL") return "Periode: Selama Magang (Keseluruhan)";
    if (dateRange.startDate && dateRange.endDate) {
        if (filterType === "MONTHLY") {
             return `Periode: ${new Date(dateRange.startDate).toLocaleDateString("id-ID", { month: "long", year: "numeric" })}`;
        }
        return `Periode: ${new Date(dateRange.startDate).toLocaleDateString("id-ID")} - ${new Date(dateRange.endDate).toLocaleDateString("id-ID")}`;
    }
    return "Periode: -";
  };

  const addModernHeader = (doc: jsPDF, title: string, subtitle: string) => {
    const PLN_BLUE = "#0066CC";
    const DARK_GREY = "#333333";
    const pageWidth = doc.internal.pageSize.getWidth();
    const margin = 14;
    const lineEnd = pageWidth - margin;

    try { doc.addImage(LogoPLN, "PNG", margin, 10, 50, 20); } catch (e) { console.warn("Logo load failed", e); }

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

  const handleExportDetailForPeserta = async (pesertaId: string, format: "excel" | "pdf" | "csv") => {
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
      
      // FIX: Gunakan Interface
      const groupedLogs: Record<string, GroupedLogItem> = {};
      logs.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

      logs.forEach(log => {
        const dateKey = new Date(log.timestamp).toLocaleDateString("en-CA");
        if (!groupedLogs[dateKey]) groupedLogs[dateKey] = { date: new Date(log.timestamp), status: log.status };
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

      // FIX: Gunakan Interface GroupedLogItem di map parameter
      const tableRows = Object.values(groupedLogs).map((item: GroupedLogItem, index: number) => {
        let durasi = "-";
        if (item.masukDate && item.keluarDate) {
          const diffMs = item.keluarDate.getTime() - item.masukDate.getTime();
          durasi = `${Math.floor(diffMs / 3600000)}j ${Math.floor((diffMs % 3600000) / 60000)}m`;
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
      const startYContent = addModernHeader(doc, "LAPORAN DETAIL ABSENSI", getPeriodLabel());
      
      doc.setFont("helvetica", "bold"); doc.setFontSize(10); doc.setTextColor(50, 50, 50);
      doc.text(`Nama: ${peserta.nama}`, 14, startYContent + 10);
      doc.text(`Divisi: ${peserta.divisi}`, 14, startYContent + 16);

      autoTable(doc, {
        head: [["No", "Tanggal", "Hari", "Masuk", "Keluar", "Durasi", "Status"]],
        body: tableRows,
        startY: startYContent + 22,
        theme: 'striped',
        styles: { fontSize: 9 },
        headStyles: { fillColor: [0, 102, 204] }
      });
      doc.save(`Laporan_Detail_${peserta.nama}.pdf`);
    } catch (err) {
      console.error("Export error:", err);
      alert("Gagal mengexport. Silakan coba lagi.");
    }
  };

  const handleExport = (format: "excel" | "pdf" | "csv") => {
    const fileName = `Laporan_Rekap_Absensi_${new Date().toISOString().split("T")[0]}`;
    if (format === "pdf") {
      const doc = new jsPDF({ orientation: 'landscape' });
      const startYContent = addModernHeader(doc, "LAPORAN REKAPITULASI ABSENSI", getPeriodLabel());
      const tableRows = filteredData.map((item) => [
        item.pesertaMagangName,
        item.pesertaMagang?.divisi || "-",
        item.pesertaMagang?.status || "-",
        item.totalHari, item.hadir, item.tidakHadir, item.terlambat,
        `${item.tingkatKehadiran}%`
      ]);
      autoTable(doc, {
        head: [["Nama", "Divisi", "Status", "Total", "Hadir", "Absen", "Telat", "Performa"]],
        body: tableRows,
        startY: startYContent + 10,
        theme: 'striped',
        headStyles: { fillColor: [0, 102, 204] }
      });
      doc.save(`${fileName}.pdf`);
    } else {
        const dataToExport = filteredData.map((item) => ({
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
    const endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }

    for (let i = startPage; i <= endPage; i++) {
      buttons.push(
        <RButton key={i} size="1" variant={currentPage === i ? "solid" : "soft"} color={currentPage === i ? "indigo" : "gray"} onClick={() => setCurrentPage(i)} className="w-8 h-8 p-0 cursor-pointer">
          {i}
        </RButton>
      );
    }
    return buttons;
  };

  if (loading) return <div className="flex items-center justify-center h-[50vh]"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div></div>;

  return (
    <div className="space-y-4 pb-10">
      <div>
        <h1 className="text-xl font-bold text-gray-900 tracking-tight">Laporan Absensi</h1>
        <p className="text-xs text-gray-500 mt-0.5">Rekapitulasi dan analisis kehadiran peserta</p>
      </div>

      <RGrid columns={{ initial: "2", md: "4" }} gap="3">
        {[{ label: "Total Peserta", value: stats.total, color: "text-blue-600", bg: "bg-blue-50/50", border: "border-blue-100" },
          { label: "Sangat Baik", value: stats.sangatBaik, color: "text-green-600", bg: "bg-green-50/50", border: "border-green-100" },
          { label: "Baik", value: stats.baik, color: "text-yellow-600", bg: "bg-yellow-50/50", border: "border-yellow-100" },
          { label: "Perlu Perhatian", value: stats.perluDiperhatikan, color: "text-red-600", bg: "bg-red-50/50", border: "border-red-100" }
        ].map((stat, idx) => (
          <div key={idx} className={`${stat.bg} ${stat.border} border rounded-lg p-3 flex flex-col justify-center`}>
            <span className="text-[10px] font-semibold text-gray-500 uppercase tracking-wider">{stat.label}</span>
            <span className={`text-xl font-bold ${stat.color} mt-0.5`}>{stat.value}</span>
          </div>
        ))}
      </RGrid>

      <RCard className="shadow-sm border border-gray-200 overflow-visible" style={{ padding: 0 }}>
        <div className="flex flex-col md:flex-row divide-y md:divide-y-0 md:divide-x divide-gray-100">
          <div className="p-3 flex-1 flex flex-wrap gap-2 items-center bg-white">
            <div className="relative flex-1 min-w-[180px]">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none"><Search className="h-4 w-4 text-gray-400" /></div>
              <input type="text" placeholder="Cari nama atau divisi..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="pl-9 pr-3 py-1.5 w-full text-sm border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <RSelect.Root value={statusFilter} onValueChange={setStatusFilter} size="2">
              <RSelect.Trigger variant="surface" color="gray" radius="medium" className="min-w-[110px]">
                <RFlex gap="2" align="center"><Users className="w-3.5 h-3.5" />{statusFilter === "Semua" ? "Status" : statusFilter}</RFlex>
              </RSelect.Trigger>
              <RSelect.Content>
                <RSelect.Item value="Semua">Semua Status</RSelect.Item>
                <RSelect.Item value="AKTIF">Aktif</RSelect.Item>
                <RSelect.Item value="NONAKTIF">Nonaktif</RSelect.Item>
                <RSelect.Item value="SELESAI">Selesai</RSelect.Item>
              </RSelect.Content>
            </RSelect.Root>
          </div>

          <div className="p-3 bg-gray-50/50 flex flex-wrap items-center gap-3 justify-end">
            <div className="flex bg-gray-200/60 p-1 rounded-lg">
              {["MONTHLY", "CUSTOM", "ALL"].map(type => (
                <button
                  key={type}
                  // FIX: Casting eksplisit ke tipe yang valid
                  onClick={() => setFilterType(type as "MONTHLY" | "CUSTOM" | "ALL")}
                  className={`px-3 py-1 text-xs font-medium rounded-md transition-all ${filterType === type ? "bg-white text-blue-700 shadow-sm" : "text-gray-600"}`}
                >
                  {type === "MONTHLY" ? "Bulanan" : type === "CUSTOM" ? "Rentang" : "Semua"}
                </button>
              ))}
            </div>
            <div className="flex items-center">
              {filterType === "MONTHLY" && <input type="month" value={selectedMonth} onChange={(e) => setSelectedMonth(e.target.value)} className="pl-2 pr-3 py-1.5 text-sm border border-gray-200 rounded-md h-8" />}
              {filterType === "CUSTOM" && <div className="flex items-center gap-1 bg-white border border-gray-200 rounded-md px-2 py-1 h-8"><input type="date" className="text-xs border-none" value={dateRange.startDate} onChange={(e) => setDateRange(prev => ({ ...prev, startDate: e.target.value }))} /><span className="text-gray-300">-</span><input type="date" className="text-xs border-none" value={dateRange.endDate} onChange={(e) => setDateRange(prev => ({ ...prev, endDate: e.target.value }))} /></div>}
            </div>
            <RDropdownMenu.Root>
              <RDropdownMenu.Trigger>
                <RButton size="2" className="cursor-pointer bg-blue-600 text-white h-8 px-3 flex items-center gap-2"><Download className="h-3.5 w-3.5" /><span className="text-xs font-medium">Export</span><ChevronDown className="h-3 w-3 opacity-70" /></RButton>
              </RDropdownMenu.Trigger>
              <RDropdownMenu.Content align="end" variant="soft">
                <RText size="1" color="gray" className="px-3 py-1 block mb-1">Pilih Format</RText>
                <RDropdownMenu.Item onClick={() => handleExport("excel")} className="cursor-pointer"><FileSpreadsheet className="w-3.5 h-3.5 mr-2 text-green-600" /> <span className="text-xs">Excel Workbook</span></RDropdownMenu.Item>
                <RDropdownMenu.Item onClick={() => handleExport("pdf")} className="cursor-pointer"><FileText className="w-3.5 h-3.5 mr-2 text-red-600" /> <span className="text-xs">PDF Document</span></RDropdownMenu.Item>
              </RDropdownMenu.Content>
            </RDropdownMenu.Root>
          </div>
        </div>
      </RCard>

      {/* Table & Error display */}
      {error && <div className="bg-red-50 text-red-600 p-3 rounded text-sm">{error}</div>}

      <RCard className="shadow-sm overflow-hidden border border-gray-200">
        <RFlex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-white p-3">
          <RFlex align="center" gap="2"><div className="bg-blue-50 p-1.5 rounded-md"><CalendarIcon className="w-4 h-4 text-blue-600"/></div><RText weight="bold" size="2" className="text-gray-900">Data Kehadiran</RText></RFlex>
          <RText size="1" className="text-gray-500 font-medium">{getPeriodLabel()}</RText>
        </RFlex>

        <RTable.Root variant="surface" size="1">
          <RTable.Header>
            <RTable.Row className="bg-gray-50/50">
              <RTable.ColumnHeaderCell className="p-3">Peserta</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3">Status</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3" align="center">Total</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3" align="center">Hadir</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3" align="center">Absen</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3" align="center">Telat</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3">Performa</RTable.ColumnHeaderCell>
              <RTable.ColumnHeaderCell className="p-3" align="center">Aksi</RTable.ColumnHeaderCell>
            </RTable.Row>
          </RTable.Header>
          <RTable.Body>
            {paginatedData.map((record, index) => (
              <RTable.Row key={`${record.pesertaMagangId}-${index}`} className="hover:bg-blue-50/20 transition-colors group">
                <RTable.Cell className="p-3">
                  <div className="flex items-center"><Avatar src={record.pesertaMagang?.avatar} alt={record.pesertaMagangName} name={record.pesertaMagangName} size="sm" showBorder className="border-gray-200 shadow-sm" /><div className="ml-3"><div className="text-xs font-bold text-gray-900 group-hover:text-blue-700">{record.pesertaMagangName}</div><div className="text-[10px] text-gray-500 font-medium">{record.pesertaMagang?.divisi || "-"}</div></div></div>
                </RTable.Cell>
                <RTable.Cell className="p-3 align-middle"><span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold tracking-wide ${record.pesertaMagang?.status === "AKTIF" ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-600"}`}>{record.pesertaMagang?.status || "-"}</span></RTable.Cell>
                <RTable.Cell className="p-3 align-middle" align="center"><span className="font-mono text-xs font-semibold text-gray-700">{record.totalHari}</span></RTable.Cell>
                <RTable.Cell className="p-3 align-middle" align="center"><span className="font-mono text-xs font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md">{record.hadir}</span></RTable.Cell>
                <RTable.Cell className="p-3 align-middle" align="center"><span className={`font-mono text-xs font-bold px-2 py-0.5 rounded-md ${record.tidakHadir > 0 ? 'text-red-600 bg-red-50' : 'text-gray-400'}`}>{record.tidakHadir}</span></RTable.Cell>
                <RTable.Cell className="p-3 align-middle" align="center"><span className={`font-mono text-xs font-bold px-2 py-0.5 rounded-md ${record.terlambat > 0 ? 'text-orange-600 bg-orange-50' : 'text-gray-400'}`}>{record.terlambat}</span></RTable.Cell>
                <RTable.Cell className="p-3 align-middle">{getAttendanceRateBadge(record.tingkatKehadiran)}</RTable.Cell>
                <RTable.Cell className="p-3 align-middle" align="center">
                  <RDropdownMenu.Root>
                    <RDropdownMenu.Trigger><RIconButton variant="outline" color="blue" size="1" className="cursor-pointer hover:bg-blue-50"><Download width="14" height="14" /></RIconButton></RDropdownMenu.Trigger>
                    <RDropdownMenu.Content align="end"><RDropdownMenu.Label className="text-xs text-gray-400">Download Detail</RDropdownMenu.Label><RDropdownMenu.Item onClick={() => handleExportDetailForPeserta(record.pesertaMagangId, "pdf")} className="cursor-pointer"><FileText className="w-3.5 h-3.5 mr-2 text-red-600" /> <span className="text-xs">PDF Report</span></RDropdownMenu.Item></RDropdownMenu.Content>
                  </RDropdownMenu.Root>
                </RTable.Cell>
              </RTable.Row>
            ))}
          </RTable.Body>
        </RTable.Root>
        {filteredData.length === 0 && <RBox className="text-center py-16 bg-gray-50/30"><div className="bg-white p-4 rounded-full inline-block shadow-sm mb-3 border border-gray-100"><ClockIcon className="h-8 w-8 text-gray-300" /></div><RFlex direction="column" justify="center" gap="1"><RText size="2" color="gray" weight="bold">Tidak ada data ditemukan</RText></RFlex></RBox>}
        {filteredData.length > 0 && <RFlex justify="between" align="center" p="3" className="border-t border-gray-100 bg-gray-50/50"><div className="flex items-center gap-2"><RText size="1" color="gray">Show:</RText><RSelect.Root value={itemsPerPage} onValueChange={setItemsPerPage} size="1"><RSelect.Trigger variant="ghost" color="gray" /><RSelect.Content position="popper"><RSelect.Item value="20">20</RSelect.Item><RSelect.Item value="50">50</RSelect.Item><RSelect.Item value="100">100</RSelect.Item><RSelect.Item value="All">All</RSelect.Item></RSelect.Content></RSelect.Root></div><RFlex gap="1" align="center"><RButton variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(curr => Math.max(1, curr - 1))} className="cursor-pointer"><ChevronLeftIcon width="14" height="14" /></RButton><span className="text-xs text-gray-500 font-medium px-2">Page {currentPage} of {totalPages}</span><RButton variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(curr => Math.min(totalPages, curr + 1))} className="cursor-pointer"><ChevronRightIcon width="14" height="14" /></RButton></RFlex></RFlex>}
        
        {filteredData.length > 0 && (
           <div className="hidden">
             {renderPaginationButtons()}
           </div>
        )}
      </RCard>
    </div>
  );
}