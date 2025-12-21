import { useState, useEffect } from "react";
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
  ClockIcon,
  CrossCircledIcon,
  DownloadIcon,
  EyeOpenIcon,
  InfoCircledIcon,
  MixerHorizontalIcon,
} from "@radix-ui/react-icons";
import absensiService from "../services/absensiService";
import Avatar from "../components/Avatar";
import { parseQRCodeData, formatQRCodeType, getQRCodeTypeColor } from "../lib/qrCodeUtils";

// Data dummy sudah dihapus - menggunakan API real

const StatusIcon = ({ status }: { status: Absensi["status"] }) => {
  switch (status) {
    case "VALID":
      return <CheckCircledIcon color="green" />;
    case "TERLAMBAT":
      return <InfoCircledIcon color="orange" />;
    case "INVALID":
      return <CrossCircledIcon color="red" />;
    default:
      return <CircleBackslashIcon color="gray" />;
  }
};

const StatusBadge = ({ status }: { status: Absensi["status"] }) => {
  const statusConfig = {
    VALID: { color: "bg-green-100 text-green-800", label: "Valid" },
    TERLAMBAT: { color: "bg-yellow-100 text-yellow-800", label: "Terlambat" },
    INVALID: { color: "bg-red-100 text-red-800", label: "Tidak Valid" },
  };

  const config = statusConfig[status] || {
    color: "bg-gray-100 text-gray-800",
    label: status,
  };

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
    MASUK: { color: "bg-blue-100 text-blue-800", label: "Masuk" },
    KELUAR: { color: "bg-purple-100 text-purple-800", label: "Keluar" },
    IZIN: { color: "bg-orange-100 text-orange-800", label: "Izin" },
    SAKIT: { color: "bg-red-100 text-red-800", label: "Sakit" },
    CUTI: { color: "bg-green-100 text-green-800", label: "Cuti" },
  };

  const config = typeConfig[tipe] || {
    color: "bg-gray-100 text-gray-800",
    label: tipe,
  };

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

export default function AbsensiPage() {
  const [absensi, setAbsensi] = useState<Absensi[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");
  const [dateFilter, setDateFilter] = useState("");

  // Fetch data on component mount
  useEffect(() => {
    fetchAbsensi();
  }, []);

  const fetchAbsensi = async () => {
    try {
      setLoading(true);
      const response = await absensiService.getAbsensi();
      if (response.success && response.data) {
        setAbsensi(response.data);
      } else {
        setError(response.message || "Failed to fetch absensi");
        setAbsensi([]); // Fallback to empty data
      }
    } catch (error: unknown) {
      console.error("Fetch absensi error:", error);
      setError("Failed to fetch absensi");
      setAbsensi([]); // Fallback to empty data
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async (
    id: string,
    newStatus: Absensi["status"]
  ) => {
    try {
      const response = await absensiService.updateAbsensi(id, {
        status: newStatus,
      });
      if (response.success) {
        await fetchAbsensi();
      } else {
        setError(response.message || "Failed to update absensi status");
      }
    } catch (error: unknown) {
      console.error("Update absensi status error:", error);
      setError("Failed to update absensi status");
    }
  };

  const hasPesertaMagang = (
    record: Absensi
  ): record is Absensi & { pesertaMagang: PesertaMagang } => {
    return record.pesertaMagang !== undefined && record.pesertaMagang !== null;
  };

  const filteredAbsensi = absensi.filter(hasPesertaMagang).filter((record) => {
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

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading absensi...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Error message */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md">
          {error}
        </div>
      )}

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
        <Button className="flex items-center">
          <DownloadIcon className="w-4 h-4 mr-2" />
          Export Data
        </Button>
      </div>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          {/* Header Judul */}
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <h3 className="text-lg font-semibold text-gray-900">
              Filter Absensi
            </h3>
          </Flex>

          {/* Area Controls */}
          {/* justify="between" akan memisahkan Search (kiri) dan Group Filter (kanan) */}
          <Flex gap="4" wrap="wrap" align="center" justify="between">

            {/* 1. SEARCH BAR (KIRI) */}
            {/* class flex-1 membuat elemen ini mengisi ruang kosong, mendorong filter ke kanan */}
            <div className="flex-1 min-w-[250px]">
              <TextField.Root
                color="indigo"
                placeholder="Cari Peserta Magang…"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full"
                radius="large"
              />
            </div>

            {/* 2. GROUP FILTER (KANAN) */}
            {/* Dibungkus Flex lagi agar mereka tetap berdekatan di sisi kanan */}
            <Flex gap="3" align="center" wrap="wrap" className="justify-end">

              {/* Filter Status */}
              <div className="w-auto">
                <Select.Root
                  defaultValue="Semua"
                  value={statusFilter}
                  onValueChange={(value) => setStatusFilter(value)}
                >
                  <Select.Trigger
                    color="indigo"
                    radius="large"
                    placeholder="Status"
                    className="min-w-[140px]" // Opsional: agar lebar konsisten
                  />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua Status</Select.Item>
                    <Select.Item value="VALID">Valid</Select.Item>
                    <Select.Item value="TERLAMBAT">Terlambat</Select.Item>
                    <Select.Item value="INVALID">Tidak Valid</Select.Item>
                  </Select.Content>
                </Select.Root>
              </div>

              {/* Filter Tipe */}
              <div className="w-auto">
                <Select.Root
                  defaultValue="Semua"
                  value={typeFilter}
                  onValueChange={(value) => setTypeFilter(value)}
                >
                  <Select.Trigger
                    color="indigo"
                    radius="large"
                    placeholder="Tipe"
                    className="min-w-[130px]"
                  />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua Tipe</Select.Item>
                    <Select.Item value="MASUK">Masuk</Select.Item>
                    <Select.Item value="KELUAR">Keluar</Select.Item>
                    <Select.Item value="IZIN">Izin</Select.Item>
                    <Select.Item value="SAKIT">Sakit</Select.Item>
                    <Select.Item value="CUTI">Cuti</Select.Item>
                  </Select.Content>
                </Select.Root>
              </div>

              {/* Filter Tanggal */}
              <div className="w-auto">
                <TextField.Root
                  aria-label="Filter Tanggal"
                  radius="large"
                  type="date"
                  value={dateFilter}
                  onChange={(e) => setDateFilter(e.target.value)}
                  className="cursor-pointer"
                  color="indigo"
                />
              </div>
            </Flex>
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
                      <Avatar
                        src={item.pesertaMagang.avatar}
                        alt={item.pesertaMagang.nama}
                        name={item.pesertaMagang.nama}
                        size="md"
                        showBorder={true}
                        showHover={true}
                        className="border-gray-200"
                      />
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {item.pesertaMagang.nama}
                        </div>
                        <div className="text-sm text-gray-500">
                          @{item.pesertaMagang.username}
                        </div>
                      </div>
                    </div>
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
                          <Dialog.Title>Detail Absensi</Dialog.Title>

                          <Flex direction="column" gap="6" className="mt-6">
                            {/* Profile Header */}
                            <Grid columns="2" gap="6" width="auto">
                              <AspectRatio ratio={1}>
                                <img
                                  src={item.selfieUrl}
                                  alt="Selfie"
                                  className="w-full h-full object-cover shadow-xl rounded-lg"
                                />
                              </AspectRatio>
                              <div className="flex flex-col justify-center">
                                <div className="flex items-center gap-4 mb-4">
                                  <Avatar
                                    src={item.pesertaMagang.avatar}
                                    alt={item.pesertaMagang.nama}
                                    name={item.pesertaMagang.nama}
                                    size="lg"
                                    showBorder={true}
                                    showHover={false}
                                    className="border-gray-200"
                                  />
                                  <div>
                                    <Text className="text-2xl font-semibold text-gray-900">
                                      {item.pesertaMagang.nama}
                                    </Text>
                                    <Text className="text-gray-600">
                                      @{item.pesertaMagang.username}
                                    </Text>
                                  </div>
                                </div>
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
                              <div className="py-3 border-b border-gray-200">
                                <Text className="text-lg font-medium text-gray-700 mb-2">
                                  QR Code Data
                                </Text>
                                <div className="bg-gray-50 p-3 rounded-lg">
                                  {(() => {
                                    const qrData = parseQRCodeData(item.qrCodeData);
                                    if (qrData) {
                                      return (
                                        <div className="space-y-2 text-sm">
                                          <div className="flex justify-between">
                                            <span className="text-gray-600">Type:</span>
                                            <span className={`px-2 py-1 rounded-full text-xs ${getQRCodeTypeColor(qrData.type)}`}>
                                              {formatQRCodeType(qrData.type)}
                                            </span>
                                          </div>
                                          <div className="flex justify-between">
                                            <span className="text-gray-600">Session ID:</span>
                                            <span className="font-mono text-xs">{qrData.sessionId}</span>
                                          </div>
                                          <div className="flex justify-between">
                                            <span className="text-gray-600">Location:</span>
                                            <span>{qrData.location}</span>
                                          </div>
                                          <div className="flex justify-between">
                                            <span className="text-gray-600">Valid Until:</span>
                                            <span>{new Date(qrData.validUntil).toLocaleString("id-ID")}</span>
                                          </div>
                                          <div className="flex justify-between">
                                            <span className="text-gray-600">Generated:</span>
                                            <span>{new Date(qrData.timestamp).toLocaleString("id-ID")}</span>
                                          </div>
                                        </div>
                                      );
                                    } else {
                                      return (
                                        <Text className="text-sm text-gray-600 font-mono">
                                          {item.qrCodeData}
                                        </Text>
                                      );
                                    }
                                  })()}
                                </div>
                              </div>

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
                            Periksa foto selfie untuk memvalidasi kehadiran
                            peserta magang
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
                                  <p className="text-sm font-medium text-gray-700">
                                    Status Saat Ini:
                                  </p>
                                  <div className="flex items-center gap-2 mt-1">
                                    <StatusIcon status={item.status} />
                                    <StatusBadge status={item.status} />
                                  </div>
                                </div>
                                <div className="text-right">
                                  <p className="text-sm text-gray-500">
                                    Waktu Absensi:
                                  </p>
                                  <p className="text-sm font-medium">
                                    {new Date(item.timestamp).toLocaleString()}
                                  </p>
                                </div>
                              </div>
                            </div>

                            {/* Action Buttons */}
                            <div className="mt-6 flex gap-3 justify-end">
                              <Button
                                variant="outline"
                                color="red"
                                onClick={() =>
                                  handleUpdateStatus(item.id, "INVALID")
                                }
                                disabled={item.status === "INVALID"}
                              >
                                <CrossCircledIcon className="w-4 h-4 mr-2" />
                                Tandai Tidak Valid
                              </Button>
                              <Button
                                color="green"
                                onClick={() =>
                                  handleUpdateStatus(item.id, "VALID")
                                }
                                disabled={item.status === "VALID"}
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
          {filteredAbsensi.length === 0 && (
            <Box className="text-center py-12">
              <ClockIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <Flex direction="column" justify="center">
                <Text size="3" color="gray" weight="medium">
                  Tidak ada adata absensi yang ditemukan
                </Text>
                <Text size="2" color="gray" className="mt-2">
                  {searchTerm
                    ? "Coba ubah kata kunci pencarian"
                    : "Belum ada riwayat absensi"}
                </Text>
              </Flex>
            </Box>
          )}
        </Card>
      </Box>
    </div>
  );
}
