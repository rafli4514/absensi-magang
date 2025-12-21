import { useState, useEffect } from "react";
import {
  Download,
  ChevronDown,
  FileSpreadsheet,
  FileText,
  File
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

// Import services & Components
import dashboardService from "../services/dashboardService";
import pesertaMagangService from "../services/pesertaMagangService";
import absensiService from "../services/absensiService";
import Avatar from "../components/Avatar";
import type { Absensi } from "../types";

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

  // Filters
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [dateRange, setDateRange] = useState({
    startDate: "",
    endDate: "",
  });

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState<string>("20");

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

  // Reset page when filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, statusFilter, dateRange, itemsPerPage]);

  // Pagination Logic
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

  // ============ EXPORT LOGIC ============
  const handleExportDetailForPeserta = async (
    pesertaId: string,
    format: "excel" | "pdf" | "csv"
  ) => {
    // ... (Your export logic remains the same)
    alert("Fitur export detail akan berjalan di sini.");
  };

  const prepareExportData = () => {
    return filteredData.map((item) => ({
      Nama: item.pesertaMagangName,
      Divisi: item.pesertaMagang?.divisi || "-",
      Status: item.pesertaMagang?.status || "-",
      "Total": item.totalHari,
      Hadir: item.hadir,
      "Absen": item.tidakHadir,
      Telat: item.terlambat,
      "Mulai": item.periode?.mulai ? new Date(item.periode.mulai).toLocaleDateString("id-ID") : "-",
      "Persentase": `${item.tingkatKehadiran}%`,
    }));
  };

  const handleExport = (format: "excel" | "pdf" | "csv") => {
    // ... (Your export logic remains the same)
    alert("Fitur export rekap akan berjalan di sini.");
  };

  // --- Pagination Render Helpers ---
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

  // ============ RENDER UI ============
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

      {/* Page Header */}
      <div className="flex flex-row justify-between items-center gap-4">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">Laporan Absensi</h1>
          <p className="text-xs text-gray-500 mt-0.5">Rekapitulasi kehadiran peserta magang</p>
        </div>

        {/* General Export Button (REKAP) */}
        <DropdownMenu.Root>
          <DropdownMenu.Trigger>
            <Button size="2" className="cursor-pointer bg-blue-600 hover:bg-blue-700 text-white shadow-sm">
              <Download className="h-3.5 w-3.5 mr-1.5" />
              Export
              <ChevronDown className="h-3.5 w-3.5 ml-1 opacity-70" />
            </Button>
          </DropdownMenu.Trigger>
          <DropdownMenu.Content align="end" variant="soft">
            <DropdownMenu.Item onClick={() => handleExport("excel")} className="cursor-pointer">
              <FileSpreadsheet className="w-3.5 h-3.5 mr-2 text-green-600" /> <span className="text-xs">Excel</span>
            </DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => handleExport("pdf")} className="cursor-pointer">
              <FileText className="w-3.5 h-3.5 mr-2 text-red-600" /> <span className="text-xs">PDF</span>
            </DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => handleExport("csv")} className="cursor-pointer">
              <File className="w-3.5 h-3.5 mr-2 text-blue-600" /> <span className="text-xs">CSV</span>
            </DropdownMenu.Item>
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </div>

      {/* Statistics Cards */}
      <Grid columns={{ initial: "2", md: "4" }} gap="3">
        {[
          { label: "Total Peserta", value: stats.total, sub: "Terdaftar", color: "text-gray-900", bg: "bg-white" },
          { label: "Sangat Baik", value: stats.sangatBaik, sub: "≥95%", color: "text-green-600", bg: "bg-green-50/50" },
          { label: "Baik", value: stats.baik, sub: "85-94%", color: "text-yellow-600", bg: "bg-yellow-50/50" },
          { label: "Perlu Perhatian", value: stats.perluDiperhatikan, sub: "<85%", color: "text-red-600", bg: "bg-red-50/50" },
        ].map((stat, idx) => (
          <Card key={idx} className={`${stat.bg} shadow-sm border border-gray-100`}>
            <Flex direction="column" p="3">
              <Text size="1" weight="medium" color="gray" className="uppercase tracking-wider">
                {stat.label}
              </Text>
              <Text size="6" weight="bold" className={`my-0.5 ${stat.color}`}>
                {stat.value}
              </Text>
              <Text size="1" color="gray" className="text-[10px]">
                {stat.sub}
              </Text>
            </Flex>
          </Card>
        ))}
      </Grid>

      {/* Filters Section */}
      <Card className="shadow-sm">
        <Box p="3">
          <Flex direction="column" gap="3">
            <Flex gap="3" wrap="wrap" align="center" justify="between">
              {/* Search */}
              <div className="flex-1 min-w-[200px]">
                <TextField.Root
                  size="2"
                  color="indigo"
                  placeholder="Cari nama/divisi..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full"
                  radius="large"
                >
                  <TextField.Slot>
                    <MixerHorizontalIcon height="14" width="14" />
                  </TextField.Slot>
                </TextField.Root>
              </div>

              {/* Filters Right Side */}
              <Flex gap="2" align="center" wrap="wrap" className="justify-end flex-1 sm:flex-none">
                <Select.Root
                  size="2"
                  defaultValue="Semua"
                  value={statusFilter}
                  onValueChange={(value) => setStatusFilter(value)}
                >
                  <Select.Trigger color="indigo" radius="large" className="min-w-[120px]" placeholder="Status" />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua</Select.Item>
                    <Select.Item value="AKTIF">Aktif</Select.Item>
                    <Select.Item value="NONAKTIF">Nonaktif</Select.Item>
                    <Select.Item value="SELESAI">Selesai</Select.Item>
                  </Select.Content>
                </Select.Root>

                <div className="flex items-center gap-2 bg-gray-50 px-2 py-1 rounded-lg border border-gray-200">
                  <input
                    type="date"
                    className="bg-transparent border-none text-xs text-gray-700 focus:ring-0 cursor-pointer p-0"
                    value={dateRange.startDate}
                    onChange={(e) => setDateRange((prev) => ({ ...prev, startDate: e.target.value }))}
                  />
                  <span className="text-gray-400 text-xs">-</span>
                  <input
                    type="date"
                    className="bg-transparent border-none text-xs text-gray-700 focus:ring-0 cursor-pointer p-0"
                    value={dateRange.endDate}
                    onChange={(e) => setDateRange((prev) => ({ ...prev, endDate: e.target.value }))}
                  />
                  <Button onClick={handleDateRangeChange} size="1" color="indigo" radius="full" variant="ghost" className="ml-1 h-6 w-6 p-0 cursor-pointer">
                    <ClockIcon width="14" height="14" />
                  </Button>
                </div>
              </Flex>
            </Flex>
          </Flex>
        </Box>
      </Card>

      {/* Table Data */}
      <Card className="shadow-sm overflow-hidden">
        <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-gray-50/50" p="3">
          <Flex align="center" gap="2">
            <CalendarIcon width="16" height="16" className="text-gray-700"/>
            <Text weight="bold" size="2" className="text-gray-900">Data Kehadiran</Text>
          </Flex>

          <Flex align="center" gap="3">
            {/* Show Rows Dropdown */}
            <Flex align="center" gap="2">
              <Text size="1" color="gray">Show:</Text>
              <Select.Root
                value={itemsPerPage}
                onValueChange={setItemsPerPage}
                size="1"
              >
                <Select.Trigger variant="ghost" color="gray" />
                <Select.Content position="popper">
                  <Select.Item value="20">20</Select.Item>
                  <Select.Item value="50">50</Select.Item>
                  <Select.Item value="100">100</Select.Item>
                  <Select.Item value="All">All</Select.Item>
                </Select.Content>
              </Select.Root>
            </Flex>
            <Text size="1" color="gray" className="hidden sm:inline">
              {startDateDisplay ? `${startDateDisplay} - ${endDateDisplay}` : "Semua Periode"}
            </Text>
          </Flex>
        </Flex>

        <Table.Root variant="surface" size="1">
          <Table.Header>
            <Table.Row className="bg-gray-50/80">
              <Table.ColumnHeaderCell className="p-3">Peserta</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Total</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Hadir</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Absen</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Telat</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Mulai</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Performa</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Aksi</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {paginatedData.map((record, index) => (
              <Table.Row key={`${record.pesertaMagangId}-${index}`} className="hover:bg-blue-50/30 transition-colors">
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
                      <div className="text-xs font-semibold text-gray-900">{record.pesertaMagangName}</div>
                      <div className="text-[10px] text-gray-500 font-medium">{record.pesertaMagang?.divisi || "-"}</div>
                    </div>
                  </div>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium ${
                      record.pesertaMagang?.status === "AKTIF" ? "bg-green-100 text-green-800" :
                      record.pesertaMagang?.status === "NONAKTIF" ? "bg-gray-100 text-gray-800" :
                      "bg-blue-100 text-blue-800"
                    }`}>
                    {record.pesertaMagang?.status || "-"}
                  </span>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle" align="center">
                  <span className="font-mono text-xs font-medium">{record.totalHari}</span>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <span className="font-mono text-xs font-bold text-green-600 bg-green-50 px-1.5 py-0.5 rounded">{record.hadir}</span>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <span className={`font-mono text-xs font-bold px-1.5 py-0.5 rounded ${record.tidakHadir > 0 ? 'text-red-600 bg-red-50' : 'text-gray-400'}`}>
                    {record.tidakHadir}
                  </span>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <span className={`font-mono text-xs font-bold px-1.5 py-0.5 rounded ${record.terlambat > 0 ? 'text-orange-600 bg-orange-50' : 'text-gray-400'}`}>
                    {record.terlambat}
                  </span>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle">
                  <Text size="1" color="gray">
                    {record.periode?.mulai ? new Date(record.periode.mulai).toLocaleDateString("id-ID", { day: 'numeric', month: 'short', year: '2-digit' }) : '-'}
                  </Text>
                </Table.Cell>

                <Table.Cell className="p-3 align-middle">
                  {getAttendanceRateBadge(record.tingkatKehadiran)}
                </Table.Cell>

                <Table.Cell className="p-3 align-middle" align="center">
                  <DropdownMenu.Root>
                    <DropdownMenu.Trigger>
                      <IconButton variant="outline" color="blue" size="1" highContrast className="cursor-pointer" title="Download Detail">
                        <Download width="14" height="14" />
                      </IconButton>
                    </DropdownMenu.Trigger>
                    <DropdownMenu.Content align="end">
                      <DropdownMenu.Item onClick={() => handleExportDetailForPeserta(record.pesertaMagangId, "excel")} className="cursor-pointer">
                        <FileSpreadsheet className="w-3.5 h-3.5 mr-2 text-green-600" /> <span className="text-xs">Excel</span>
                      </DropdownMenu.Item>
                      <DropdownMenu.Item onClick={() => handleExportDetailForPeserta(record.pesertaMagangId, "pdf")} className="cursor-pointer">
                        <FileText className="w-3.5 h-3.5 mr-2 text-red-600" /> <span className="text-xs">PDF</span>
                      </DropdownMenu.Item>
                      <DropdownMenu.Item onClick={() => handleExportDetailForPeserta(record.pesertaMagangId, "csv")} className="cursor-pointer">
                        <File className="w-3.5 h-3.5 mr-2 text-blue-600" /> <span className="text-xs">CSV</span>
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
          <Box className="text-center py-10 bg-gray-50/30">
            <div className="bg-white p-3 rounded-full inline-block shadow-sm mb-3">
              <ClockIcon className="h-6 w-6 text-gray-300" />
            </div>
            <Flex direction="column" justify="center">
              <Text size="2" color="gray" weight="medium">Tidak ada data ditemukan</Text>
            </Flex>
          </Box>
        )}

        {/* Pagination Footer */}
        {filteredData.length > 0 && itemsPerPage !== "All" && (
          <Flex justify="between" align="center" p="3" className="border-t border-gray-100 bg-gray-50/30">
            <Text size="1" color="gray">
              Showing <span className="font-medium text-gray-900">{(currentPage - 1) * pageSize + 1}</span> to{" "}
              <span className="font-medium text-gray-900">{Math.min(currentPage * pageSize, totalItems)}</span> of{" "}
              <span className="font-medium text-gray-900">{totalItems}</span> entries
            </Text>

            <Flex gap="1" align="center">
              <Button
                variant="soft"
                color="gray"
                size="1"
                disabled={currentPage === 1}
                onClick={() => setCurrentPage(1)}
                className="cursor-pointer"
              >
                <DoubleArrowLeftIcon width="12" height="12" />
              </Button>
              <Button
                variant="soft"
                color="gray"
                size="1"
                disabled={currentPage === 1}
                onClick={() => setCurrentPage(curr => Math.max(1, curr - 1))}
                className="cursor-pointer"
              >
                <ChevronLeftIcon width="12" height="12" />
              </Button>

              <div className="flex gap-1 mx-1">
                {renderPaginationButtons()}
              </div>

              <Button
                variant="soft"
                color="gray"
                size="1"
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage(curr => Math.min(totalPages, curr + 1))}
                className="cursor-pointer"
              >
                <ChevronRightIcon width="12" height="12" />
              </Button>
              <Button
                variant="soft"
                color="gray"
                size="1"
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage(totalPages)}
                className="cursor-pointer"
              >
                <DoubleArrowRightIcon width="12" height="12" />
              </Button>
            </Flex>
          </Flex>
        )}
      </Card>
    </div>
  );
}