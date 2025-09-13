import { useState } from "react";
import { Download, ChevronDown } from "lucide-react";
import type { LaporanAbsensi, PesertaMagang } from "../types";
import {
  Box,
  Button,
  Card,
  DropdownMenu,
  Flex,
  Grid,
  IconButton,
  Select,
  Table,
  Text,
  TextField,
} from "@radix-ui/themes";
import {
  CalendarIcon,
  MagnifyingGlassIcon,
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";

// Mock data for attendance reports matching LaporanAbsensi interface
const attendanceReports: LaporanAbsensi[] = [
  {
    pesertaMagangId: "1",
    pesertaMagangName: "Ahmad Rizki Pratama",
    totalHari: 22,
    hadir: 20,
    tidakHadir: 1,
    terlambat: 1,
    tingkatKehadiran: 95,
    periode: {
      mulai: "2024-01-01",
    },
  },
  {
    pesertaMagangId: "2",
    pesertaMagangName: "Siti Nurhaliza",
    totalHari: 22,
    hadir: 19,
    tidakHadir: 0,
    terlambat: 2,
    tingkatKehadiran: 100,
    periode: {
      mulai: "2024-01-01",
    },
  },
  {
    pesertaMagangId: "3",
    pesertaMagangName: "Budi Santoso",
    totalHari: 22,
    hadir: 18,
    tidakHadir: 2,
    terlambat: 1,
    tingkatKehadiran: 86,
    periode: {
      mulai: "2024-01-01",
    },
  },
  {
    pesertaMagangId: "4",
    pesertaMagangName: "Dewi Sartika",
    totalHari: 22,
    hadir: 21,
    tidakHadir: 0,
    terlambat: 0,
    tingkatKehadiran: 100,
    periode: {
      mulai: "2024-01-01",
    },
  },
  {
    pesertaMagangId: "5",
    pesertaMagangName: "Eko Prasetyo",
    totalHari: 22,
    hadir: 17,
    tidakHadir: 3,
    terlambat: 1,
    tingkatKehadiran: 82,
    periode: {
      mulai: "2024-01-01",
    },
  },
];

// Mock peserta magang data for status filtering
const pesertaMagangData: PesertaMagang[] = [
  {
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
  {
    id: "2",
    nama: "Siti Nurhaliza",
    username: "siti",
    divisi: "Marketing",
    universitas: "Universitas Gadjah Mada",
    nomorHp: "08123456790",
    tanggalMulai: "2024-01-01",
    tanggalSelesai: "2024-06-30",
    status: "Aktif",
    createdAt: "2024-01-01",
    updatedAt: "2024-01-01",
  },
  {
    id: "3",
    nama: "Budi Santoso",
    username: "budi",
    divisi: "Finance",
    universitas: "Institut Teknologi Bandung",
    nomorHp: "08123456791",
    tanggalMulai: "2023-07-01",
    tanggalSelesai: "2023-12-31",
    status: "Selesai",
    createdAt: "2023-07-01",
    updatedAt: "2023-12-31",
  },
  {
    id: "4",
    nama: "Dewi Sartika",
    username: "dewi",
    divisi: "HR",
    universitas: "Universitas Diponegoro",
    nomorHp: "08123456792",
    tanggalMulai: "2024-01-01",
    tanggalSelesai: "2024-06-30",
    status: "Nonaktif",
    createdAt: "2024-01-01",
    updatedAt: "2024-02-15",
  },
  {
    id: "5",
    nama: "Eko Prasetyo",
    username: "eko",
    divisi: "Operations",
    universitas: "Universitas Brawijaya",
    nomorHp: "08123456793",
    tanggalMulai: "2024-01-01",
    tanggalSelesai: "2024-06-30",
    status: "Aktif",
    createdAt: "2024-01-01",
    updatedAt: "2024-01-01",
  },
];

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

export default function Laporan() {
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const startDate = "1 Januari 2024";
  const endDate = "31 Januari 2024";

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
            <DropdownMenu.Item onClick={() => console.log("Generate Excel")}>
              <Download className="h-4 w-4 mr-2" />
              Excel (.xlsx)
            </DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => console.log("Generate PDF")}>
              <Download className="h-4 w-4 mr-2" />
              PDF
            </DropdownMenu.Item>
            <DropdownMenu.Item onClick={() => console.log("Generate CSV")}>
              <Download className="h-4 w-4 mr-2" />
              CSV
            </DropdownMenu.Item>
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </div>

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
              <IconButton variant="surface" color="gray" className="ml-2">
                <MagnifyingGlassIcon width="18" height="18" />
              </IconButton>
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
                  <Select.Item value="Aktif">Aktif</Select.Item>
                  <Select.Item value="Nonaktif">Nonaktif</Select.Item>
                  <Select.Item value="Selesai">Selesai</Select.Item>
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
                <Table.ColumnHeaderCell>Nama Peserta Magang</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Total Hari</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Hadir</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Tidak Hadir</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Terlambat</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Periode Mulai</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Persentase Kehadiran</Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {filteredData.map((record, index) => (
                <Table.Row key={`${record.pesertaMagangId}-${index}`} className="hover:bg-gray-50">
                  <Table.Cell>
                    <Text size="2">{record.pesertaMagangName}</Text>
                  </Table.Cell>
                  <Table.Cell>
                    <span
                      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                        record.pesertaMagang?.status === "Aktif"
                          ? "bg-green-100 text-green-800"
                          : record.pesertaMagang?.status === "Nonaktif"
                          ? "bg-gray-100 text-gray-800"
                          : "bg-blue-100 text-blue-800"
                      }`}
                    >
                      {record.pesertaMagang?.status || "Unknown"}
                    </span>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center">{record.totalHari}</Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="green">{record.hadir}</Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="red">{record.tidakHadir}</Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="orange">{record.terlambat}</Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" align="center" color="gray">
                      {new Date(record.periode.mulai).toLocaleDateString("id-ID")}
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
