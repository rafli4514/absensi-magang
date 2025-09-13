import { useState } from "react";
import type { Absensi, PesertaMagang } from "../types";
import { formatDateTime } from "../lib/utils";
import {
  AspectRatio,
  Box,
  Button,
  Card,
  Dialog,
  Flex,
  Grid,
  IconButton,
  Select,
  Table,
  Text,
  TextField,
} from "@radix-ui/themes";
import {
  CameraIcon,
  CheckCircledIcon,
  CircleBackslashIcon,
  CrossCircledIcon,
  DownloadIcon,
  EyeOpenIcon,
  InfoCircledIcon,
  MagnifyingGlassIcon,
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";
import Gambar from "../assets/papa.jpg"

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
      tanggalMulai: "2025-09-04",
      tanggalSelesai: "2026-01-04",
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
    selfieUrl: Gambar,
    qrCodeData: "QR123",
    status: "valid",
    createdAt: new Date().toISOString(),
  },
  {
    id: "2",
    pesertaMagangId: "1",
    pesertaMagang: {
      id: "1",
      nama: "Mamad Supratman",
      username: "Mamad",
      divisi: "IT",
      universitas: "Universitas Apa Coba",
      nomorHp: "08123456789",
      tanggalMulai: "2025-09-04",
      tanggalSelesai: "2026-01-04",
      status: "Aktif",
      createdAt: "2025-08-01",
      updatedAt: "2025-08-01",
    },
    tipe: "Izin",
    timestamp: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
    lokasi: {
      latitude: -6.2088,
      longitude: 106.8456,
      alamat: "Jakarta, Indonesia",
    },
    qrCodeData: "QR456",
    status: "valid",
    createdAt: new Date(Date.now() - 86400000).toISOString(),
  },
  {
    id: "3",
    pesertaMagangId: "1",
    pesertaMagang: {
      id: "1",
      nama: "Mamad Supratman",
      username: "Mamad",
      divisi: "IT",
      universitas: "Universitas Apa Coba",
      nomorHp: "08123456789",
      tanggalMulai: "2025-09-04",
      tanggalSelesai: "2026-01-04",
      status: "Aktif",
      createdAt: "2025-08-01",
      updatedAt: "2025-08-01",
    },
    tipe: "Sakit",
    timestamp: new Date(Date.now() - 172800000).toISOString(), // 2 days ago
    qrCodeData: "QR789",
    status: "valid",
    createdAt: new Date(Date.now() - 172800000).toISOString(),
  },
];

const StatusIcon = ({ status }: { status: Absensi["status"] }) => {
  switch (status) {
    case "valid":
      return <CheckCircledIcon color="green" />;
    case "Terlambat":
      return <InfoCircledIcon color="orange" />;
    case "invalid":
      return <CrossCircledIcon color="red" />;
    default:
      return <CircleBackslashIcon color="gray" />;
  }
};

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig = {
    valid: { color: "bg-green-100 text-green-800", label: "Valid" },
    Terlambat: { color: "bg-yellow-100 text-yellow-800", label: "Terlambat" },
    invalid: { color: "bg-red-100 text-red-800", label: "Tidak Valid" },
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

const TypeBadge = ({ tipe }: { tipe: Absensi["tipe"] }) => {
  const typeConfig = {
    Masuk: { color: "bg-blue-100 text-blue-800", label: "Masuk" },
    Keluar: { color: "bg-purple-100 text-purple-800", label: "Keluar" },
    Izin: { color: "bg-orange-100 text-orange-800", label: "Izin" },
    Sakit: { color: "bg-red-100 text-red-800", label: "Sakit" },
    Cuti: { color: "bg-green-100 text-green-800", label: "Cuti" },
  };

  const config = typeConfig[tipe] || { color: "bg-gray-100 text-gray-800", label: tipe };

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
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");
  const [dateFilter, setDateFilter] = useState("");

  const hasPesertaMagang = (
    record: Absensi
  ): record is Absensi & { pesertaMagang: PesertaMagang } => {
    return record.pesertaMagang !== undefined && record.pesertaMagang !== null;
  };

  const filteredAbsensi = Absensi.filter(hasPesertaMagang).filter((record) => {
    const matchesSearch =
      record.pesertaMagang.nama
        .toLowerCase()
        .includes(searchTerm.toLowerCase()) ||
      record.pesertaMagang.username
        .toLowerCase()
        .includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || record.status === statusFilter;
    const matchesType = typeFilter === "Semua" || record.tipe === typeFilter;

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
        {/* Judul */}
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Monitoring Absensi
          </h1>
          <p className="text-gray-600">
            Pantau kehadiran siswa secara real-time
          </p>
        </div>

        {/* Export button */}
        <button className="btn-primary flex items-center">
          <Button>
            <DownloadIcon /> Export Data
          </Button>
        </button>
      </div>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <h3 className="text-lg font-semibold text-gray-900">Filter Absensi</h3>
          </Flex>
          <Flex gap="4" wrap="wrap">
            <Flex className="flex items-center w-full relative">
              <TextField.Root
                color="indigo"
                placeholder="Cari Peserta Magang…"
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
                  <Select.Item value="valid">Valid</Select.Item>
                  <Select.Item value="Terlambat">Terlambat</Select.Item>
                  <Select.Item value="invalid">Tidak Valid</Select.Item>
                </Select.Content>
              </Select.Root>
            </div>
            <div className="flex items-center">
              <Select.Root
                size="2"
                defaultValue="Semua"
                value={typeFilter}
                onValueChange={(value) => setTypeFilter(value)}
              >
                <Select.Trigger color="indigo" radius="large" />
                <Select.Content color="indigo">
                  <Select.Item value="Semua">Semua Tipe</Select.Item>
                  <Select.Item value="Masuk">Masuk</Select.Item>
                  <Select.Item value="Keluar">Keluar</Select.Item>
                  <Select.Item value="Izin">Izin</Select.Item>
                  <Select.Item value="Sakit">Sakit</Select.Item>
                  <Select.Item value="Cuti">Cuti</Select.Item>
                </Select.Content>
              </Select.Root>
            </div>
            <div className="flex items-center">
              <TextField.Root
                aria-label="Filter Tanggal"
                size="2"
                radius="large"
                type="date"
                value={dateFilter}
                onChange={(e) => setDateFilter(e.target.value)}
                className="input-field"
              />
            </div>
          </Flex>
        </Flex>
      </Box>

      {/* Absensi records */}
      <Box>
        <Card>
          {/* Table */}
          <Table.Root variant="ghost">
            {/* <Table.Header> */}
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeaderCell>Nama</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Tipe</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Waktu</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Lokasi</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Verifikasi</Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>

            {/* Tabel Body */}
            <Table.Body>
              {filteredAbsensi.map((item) => (
                <Table.Row key={item.id} className="hover:bg-gray-50">
                  <Table.Cell>
                    <div className="flex items-center">
                      <div className="h-10 w-10 flex-shrink-0">
                        <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center">
                          <span className="text-sm font-medium text-primary-600">
                            {item.pesertaMagang.nama
                              .split(" ")
                              .map((n: string) => n[0])
                              .join("")}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {item.pesertaMagang.nama}
                        </div>
                        <div className="text-sm text-gray-500">
                          {item.pesertaMagang.username}
                        </div>
                      </div>
                    </div>
                    {/* Nama Peserta */}
                  </Table.Cell>
                  <Table.Cell>
                    <TypeBadge tipe={item.tipe} />
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">
                      {formatDateTime(item.createdAt) || "Tidak tersedia"}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">
                      {item.lokasi?.alamat || "Tidak tersedia"}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex
                      direction="row"
                      className="text-sm text-gray-900 justify-start items-center"
                    >
                      <StatusIcon status={item.status} />
                      <StatusBadge status={item.status} />
                    </Flex>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex gap="3">
                      <Dialog.Root>
                        <Dialog.Trigger>
                          <IconButton
                            color="gray"
                            variant="outline"
                            className="hover:bg-gray-100 transition-all duration-200"
                          >
                            <EyeOpenIcon width="18" height="18" />
                          </IconButton>
                        </Dialog.Trigger>

                        <Dialog.Content className="p-8 max-w-2xl mx-auto bg-white rounded-xl shadow-lg">
                          <Dialog.Title>
                            Detail Absensi
                          </Dialog.Title>

                          <Flex direction="column" gap="6" className="mt-6">
                            {/* Profile Header */}
                            <Grid columns="2" gap="6" width="auto">
                              <AspectRatio ratio={1}>
                                {" "}
                                <img
                                  src={item.selfieUrl}
                                  alt="Selfie"
                                  className="w-75 h-75 object-cover shadow-xl rounded-lg"
                                />
                              </AspectRatio>
                              <div className="flex flex-col justify-center">
                                <Text className="text-2xl font-semibold text-gray-900">
                                  {item.pesertaMagang.nama}
                                </Text>
                                <Text className="text-gray-600">
                                  {item.pesertaMagang.username}
                                </Text>
                              </div>
                            </Grid>

                            {/* Information Sections */}
                            <div className="mt-6">
                              {/* Tipe Absensi */}
                              <Flex
                                direction="row"
                                justify="between"
                                align="center"
                                className="py-3 border-b border-gray-200"
                              >
                                <Text className="text-lg font-medium text-gray-700">
                                  Tipe Absensi
                                </Text>
                                <div className="flex justify-end">
                                  <TypeBadge tipe={item.tipe} />
                                </div>
                              </Flex>

                              {/* Timestamp */}
                              <Flex
                                direction="row"
                                justify="between"
                                align="center"
                                className="py-3 border-b border-gray-200"
                              >
                                <Text className="text-lg font-medium text-gray-700">
                                  Timestamp
                                </Text>
                                <Text className="text-lg text-gray-900">
                                  {new Date(item.timestamp).toLocaleString()}
                                </Text>
                              </Flex>

                              {/* Lokasi */}
                              {item.lokasi && (
                                <Flex
                                  direction="row"
                                  justify="between"
                                  align="center"
                                  className="py-3 border-b border-gray-200"
                                >
                                  <Text className="text-lg font-medium text-gray-700">
                                    Lokasi
                                  </Text>
                                  <Text className="text-lg text-gray-900">
                                    {item.lokasi.alamat} ({item.lokasi.latitude}
                                    , {item.lokasi.longitude})
                                  </Text>
                                </Flex>
                              )}

                              {/* QR Code Data */}
                              <Flex
                                direction="row"
                                justify="between"
                                align="center"
                                className="py-3 border-b border-gray-200"
                              >
                                <Text className="text-lg font-medium text-gray-700">
                                  QR Code Data
                                </Text>
                                <Text className="text-lg text-gray-900">
                                  {item.qrCodeData}
                                </Text>
                              </Flex>

                              {/* Status */}
                              <Flex
                                direction="row"
                                justify="between"
                                align="center"
                                className="py-3 border-b border-gray-200"
                              >
                                <Text className="text-lg font-medium text-gray-700">
                                  Status
                                </Text>
                                <Text className="text-lg text-gray-900">
                                  {item.status}
                                </Text>
                              </Flex>

                              {/* Catatan */}
                              {item.catatan && (
                                <div className="w-full py-3">
                                  <label className="block text-lg font-medium text-gray-700">
                                    Catatan
                                  </label>
                                  <TextField.Root
                                    placeholder="Masukkan Catatan"
                                    defaultValue={item.catatan}
                                    className="w-full p-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm"
                                  />
                                </div>
                              )}

                              {/* Created At */}
                              <Flex
                                direction="row"
                                justify="between"
                                align="center"
                                className="py-3 border-t border-gray-200"
                              >
                                <Text className="text-lg font-medium text-gray-700">
                                  Created At
                                </Text>
                                <Text className="text-lg text-gray-900">
                                  {new Date(item.createdAt).toLocaleString()}
                                </Text>
                              </Flex>
                            </div>
                          </Flex>
                        </Dialog.Content>
                      </Dialog.Root>

                      <Dialog.Root>
                        <Dialog.Trigger>
                          <IconButton
                            color="blue"
                            variant="outline"
                            className="ml-4 hover:bg-blue-100 transition-all duration-200"
                          >
                            <CameraIcon width="18" height="18" />
                          </IconButton>
                        </Dialog.Trigger>
                        <Dialog.Content className="max-w-2xl">
                          <Dialog.Title>Validasi Foto Selfie</Dialog.Title>
                          <Dialog.Description>
                            Periksa foto selfie untuk memvalidasi kehadiran peserta magang
                          </Dialog.Description>
                          
                          <div className="mt-6">
                            <AspectRatio ratio={1}>
                              <img 
                                src={item.selfieUrl || "../assets/papa.jpg"} 
                                alt="Foto Selfie" 
                                className="w-full h-full object-cover rounded-lg"
                              />
                            </AspectRatio>
                            
                            {/* Status Info */}
                            <div className="mt-4 p-4 bg-gray-50 rounded-lg">
                              <div className="flex items-center justify-between">
                                <div>
                                  <p className="text-sm font-medium text-gray-700">Status Saat Ini:</p>
                                  <div className="flex items-center gap-2 mt-1">
                                    <StatusIcon status={item.status} />
                                    <StatusBadge status={item.status} />
                                  </div>
                                </div>
                                <div className="text-right">
                                  <p className="text-sm text-gray-500">Waktu Absensi:</p>
                                  <p className="text-sm font-medium">{new Date(item.timestamp).toLocaleString()}</p>
                                </div>
                              </div>
                            </div>
                            
                            {/* Action Buttons */}
                            <div className="mt-6 flex gap-3 justify-end">
                              <Button 
                                variant="outline" 
                                color="red"
                                onClick={() => {
                                  // TODO: Update status to invalid
                                  console.log('Set status to invalid for:', item.id);
                                }}
                                disabled={item.status === 'invalid'}
                              >
                                <CrossCircledIcon className="w-4 h-4 mr-2" />
                                Tandai Tidak Valid
                              </Button>
                              <Button 
                                color="green"
                                onClick={() => {
                                  // TODO: Update status to valid
                                  console.log('Set status to valid for:', item.id);
                                }}
                                disabled={item.status === 'valid'}
                              >
                                <CheckCircledIcon className="w-4 h-4 mr-2" />
                                Tandai Valid
                              </Button>
                            </div>
                          </div>
                        </Dialog.Content>
                      </Dialog.Root>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table.Root>
        </Card>
      </Box>

      {filteredAbsensi.length === 0 && (
        <div className="text-center py-8">
          <p className="text-gray-500">Tidak ada data absensi yang ditemukan</p>
        </div>
      )}
    </div>
  );
}
