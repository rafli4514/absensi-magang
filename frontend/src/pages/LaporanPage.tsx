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
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";

// Import services
import dashboardService from "../services/dashboardService";
import pesertaMagangService from "../services/pesertaMagangService";
import Avatar from "../components/Avatar";

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
  const [attendanceReports, setAttendanceReports] = useState<LaporanAbsensi[]>([]);
  const [pesertaMagangData, setPesertaMagangData] = useState<PesertaMagang[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [dateRange, setDateRange] = useState({
    startDate: "",
    endDate: "",
  });

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
        pesertaMagangService.getPesertaMagang()
      ]);

      if (attendanceResponse.success && attendanceResponse.data) {
        setAttendanceReports(attendanceResponse.data);
      }

      if (pesertaResponse.success && pesertaResponse.data) {
        setPesertaMagangData(pesertaResponse.data);
      }
    } catch (error: unknown) {
      console.error('Fetch laporan data error:', error);
      setError('Failed to fetch laporan data');
    } finally {
      setLoading(false);
    }
  };

  const handleDateRangeChange = () => {
    fetchData();
  };

  // Combine attendance reports with peserta magang data for filtering
  const combinedData = attendanceReports.map(report => {
    const peserta = pesertaMagangData.find(p => p.id === report.pesertaMagangId);
    return {
      ...report,
      pesertaMagang: peserta,
    };
  });

  const filteredData = combinedData.filter((report) => {
    const matchesSearch =
      report.pesertaMagangName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (report.pesertaMagang?.divisi.toLowerCase().includes(searchTerm.toLowerCase()));

    const matchesStatus =
      statusFilter === "Semua" || report.pesertaMagang?.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  // Statistics for reports
  const stats = {
    total: attendanceReports.length,
    sangatBaik: attendanceReports.filter(r => r.tingkatKehadiran >= 95).length,
    baik: attendanceReports.filter(r => r.tingkatKehadiran >= 85 && r.tingkatKehadiran < 95).length,
    perluDiperhatikan: attendanceReports.filter(r => r.tingkatKehadiran < 85).length,
  };

  const startDate = dateRange.startDate ? new Date(dateRange.startDate).toLocaleDateString("id-ID", { 
    day: "numeric", 
    month: "long", 
    year: "numeric" 
  }) : "1 Januari 2024";
  
  const endDate = dateRange.endDate ? new Date(dateRange.endDate).toLocaleDateString("id-ID", { 
    day: "numeric", 
    month: "long", 
    year: "numeric" 
  }) : "31 Januari 2024";

  const handleExport = (format: "excel" | "pdf" | "csv") => {
    // TODO: Implement export functionality
    console.log(`Exporting to ${format}`);
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
        <div className="flex justify-end">
          <DropdownMenu.Root>
            <DropdownMenu.Trigger>
              <Button className="flex items-center bg-blue-600 hover:bg-blue-700 text-white">
                <Download className="h-4 w-4 mr-2" />
                Generate Laporan
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
            <div className="flex items-center">
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
            <div className="flex items-center gap-2">
              <TextField.Root
                type="date"
                placeholder="Tanggal Mulai"
                value={dateRange.startDate}
                onChange={(e) => setDateRange(prev => ({ ...prev, startDate: e.target.value }))}
                size="2"
              />
              <TextField.Root
                type="date"
                placeholder="Tanggal Selesai"
                value={dateRange.endDate}
                onChange={(e) => setDateRange(prev => ({ ...prev, endDate: e.target.value }))}
                size="2"
              />
                <Button onClick={handleDateRangeChange} size="2">
                  <CalendarIcon className="h-4 w-4 mr-2" />
                  Terapkan
                </Button>
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
                      {new Date(record.periode.mulai).toLocaleDateString(
                        "id-ID"
                      )}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    {getAttendanceRateBadge(record.tingkatKehadiran)}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table.Root>
        </Card>
      </Box>
    </div>
  );
}