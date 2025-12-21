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
  ChevronLeftIcon,
  ChevronRightIcon,
  DoubleArrowLeftIcon,
  DoubleArrowRightIcon,
} from "@radix-ui/react-icons";
import absensiService from "../services/absensiService";
import Avatar from "../components/Avatar";
import { parseQRCodeData, formatQRCodeType, getQRCodeTypeColor } from "../lib/qrCodeUtils";

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
      className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}
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
      className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

export default function AbsensiPage() {
  const [absensi, setAbsensi] = useState<Absensi[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");
  const [dateFilter, setDateFilter] = useState("");

  // Pagination State
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState<string>("20");

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
        setAbsensi([]);
      }
    } catch (error: unknown) {
      console.error("Fetch absensi error:", error);
      setError("Failed to fetch absensi");
      setAbsensi([]);
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
      record.pesertaMagang.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      record.pesertaMagang.username.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus = statusFilter === "Semua" || record.status === statusFilter;
    const matchesType = typeFilter === "Semua" || record.tipe === typeFilter;
    const matchesDate = !dateFilter || new Date(record.timestamp).toDateString() === new Date(dateFilter).toDateString();

    return matchesSearch && matchesStatus && matchesType && matchesDate;
  });

  // Pagination Logic
  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, statusFilter, typeFilter, dateFilter, itemsPerPage]);

  const totalItems = filteredAbsensi.length;
  const pageSize = itemsPerPage === "All" ? totalItems : parseInt(itemsPerPage);
  const totalPages = Math.ceil(totalItems / pageSize);

  const paginatedData = filteredAbsensi.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  );

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
          <p className="mt-2 text-sm text-gray-600">Loading absensi...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4 pb-10">
      {/* Error message */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md text-sm">
          {error}
        </div>
      )}

      {/* Page header */}
      <div className="flex flex-row justify-between items-center gap-4">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">
            Monitoring Absensi
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Pantau kehadiran siswa secara real-time
          </p>
        </div>

        {/* Export button */}
        <Button size="2" className="flex items-center cursor-pointer">
          <DownloadIcon className="w-3.5 h-3.5 mr-1.5" />
          Export Data
        </Button>
      </div>

      {/* Filters - Compact */}
      <Card className="shadow-sm">
        <Box p="3">
          <Flex direction="column" gap="3">
            <Flex gap="3" wrap="wrap" align="center" justify="between">

              {/* Search */}
              <div className="flex-1 min-w-[200px]">
                <TextField.Root
                  size="2"
                  color="indigo"
                  placeholder="Cari Peserta Magang…"
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

              {/* Group Filter */}
              <Flex gap="2" align="center" wrap="wrap" className="justify-end flex-1 sm:flex-none">
                <Select.Root
                  size="2"
                  defaultValue="Semua"
                  value={statusFilter}
                  onValueChange={(value) => setStatusFilter(value)}
                >
                  <Select.Trigger color="indigo" radius="large" placeholder="Status" className="min-w-[120px]" />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua Status</Select.Item>
                    <Select.Item value="VALID">Valid</Select.Item>
                    <Select.Item value="TERLAMBAT">Terlambat</Select.Item>
                    <Select.Item value="INVALID">Tidak Valid</Select.Item>
                  </Select.Content>
                </Select.Root>

                <Select.Root
                  size="2"
                  defaultValue="Semua"
                  value={typeFilter}
                  onValueChange={(value) => setTypeFilter(value)}
                >
                  <Select.Trigger color="indigo" radius="large" placeholder="Tipe" className="min-w-[100px]" />
                  <Select.Content color="indigo">
                    <Select.Item value="Semua">Semua Tipe</Select.Item>
                    <Select.Item value="MASUK">Masuk</Select.Item>
                    <Select.Item value="KELUAR">Keluar</Select.Item>
                    <Select.Item value="IZIN">Izin</Select.Item>
                    <Select.Item value="SAKIT">Sakit</Select.Item>
                    <Select.Item value="CUTI">Cuti</Select.Item>
                  </Select.Content>
                </Select.Root>

                <div className="w-auto">
                  <input
                    type="date"
                    value={dateFilter}
                    onChange={(e) => setDateFilter(e.target.value)}
                    className="bg-gray-50 border border-gray-200 text-xs text-gray-700 rounded-lg focus:ring-indigo-500 focus:border-indigo-500 block w-full p-1.5"
                  />
                </div>
              </Flex>
            </Flex>
          </Flex>
        </Box>
      </Card>

      {/* Absensi records - Compact Table */}
      <Card className="shadow-sm overflow-hidden">
        {/* Table Header Wrapper */}
        <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-gray-50/50" p="3">
          <Flex align="center" gap="2">
            <ClockIcon width="16" height="16" className="text-gray-700"/>
            <Text weight="bold" size="2" className="text-gray-900">Riwayat Kehadiran</Text>
          </Flex>

          {/* Rows Per Page */}
          <Flex align="center" gap="2">
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
          </Flex>
        </Flex>

        <Table.Root variant="surface" size="1">
          <Table.Header>
            <Table.Row className="bg-gray-50/80">
              <Table.ColumnHeaderCell className="p-3">Nama</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Tipe</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Waktu</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Lokasi</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Verifikasi</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {paginatedData.map((item) => (
              <Table.Row key={item.id} className="hover:bg-blue-50/30 transition-colors">
                <Table.Cell className="p-3">
                  <div className="flex items-center">
                    <Avatar
                      src={item.pesertaMagang.avatar}
                      alt={item.pesertaMagang.nama}
                      name={item.pesertaMagang.nama}
                      size="sm"
                      showBorder={true}
                      className="border-gray-200"
                    />
                    <div className="ml-3">
                      <div className="text-xs font-semibold text-gray-900">
                        {item.pesertaMagang.nama}
                      </div>
                      <div className="text-[10px] text-gray-500">
                        @{item.pesertaMagang.username}
                      </div>
                    </div>
                  </div>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle">
                  <TypeBadge tipe={item.tipe} />
                </Table.Cell>
                <Table.Cell className="p-3 align-middle">
                  <div className="text-xs text-gray-900">
                    {formatDateTime(item.createdAt) || "-"}
                  </div>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle">
                  <div className="text-xs text-gray-900 max-w-[150px] truncate" title={item.lokasi?.alamat}>
                    {item.lokasi?.alamat || "-"}
                  </div>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle">
                  <Flex align="center" gap="2">
                    <StatusIcon status={item.status} />
                    <StatusBadge status={item.status} />
                  </Flex>
                </Table.Cell>
                <Table.Cell className="p-3 align-middle" align="center">
                  <Flex gap="2" justify="center">
                    <Dialog.Root>
                      <Dialog.Trigger>
                        <IconButton
                          size="1"
                          color="blue"
                          variant="outline"
                          title="Lihat Detail"
                          className="cursor-pointer"
                        >
                          <EyeOpenIcon width="14" height="14" />
                        </IconButton>
                      </Dialog.Trigger>

                      <Dialog.Content className="p-0 overflow-hidden max-w-2xl">
                        <div className="p-6 border-b border-gray-100">
                          <Dialog.Title className="text-xl font-bold">Detail Absensi</Dialog.Title>
                        </div>

                        <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                          <div className="space-y-4">
                            <AspectRatio ratio={1}>
                              <img
                                src={item.selfieUrl}
                                alt="Selfie"
                                className="w-full h-full object-cover rounded-lg border border-gray-200 shadow-sm"
                              />
                            </AspectRatio>
                          </div>

                          <div className="space-y-4">
                            <div className="flex items-center gap-3 pb-4 border-b border-gray-100">
                              <Avatar
                                src={item.pesertaMagang.avatar}
                                alt={item.pesertaMagang.nama}
                                name={item.pesertaMagang.nama}
                                size="md"
                              />
                              <div>
                                <Text className="block text-sm font-bold text-gray-900">
                                  {item.pesertaMagang.nama}
                                </Text>
                                <Text className="block text-xs text-gray-500">
                                  @{item.pesertaMagang.username}
                                </Text>
                              </div>
                            </div>

                            <div className="grid grid-cols-2 gap-2 text-sm">
                              <Text className="text-gray-500 text-xs">Tipe</Text>
                              <div className="text-right"><TypeBadge tipe={item.tipe} /></div>

                              <Text className="text-gray-500 text-xs">Waktu</Text>
                              <Text className="text-right font-medium text-xs">{new Date(item.timestamp).toLocaleString()}</Text>

                              <Text className="text-gray-500 text-xs">Status</Text>
                              <div className="text-right"><StatusBadge status={item.status} /></div>
                            </div>

                            <div className="bg-gray-50 p-3 rounded-lg border border-gray-100 space-y-2">
                              <Text className="text-xs font-bold text-gray-700 block">Lokasi</Text>
                              <Text className="text-xs text-gray-600 block leading-relaxed">
                                {item.lokasi?.alamat || "Tidak ada data lokasi"}
                              </Text>
                              <Text className="text-[10px] text-gray-400 block font-mono">
                                {item.lokasi?.latitude}, {item.lokasi?.longitude}
                              </Text>
                            </div>

                            {item.catatan && (
                              <div className="bg-yellow-50 p-3 rounded-lg border border-yellow-100">
                                <Text className="text-xs font-bold text-yellow-800 block">Catatan</Text>
                                <Text className="text-xs text-yellow-700 block">{item.catatan}</Text>
                              </div>
                            )}
                          </div>
                        </div>

                        <div className="p-4 bg-gray-50 border-t border-gray-100 flex justify-end">
                          <Dialog.Close>
                            <Button variant="soft" color="gray">Tutup</Button>
                          </Dialog.Close>
                        </div>
                      </Dialog.Content>
                    </Dialog.Root>

                    <Dialog.Root>
                      <Dialog.Trigger>
                        <IconButton
                          size="1"
                          color="orange"
                          variant="outline"
                          title="Validasi Foto"
                          className="cursor-pointer"
                        >
                          <CameraIcon width="14" height="14" />
                        </IconButton>
                      </Dialog.Trigger>
                      <Dialog.Content className="max-w-md">
                        <Dialog.Title>Validasi Kehadiran</Dialog.Title>
                        <Dialog.Description size="2" className="mb-4">
                          Validasi kehadiran berdasarkan foto selfie peserta.
                        </Dialog.Description>

                        <div className="space-y-4">
                          <div className="relative rounded-lg overflow-hidden border border-gray-200">
                            <AspectRatio ratio={4/3}>
                              <img
                                src={item.selfieUrl || "../assets/placeholder.jpg"}
                                alt="Foto Selfie"
                                className="w-full h-full object-cover"
                              />
                            </AspectRatio>
                            <div className="absolute bottom-0 left-0 right-0 bg-black/50 p-2 text-white text-xs backdrop-blur-sm">
                              <p>Waktu: {new Date(item.timestamp).toLocaleTimeString()}</p>
                            </div>
                          </div>

                          <div className="flex gap-3 justify-end pt-2">
                            <Button
                              variant="soft"
                              color="red"
                              onClick={() => handleUpdateStatus(item.id, "INVALID")}
                              disabled={item.status === "INVALID"}
                            >
                              <CrossCircledIcon className="mr-1" /> Tidak Valid
                            </Button>
                            <Button
                              color="green"
                              onClick={() => handleUpdateStatus(item.id, "VALID")}
                              disabled={item.status === "VALID"}
                            >
                              <CheckCircledIcon className="mr-1" /> Valid
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
          <Box className="text-center py-10 bg-gray-50/30">
            <ClockIcon className="h-6 w-6 text-gray-300 mx-auto mb-2" />
            <Flex direction="column" justify="center">
              <Text size="2" color="gray" weight="medium">
                Tidak ada data absensi yang ditemukan
              </Text>
            </Flex>
          </Box>
        )}

        {/* Pagination Footer */}
        {filteredAbsensi.length > 0 && itemsPerPage !== "All" && (
          <Flex justify="between" align="center" p="3" className="border-t border-gray-100 bg-gray-50/30">
            <Text size="1" color="gray">
              Showing <span className="font-medium text-gray-900">{(currentPage - 1) * pageSize + 1}</span> to{" "}
              <span className="font-medium text-gray-900">{Math.min(currentPage * pageSize, totalItems)}</span> of{" "}
              <span className="font-medium text-gray-900">{totalItems}</span> entries
            </Text>

            <Flex gap="1" align="center">
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(1)} className="cursor-pointer">
                <DoubleArrowLeftIcon width="12" height="12" />
              </Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === 1} onClick={() => setCurrentPage(curr => Math.max(1, curr - 1))} className="cursor-pointer">
                <ChevronLeftIcon width="12" height="12" />
              </Button>

              <div className="flex gap-1 mx-1">{renderPaginationButtons()}</div>

              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(curr => Math.min(totalPages, curr + 1))} className="cursor-pointer">
                <ChevronRightIcon width="12" height="12" />
              </Button>
              <Button variant="soft" color="gray" size="1" disabled={currentPage === totalPages} onClick={() => setCurrentPage(totalPages)} className="cursor-pointer">
                <DoubleArrowRightIcon width="12" height="12" />
              </Button>
            </Flex>
          </Flex>
        )}
      </Card>
    </div>
  );
}