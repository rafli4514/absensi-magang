import { useState } from "react";
import type { PengajuanIzin } from "../types/index";
import {
  Box,
  Button,
  Card,
  Dialog,
  Flex,
  IconButton,
  Select,
  Table,
  TextField,
  Text,
  Grid,
} from "@radix-ui/themes";
import {
  EyeOpenIcon,
  MagnifyingGlassIcon,
  CheckCircledIcon,
  CrossCircledIcon,
  FileTextIcon,
  CalendarIcon,
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";

// Mock data - replace with actual API calls
const mockPengajuanIzin: PengajuanIzin[] = [
  {
    id: "1",
    pesertaMagangId: "1",
    pesertaMagang: {
      id: "1",
      nama: "Ahmad Rizki Pratama",
      username: "ahmad",
    divisi: "IT",
      universitas: "Universitas Indonesia",
    nomorHp: "08123456789",
      tanggalMulai: "2025-01-01",
      tanggalSelesai: "2025-06-30",
    status: "Aktif",
    avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=32&h=32&fit=crop&crop=face",
      createdAt: "2025-01-01",
      updatedAt: "2025-01-01",
    },
    tipe: "sakit",
    tanggalMulai: "2025-01-15",
    tanggalSelesai: "2025-01-16",
    alasan: "Demam tinggi dan perlu istirahat",
    status: "pending",
    diajukanPada: "2025-01-14T08:30:00Z",
    dokumenPendukung: "surat-dokter.pdf",
    createdAt: "2025-01-14T08:30:00Z",
  },
  {
    id: "2",
    pesertaMagangId: "2",
    pesertaMagang: {
      id: "2",
      nama: "Siti Nurhaliza",
      username: "siti",
      divisi: "Marketing",
      universitas: "Universitas Gadjah Mada",
      nomorHp: "08123456790",
      tanggalMulai: "2025-01-01",
      tanggalSelesai: "2025-06-30",
      status: "Aktif",
      avatar: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=32&h=32&fit=crop&crop=face",
      createdAt: "2025-01-01",
      updatedAt: "2025-01-01",
    },
    tipe: "izin",
    tanggalMulai: "2025-01-20",
    tanggalSelesai: "2025-01-20",
    alasan: "Menghadiri acara keluarga",
    status: "disetujui",
    diajukanPada: "2025-01-18T14:20:00Z",
    disetujuiOleh: "Admin",
    disetujuiPada: "2025-01-19T09:15:00Z",
    catatan: "Izin disetujui. Pastikan untuk catch up pekerjaan.",
    createdAt: "2025-01-18T14:20:00Z",
    updatedAt: "2025-01-19T09:15:00Z",
  },
  {
    id: "3",
    pesertaMagangId: "3",
    pesertaMagang: {
      id: "3",
      nama: "Budi Santoso",
      username: "budi",
      divisi: "Finance",
      universitas: "Institut Teknologi Bandung",
      nomorHp: "08123456791",
      tanggalMulai: "2025-01-01",
      tanggalSelesai: "2025-06-30",
      status: "Aktif",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=32&h=32&fit=crop&crop=face",
      createdAt: "2025-01-01",
      updatedAt: "2025-01-01",
    },
    tipe: "cuti",
    tanggalMulai: "2025-01-25",
    tanggalSelesai: "2025-01-27",
    alasan: "Liburan bersama keluarga",
    status: "ditolak",
    diajukanPada: "2025-01-22T16:45:00Z",
    disetujuiOleh: "Admin",
    disetujuiPada: "2025-01-23T10:30:00Z",
    catatan: "Ditolak karena periode sibuk proyek. Silakan ajukan di waktu lain.",
    createdAt: "2025-01-22T16:45:00Z",
    updatedAt: "2025-01-23T10:30:00Z",
  },
];

const StatusBadge = ({ status }: { status: PengajuanIzin["status"] }) => {
  const statusConfig = {
    pending: { color: "bg-yellow-100 text-yellow-800", label: "Menunggu" },
    disetujui: { color: "bg-green-100 text-green-800", label: "Disetujui" },
    ditolak: { color: "bg-red-100 text-red-800", label: "Ditolak" },
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

const TypeBadge = ({ tipe }: { tipe: PengajuanIzin["tipe"] }) => {
  const typeConfig = {
    sakit: { color: "text-red-600 border-red-200", label: "Sakit" },
    izin: { color: "text-blue-600 border-blue-200", label: "Izin" },
    cuti: { color: "text-purple-600 border-purple-200", label: "Cuti" },
  };

  const config = typeConfig[tipe];

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full border ${config.color}`}
    >
      {config.label}
    </span>
  );
};

export default function PengajuanIzinPage() {
  const [pengajuanIzin, setPengajuanIzin] = useState<PengajuanIzin[]>(mockPengajuanIzin);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");

  const filteredPengajuanIzin = pengajuanIzin.filter((item) => {
    const matchesSearch =
      item.pesertaMagang?.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.pesertaMagang?.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.alasan.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || item.status === statusFilter;

    const matchesType =
      typeFilter === "Semua" || item.tipe === typeFilter;

    return matchesSearch && matchesStatus && matchesType;
  });

  const handleApprove = (id: string, catatan: string = '') => {
    setPengajuanIzin(pengajuanIzin.map(item => 
      item.id === id 
        ? { 
            ...item, 
            status: 'disetujui', 
            disetujuiOleh: 'Admin',
            disetujuiPada: new Date().toISOString(),
            catatan,
            updatedAt: new Date().toISOString()
          }
        : item
    ));
  };

  const handleReject = (id: string, catatan: string = '') => {
    setPengajuanIzin(pengajuanIzin.map(item => 
      item.id === id 
        ? { 
            ...item, 
            status: 'ditolak', 
            disetujuiOleh: 'Admin',
            disetujuiPada: new Date().toISOString(),
            catatan,
            updatedAt: new Date().toISOString()
          }
        : item
    ));
  };

  // Statistics
  const stats = {
    total: pengajuanIzin.length,
    pending: pengajuanIzin.filter(p => p.status === 'pending').length,
    disetujui: pengajuanIzin.filter(p => p.status === 'disetujui').length,
    ditolak: pengajuanIzin.filter(p => p.status === 'ditolak').length,
  };

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Manajemen Izin
          </h1>
          <p className="text-gray-600">
            Kelola permohonan izin dari peserta magang
          </p>
                </div>
              </div>

      {/* Statistics Cards */}
      <Grid columns={{ initial: "1", md: "4" }} gap="4">
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Total Izin
            </Text>
            <Text size="6" weight="bold">
              {stats.total}
            </Text>
            <Text size="1" color="gray">
              Total permohonan
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Menunggu Approval
            </Text>
            <Text size="6" weight="bold" color="orange">
              {stats.pending}
            </Text>
            <Text size="1" color="gray">
              Perlu ditinjau
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Disetujui
            </Text>
            <Text size="6" weight="bold" color="green">
              {stats.disetujui}
            </Text>
            <Text size="1" color="gray">
              Izin diterima
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Ditolak
            </Text>
            <Text size="6" weight="bold" color="red">
              {stats.ditolak}
            </Text>
            <Text size="1" color="gray">
              Izin ditolak
            </Text>
            </Flex>
        </Card>
      </Grid>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <Text weight="bold">Filter Izin</Text>
          </Flex>
          <Flex gap="4" wrap="wrap">
          <Flex className="flex items-center w-full relative">
            <TextField.Root
              color="indigo"
                placeholder="Cari pengajuan izin…"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full"
            />
              <IconButton variant="surface" color="gray" className="ml-2">
            <MagnifyingGlassIcon width="18" height="18" />
          </IconButton>
            </Flex>
            <Select.Root
              size="2"
              defaultValue="Semua"
              value={statusFilter}
              onValueChange={(value) => setStatusFilter(value)}
            >
              <Select.Trigger color="indigo" radius="large" />
              <Select.Content color="indigo">
                <Select.Item value="Semua">Semua Status</Select.Item>
                <Select.Item value="pending">Menunggu</Select.Item>
                <Select.Item value="disetujui">Disetujui</Select.Item>
                <Select.Item value="ditolak">Ditolak</Select.Item>
              </Select.Content>
            </Select.Root>
            <Select.Root
              size="2"
              defaultValue="Semua"
              value={typeFilter}
              onValueChange={(value) => setTypeFilter(value)}
            >
              <Select.Trigger color="indigo" radius="large" />
              <Select.Content color="indigo">
                <Select.Item value="Semua">Semua Jenis</Select.Item>
                <Select.Item value="sakit">Sakit</Select.Item>
                <Select.Item value="izin">Izin</Select.Item>
                <Select.Item value="cuti">Cuti</Select.Item>
              </Select.Content>
            </Select.Root>
          </Flex>
        </Flex>
      </Box>

      {/* Permissions Table */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="2">
            <Flex align="center" gap="2">
              <CalendarIcon width="18" height="18" />
              <Text weight="bold">Daftar Permohonan Izin</Text>
            </Flex>
            <Text size="2" color="gray">
              {filteredPengajuanIzin.length} izin ditemukan
            </Text>
          </Flex>
          <Table.Root variant="ghost">
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeaderCell>Peserta Magang</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Jenis</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Tanggal</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Alasan</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Diajukan</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Aksi</Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {filteredPengajuanIzin.map((item) => (
                <Table.Row key={item.id} className="hover:bg-gray-50">
                  <Table.Cell>
                    <Flex align="center" gap="3">
                      <div className="h-8 w-8 flex-shrink-0">
                        {item.pesertaMagang?.avatar ? (
                          <img
                            src={item.pesertaMagang.avatar}
                            alt={item.pesertaMagang.nama}
                            className="h-8 w-8 rounded-full object-cover"
                          />
                        ) : (
                          <div className="h-8 w-8 rounded-full bg-primary-100 flex items-center justify-center">
                            <span className="text-xs font-medium text-primary-600">
                              {item.pesertaMagang?.nama
                                .split(" ")
                                .map((n: string) => n[0])
                                .join("")}
                            </span>
                          </div>
                        )}
                      </div>
                      <Text size="2">{item.pesertaMagang?.nama}</Text>
                    </Flex>
                  </Table.Cell>
                  <Table.Cell>
                    <TypeBadge tipe={item.tipe} />
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2">
                      {new Date(item.tanggalMulai).toLocaleDateString("id-ID")}
                      {item.tanggalMulai !== item.tanggalSelesai && (
                        <span> - {new Date(item.tanggalSelesai).toLocaleDateString("id-ID")}</span>
                      )}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" color="gray" className="max-w-xs truncate">
                      {item.alasan}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <StatusBadge status={item.status} />
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" color="gray">
                      {new Date(item.diajukanPada).toLocaleDateString("id-ID")}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                      <Dialog.Root>
                        <Dialog.Trigger>
                        <Button 
                            variant="outline"
                          size="1" 
                          >
                          <EyeOpenIcon width="16" height="16" className="mr-1" />
                          Review
                        </Button>
                        </Dialog.Trigger>
                      <Dialog.Content className="max-w-3xl">
                        <div className="space-y-6">
                          {/* Header */}
                          <div className="text-center pb-4 border-b border-gray-200">
                            <Dialog.Title className="text-xl font-bold text-gray-900 mb-2">
                              Review Permohonan Izin
                            </Dialog.Title>
                            <Dialog.Description className="text-sm text-gray-600">
                              {item.pesertaMagang?.nama} • {item.pesertaMagang?.divisi}
                          </Dialog.Description>
                            </div>

                          {/* Main Content */}
                          <div className="space-y-6">
                            {/* Status Cards */}
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                              <div className="bg-gradient-to-r from-blue-50 to-blue-100 p-4 rounded-lg border border-blue-200">
                                <div className="flex items-center justify-between">
                                  <div>
                                    <p className="text-xs font-medium text-blue-600 mb-1">Jenis Izin</p>
                                    <TypeBadge tipe={item.tipe} />
                                  </div>
                                  <div className="w-10 h-10 bg-blue-200 rounded-full flex items-center justify-center">
                                    <CalendarIcon className="w-5 h-5 text-blue-600" />
                                  </div>
                            </div>
                            </div>

                              <div className="bg-gradient-to-r from-purple-50 to-purple-100 p-4 rounded-lg border border-purple-200">
                                <div className="flex items-center justify-between">
                                  <div>
                                    <p className="text-xs font-medium text-purple-600 mb-1">Status</p>
                                    <StatusBadge status={item.status} />
                                  </div>
                                  <div className="w-10 h-10 bg-purple-200 rounded-full flex items-center justify-center">
                                    <CheckCircledIcon className="w-5 h-5 text-purple-600" />
                              </div>
                              </div>
                            </div>

                              <div className="bg-gradient-to-r from-gray-50 to-gray-100 p-4 rounded-lg border border-gray-200">
                                <div className="flex items-center justify-between">
                              <div>
                                    <p className="text-xs font-medium text-gray-600 mb-1">Diajukan</p>
                                    <p className="text-sm font-semibold text-gray-900">
                                      {new Date(item.diajukanPada).toLocaleDateString('id-ID')}
                                    </p>
                                  </div>
                                  <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                                    <CalendarIcon className="w-5 h-5 text-gray-600" />
                                  </div>
                              </div>
                              </div>
                            </div>

                            {/* Date Range */}
                            <div className="bg-white border border-gray-200 rounded-lg p-4">
                              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                                <CalendarIcon className="w-4 h-4 mr-2 text-indigo-600" />
                                Periode Izin
                              </h3>
                              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                  <label className="text-sm font-medium text-gray-700">Tanggal Mulai</label>
                                  <div className="p-3 bg-gray-50 rounded-lg border border-gray-200">
                                    <p className="text-sm font-semibold text-gray-900">
                                      {new Date(item.tanggalMulai).toLocaleDateString('id-ID', {
                                        weekday: 'long',
                                        year: 'numeric',
                                        month: 'long',
                                        day: 'numeric'
                                      })}
                                    </p>
                                  </div>
                                </div>
                                <div className="space-y-2">
                                  <label className="text-sm font-medium text-gray-700">Tanggal Selesai</label>
                                  <div className="p-3 bg-gray-50 rounded-lg border border-gray-200">
                                    <p className="text-sm font-semibold text-gray-900">
                                      {new Date(item.tanggalSelesai).toLocaleDateString('id-ID', {
                                        weekday: 'long',
                                        year: 'numeric',
                                        month: 'long',
                                        day: 'numeric'
                                      })}
                                    </p>
                                  </div>
                              </div>
                              </div>
                            </div>

                            {/* Reason */}
                            <div className="bg-white border border-gray-200 rounded-lg p-4">
                              <h3 className="text-lg font-semibold text-gray-900 mb-4">Alasan Permohonan</h3>
                              <div className="p-3 bg-gray-50 rounded-lg border border-gray-200">
                                <p className="text-sm text-gray-700 leading-relaxed">{item.alasan}</p>
                            </div>
                          </div>

                            {/* Supporting Document */}
                            {item.dokumenPendukung && (
                              <div className="bg-white border border-gray-200 rounded-lg p-4">
                                <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                                  <FileTextIcon className="w-4 h-4 mr-2 text-indigo-600" />
                                  Dokumen Pendukung
                                </h3>
                                <Button variant="outline" size="2" className="w-fit">
                                  <FileTextIcon width="16" height="16" className="mr-2" />
                                  {item.dokumenPendukung}
                                </Button>
                              </div>
                            )}

                            {/* Action Section for Pending */}
                            {item.status === 'pending' && (
                              <div className="bg-gradient-to-r from-yellow-50 to-orange-50 border border-yellow-200 rounded-lg p-4">
                                <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                                  <CheckCircledIcon className="w-4 h-4 mr-2 text-yellow-600" />
                                  Tindakan Admin
                                </h3>
                                <div className="space-y-4">
                                  <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                      Catatan (Opsional)
                                </label>
                                <TextField.Root
                                      placeholder="Tambahkan catatan untuk izin ini..."
                                      size="2"
                                      className="w-full"
                                    />
                                  </div>
                                  
                                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                              <Button
                                      color="green"
                                      size="3"
                                      className="w-full"
                                      onClick={() => handleApprove(item.id, '')}
                                    >
                                      <CheckCircledIcon width="16" height="16" className="mr-2" />
                                      Setujui Izin
                              </Button>
                                    <Button 
                                      color="red"
                                      variant="outline"
                                      size="3"
                                      className="w-full"
                                      onClick={() => handleReject(item.id, '')}
                                    >
                                      <CrossCircledIcon width="16" height="16" className="mr-2" />
                                      Tolak Izin
                              </Button>
                                  </div>
                                </div>
                              </div>
                            )}

                            {/* Admin Notes for Processed */}
                            {item.status !== 'pending' && item.catatan && (
                              <div className="bg-white border border-gray-200 rounded-lg p-4">
                                <h3 className="text-lg font-semibold text-gray-900 mb-4">Catatan Admin</h3>
                                <div className="p-3 bg-blue-50 rounded-lg border border-blue-200">
                                  <p className="text-sm text-gray-700">{item.catatan}</p>
                                </div>
                                <div className="mt-3 text-xs text-gray-500">
                                  <p>Diproses oleh <span className="font-medium text-gray-900">{item.disetujuiOleh}</span></p>
                                  <p>pada {item.disetujuiPada && new Date(item.disetujuiPada).toLocaleString('id-ID')}</p>
                            </div>
                          </div>
                            )}
                          </div>
                          </div>
                        </Dialog.Content>
                      </Dialog.Root>
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