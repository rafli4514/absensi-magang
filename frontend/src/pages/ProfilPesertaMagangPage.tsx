import { useState } from "react";
import { useParams } from "react-router-dom";
import type { PesertaMagang, Absensi } from "../types";
import { formatDateTime } from "../lib/utils";
import {
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
  MixerHorizontalIcon,
  CalendarIcon,
  Pencil2Icon,
  TrashIcon,
  FileTextIcon,
} from "@radix-ui/react-icons";
import {
  User,
  Building,
  Phone,
} from "lucide-react";

// Mock data - replace with actual API calls
const mockPeserta: PesertaMagang = {
  id: "1",
  nama: "Ahmad Rizki Pratama",
  username: "ahmad",
  divisi: "IT",
  universitas: "Universitas Indonesia",
  nomorHp: "08123456789",
  tanggalMulai: "2024-01-01",
  tanggalSelesai: "2024-06-30",
  status: "Aktif",
  avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
  createdAt: "2024-01-01",
  updatedAt: "2024-01-01",
};

const mockAbsensi: Absensi[] = [
  {
    id: "1",
    pesertaMagangId: "1",
    tipe: "Masuk",
    timestamp: "2024-01-15T08:30:00Z",
    lokasi: {
      latitude: -6.2088,
      longitude: 106.8456,
      alamat: "Jakarta, Indonesia",
    },
    selfieUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
    qrCodeData: "QR123",
    status: "valid",
    createdAt: "2024-01-15T08:30:00Z",
  },
  {
    id: "2",
    pesertaMagangId: "1",
    tipe: "Keluar",
    timestamp: "2024-01-15T17:00:00Z",
    lokasi: {
      latitude: -6.2088,
      longitude: 106.8456,
      alamat: "Jakarta, Indonesia",
    },
    qrCodeData: "QR456",
    status: "valid",
    createdAt: "2024-01-15T17:00:00Z",
  },
  {
    id: "3",
    pesertaMagangId: "1",
    tipe: "Masuk",
    timestamp: "2024-01-16T08:45:00Z",
    qrCodeData: "QR789",
    status: "Terlambat",
    createdAt: "2024-01-16T08:45:00Z",
  },
  {
    id: "4",
    pesertaMagangId: "1",
    tipe: "Izin",
    timestamp: "2024-01-17T09:00:00Z",
    qrCodeData: "QR101",
    status: "valid",
    createdAt: "2024-01-17T09:00:00Z",
  },
];

const StatusIcon = ({ status }: { status: Absensi["status"] }) => {
  switch (status) {
    case "valid":
      return <CheckCircledIcon color="green" />;
    case "Terlambat":
      return <CircleBackslashIcon color="orange" />;
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

export default function ProfilPesertaMagangPage() {
  const { id } = useParams<{ id: string }>();
  // TODO: Use id to fetch specific peserta data from API
  const [peserta] = useState<PesertaMagang>(mockPeserta);
  const [absensi] = useState<Absensi[]>(mockAbsensi);
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [typeFilter, setTypeFilter] = useState<string>("Semua");

  // Dialog states
  const [selectedRecord, setSelectedRecord] = useState<Absensi | null>(null);
  const [showDetailDialog, setShowDetailDialog] = useState(false);
  const [showSelfieDialog, setShowSelfieDialog] = useState(false);
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [editForm, setEditForm] = useState({
    status: "valid" as Absensi["status"],
    notes: "",
  });

  // Action handlers
  const handleViewDetail = (record: Absensi) => {
    setSelectedRecord(record);
    setShowDetailDialog(true);
  };

  const handleViewSelfie = (record: Absensi) => {
    setSelectedRecord(record);
    setShowSelfieDialog(true);
  };

  const handleEditStatus = (record: Absensi) => {
    setSelectedRecord(record);
    setEditForm({
      status: record.status,
      notes: "",
    });
    setShowEditDialog(true);
  };

  const handleDeleteRecord = (record: Absensi) => {
    setSelectedRecord(record);
    setShowDeleteDialog(true);
  };

  const handleDownloadProof = (record: Absensi) => {
    // TODO: Implement actual download functionality
    console.log('Download proof for record:', record.id);
    alert('Fitur download bukti akan diimplementasikan');
  };

  const handleEditSubmit = () => {
    // TODO: Implement API call to update record
    console.log('Update record:', selectedRecord?.id, 'with:', editForm);
    alert('Status berhasil diperbarui');
    setShowEditDialog(false);
    setSelectedRecord(null);
  };

  const handleDeleteConfirm = () => {
    // TODO: Implement API call to delete record
    console.log('Delete record:', selectedRecord?.id);
    alert('Record berhasil dihapus');
    setShowDeleteDialog(false);
    setSelectedRecord(null);
  };

  // Calculate statistics
  const stats = {
    totalAbsensi: absensi.length,
    valid: absensi.filter(a => a.status === 'valid').length,
    terlambat: absensi.filter(a => a.status === 'Terlambat').length,
    invalid: absensi.filter(a => a.status === 'invalid').length,
    masuk: absensi.filter(a => a.tipe === 'Masuk').length,
    keluar: absensi.filter(a => a.tipe === 'Keluar').length,
    izin: absensi.filter(a => a.tipe === 'Izin').length,
  };

  // Calculate attendance rate
  const totalHariKerja = 22; // Assuming 22 working days in a month
  const hadir = stats.valid + stats.terlambat;
  const tingkatKehadiran = totalHariKerja > 0 ? (hadir / totalHariKerja) * 100 : 0;

  const filteredAbsensi = absensi.filter((record) => {
    const matchesStatus = statusFilter === "Semua" || record.status === statusFilter;
    const matchesType = typeFilter === "Semua" || record.tipe === typeFilter;

    return matchesStatus && matchesType;
  });

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Profil Peserta Magang
          </h1>
          <p className="text-gray-600">
            Detail informasi dan laporan kehadiran {peserta.nama}
          </p>
        </div>
        <Button size="2">
          <DownloadIcon className="mr-2" />
          Export Laporan
        </Button>
      </div>

      {/* Profile Information */}
      <Card>
        <Flex direction="column" gap="6" className="p-6">
          <Flex align="center" gap="6">
            <div className="h-24 w-24 flex-shrink-0">
              {peserta.avatar ? (
                <img
                  src={peserta.avatar}
                  alt={peserta.nama}
                  className="h-24 w-24 rounded-full object-cover border-4 border-blue-100"
                />
              ) : (
                <div className="h-24 w-24 rounded-full bg-primary-100 flex items-center justify-center border-4 border-blue-100">
                  <span className="text-2xl font-medium text-primary-600">
                    {peserta.nama.split(" ").map((n: string) => n[0]).join("")}
                  </span>
                </div>
              )}
            </div>
            <div className="flex-1">
              <h2 className="text-3xl font-bold text-gray-900">{peserta.nama}</h2>
              <p className="text-lg text-gray-600">@{peserta.username}</p>
              <div className="flex items-center gap-4 mt-2">
                <span className={`inline-flex px-3 py-1 text-sm font-medium rounded-full ${
                  peserta.status === "Aktif"
                    ? "bg-green-100 text-green-800"
                    : peserta.status === "Nonaktif"
                    ? "bg-gray-100 text-gray-800"
                    : "bg-blue-100 text-blue-800"
                }`}>
                  {peserta.status}
                </span>
                <span className="inline-flex px-3 py-1 text-sm font-medium rounded-full bg-blue-100 text-blue-800">
                  {peserta.divisi}
                </span>
              </div>
            </div>
          </Flex>

          {/* Profile Details */}
          <Grid columns={{ initial: "1", md: "2" }} gap="6">
            <div className="space-y-4">
              <div>
                <Text size="2" weight="bold" className="flex items-center gap-2">
                  <Building className="h-4 w-4" />
                  Universitas
                </Text>
                <Text size="3" className="text-gray-900">{peserta.universitas}</Text>
              </div>
              <div>
                <Text size="2" weight="bold" className="flex items-center gap-2">
                  <Phone className="h-4 w-4" />
                  Nomor Telepon
                </Text>
                <Text size="3" className="text-gray-900">{peserta.nomorHp}</Text>
              </div>
            </div>
            <div className="space-y-4">
              <div>
                <Text size="2" weight="bold" className="flex items-center gap-2">
                  <CalendarIcon className="h-4 w-4" />
                  Periode Magang
                </Text>
                <Text size="3" className="text-gray-900">
                  {new Date(peserta.tanggalMulai).toLocaleDateString('id-ID')} - {new Date(peserta.tanggalSelesai).toLocaleDateString('id-ID')}
                </Text>
              </div>
              <div>
                <Text size="2" weight="bold" className="flex items-center gap-2">
                  <User className="h-4 w-4" />
                  Bergabung Sejak
                </Text>
                <Text size="3" className="text-gray-900">
                  {new Date(peserta.createdAt).toLocaleDateString('id-ID')}
                </Text>
              </div>
            </div>
          </Grid>
        </Flex>
      </Card>

      {/* Attendance Statistics */}
      <Grid columns={{ initial: "1", md: "4" }} gap="4">
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Total Absensi
            </Text>
            <Text size="6" weight="bold">
              {stats.totalAbsensi}
            </Text>
            <Text size="1" color="gray">
              Record bulan ini
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Tingkat Kehadiran
            </Text>
            <Text size="6" weight="bold" color="green">
              {tingkatKehadiran.toFixed(1)}%
            </Text>
            <div className="flex justify-start">
              {getAttendanceRateBadge(tingkatKehadiran)}
            </div>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Terlambat
            </Text>
            <Text size="6" weight="bold" color="orange">
              {stats.terlambat}
            </Text>
            <Text size="1" color="gray">
              Kali terlambat
            </Text>
          </Flex>
        </Card>
        <Card>
          <Flex direction="column" p="4">
            <Text size="2" weight="bold" color="gray">
              Izin/Sakit
            </Text>
            <Text size="6" weight="bold" color="blue">
              {stats.izin}
            </Text>
            <Text size="1" color="gray">
              Hari izin/sakit
            </Text>
          </Flex>
        </Card>
      </Grid>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <Text weight="bold">Filter Riwayat Absensi</Text>
          </Flex>
          <Flex gap="4" wrap="wrap">
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
          </Flex>
        </Flex>
      </Box>

      {/* Attendance History */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="2">
            <Flex align="center" gap="2">
              <CalendarIcon width="18" height="18" />
              <Text weight="bold">Riwayat Absensi</Text>
            </Flex>
            <Text size="2" color="gray">
              {filteredAbsensi.length} record ditemukan
            </Text>
          </Flex>
          <Table.Root variant="ghost">
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeaderCell>Tanggal</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Tipe</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Waktu</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Lokasi</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Aksi</Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>
            <Table.Body>
              {filteredAbsensi.map((record) => (
                <Table.Row key={record.id} className="hover:bg-gray-50">
                  <Table.Cell>
                    <Text size="2">
                      {new Date(record.timestamp).toLocaleDateString("id-ID")}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <TypeBadge tipe={record.tipe} />
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" color="gray">
                      {formatDateTime(record.createdAt)}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Text size="2" color="gray">
                      {record.lokasi?.alamat || "Tidak tersedia"}
                    </Text>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex gap="2" align="center">
                      <StatusIcon status={record.status} />
                      <StatusBadge status={record.status} />
                    </Flex>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex gap="1" wrap="wrap">
                      <IconButton
                        size="1"
                        variant="outline"
                        color="blue"
                        onClick={() => handleViewDetail(record)}
                        title="Lihat Detail"
                      >
                        <EyeOpenIcon width="14" height="14" />
                      </IconButton>
                      {record.selfieUrl && (
                        <IconButton
                          size="1"
                          variant="outline"
                          color="green"
                          onClick={() => handleViewSelfie(record)}
                          title="Lihat Selfie"
                        >
                          <CameraIcon width="14" height="14" />
                        </IconButton>
                      )}
                      <IconButton
                        size="1"
                        variant="outline"
                        color="orange"
                        onClick={() => handleEditStatus(record)}
                        title="Edit Status"
                      >
                        <Pencil2Icon width="14" height="14" />
                      </IconButton>
                      <IconButton
                        size="1"
                        variant="outline"
                        color="red"
                        onClick={() => handleDeleteRecord(record)}
                        title="Hapus Record"
                      >
                        <TrashIcon width="14" height="14" />
                      </IconButton>
                      <IconButton
                        size="1"
                        variant="outline"
                        color="purple"
                        onClick={() => handleDownloadProof(record)}
                        title="Download Bukti"
                      >
                        <FileTextIcon width="14" height="14" />
                      </IconButton>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table.Root>
        </Card>
      </Box>

      {filteredAbsensi.length === 0 && (
        <Card>
          <Flex direction="column" align="center" p="8">
            <Text size="3" color="gray">
              Tidak ada data absensi yang ditemukan
            </Text>
          </Flex>
        </Card>
      )}

      {/* Detail Dialog */}
      <Dialog.Root open={showDetailDialog} onOpenChange={setShowDetailDialog}>
        <Dialog.Content style={{ maxWidth: 600 }}>
          <Dialog.Title>Detail Absensi</Dialog.Title>
          <Dialog.Description>
            Informasi lengkap record absensi
          </Dialog.Description>

          {selectedRecord && (
            <Flex direction="column" gap="4" mt="4">
              <Grid columns={{ initial: "1", md: "2" }} gap="4">
                <div>
                  <Text size="2" weight="bold">Tipe</Text>
                  <div className="mt-1">
                    <TypeBadge tipe={selectedRecord.tipe} />
                  </div>
                </div>
                <div>
                  <Text size="2" weight="bold">Status</Text>
                  <div className="mt-1">
                    <StatusBadge status={selectedRecord.status} />
                  </div>
                </div>
                <div>
                  <Text size="2" weight="bold">Tanggal</Text>
                  <Text size="3">{new Date(selectedRecord.timestamp).toLocaleDateString('id-ID')}</Text>
                </div>
                <div>
                  <Text size="2" weight="bold">Waktu</Text>
                  <Text size="3">{formatDateTime(selectedRecord.createdAt)}</Text>
                </div>
              </Grid>

              <div>
                <Text size="2" weight="bold">Lokasi</Text>
                <Text size="3">{selectedRecord.lokasi?.alamat || "Tidak tersedia"}</Text>
              </div>

              {selectedRecord.qrCodeData && (
                <div>
                  <Text size="2" weight="bold">QR Code</Text>
                  <Text size="3" className="font-mono">{selectedRecord.qrCodeData}</Text>
                </div>
              )}

              {selectedRecord.selfieUrl && (
                <div>
                  <Text size="2" weight="bold">Foto Selfie</Text>
                  <div className="mt-2">
                    <img
                      src={selectedRecord.selfieUrl}
                      alt="Selfie"
                      className="w-32 h-32 object-cover rounded-lg border"
                    />
                  </div>
                </div>
              )}
            </Flex>
          )}

          <Flex gap="3" mt="6" justify="end">
            <Dialog.Close>
              <Button variant="soft" color="gray">
                Tutup
              </Button>
            </Dialog.Close>
          </Flex>
        </Dialog.Content>
      </Dialog.Root>

      {/* Selfie Dialog */}
      <Dialog.Root open={showSelfieDialog} onOpenChange={setShowSelfieDialog}>
        <Dialog.Content style={{ maxWidth: 500 }}>
          <Dialog.Title>Foto Selfie</Dialog.Title>
          <Dialog.Description>
            Foto selfie saat absensi
          </Dialog.Description>

          {selectedRecord?.selfieUrl && (
            <Flex justify="center" mt="4">
              <img
                src={selectedRecord.selfieUrl}
                alt="Selfie"
                className="max-w-full max-h-96 object-contain rounded-lg border"
              />
            </Flex>
          )}

          <Flex gap="3" mt="6" justify="end">
            <Dialog.Close>
              <Button variant="soft" color="gray">
                Tutup
              </Button>
            </Dialog.Close>
          </Flex>
        </Dialog.Content>
      </Dialog.Root>

      {/* Edit Status Dialog */}
      <Dialog.Root open={showEditDialog} onOpenChange={setShowEditDialog}>
        <Dialog.Content style={{ maxWidth: 500 }}>
          <Dialog.Title>Edit Status Absensi</Dialog.Title>
          <Dialog.Description>
            Ubah status validasi absensi
          </Dialog.Description>

          <Flex direction="column" gap="4" mt="4">
            <div>
              <Text size="2" weight="bold" mb="2">Status</Text>
              <Select.Root
                value={editForm.status}
                onValueChange={(value) => setEditForm({ ...editForm, status: value as Absensi["status"] })}
              >
                <Select.Trigger />
                <Select.Content>
                  <Select.Item value="valid">Valid</Select.Item>
                  <Select.Item value="Terlambat">Terlambat</Select.Item>
                  <Select.Item value="invalid">Tidak Valid</Select.Item>
                </Select.Content>
              </Select.Root>
            </div>

            <div>
              <Text size="2" weight="bold" mb="2">Catatan (Opsional)</Text>
              <TextField.Root
                placeholder="Tambahkan catatan..."
                value={editForm.notes}
                onChange={(e) => setEditForm({ ...editForm, notes: e.target.value })}
              />
            </div>
          </Flex>

          <Flex gap="3" mt="6" justify="end">
            <Dialog.Close>
              <Button variant="soft" color="gray">
                Batal
              </Button>
            </Dialog.Close>
            <Button onClick={handleEditSubmit}>
              Simpan Perubahan
            </Button>
          </Flex>
        </Dialog.Content>
      </Dialog.Root>

      {/* Delete Confirmation Dialog */}
      <Dialog.Root open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <Dialog.Content style={{ maxWidth: 450 }}>
          <Dialog.Title>Hapus Record Absensi</Dialog.Title>
          <Dialog.Description>
            Apakah Anda yakin ingin menghapus record absensi ini? Tindakan ini tidak dapat dibatalkan.
          </Dialog.Description>

          {selectedRecord && (
            <Card mt="4">
              <Flex direction="column" gap="2">
                <Text size="2">
                  <strong>Tipe:</strong> <TypeBadge tipe={selectedRecord.tipe} />
                </Text>
                <Text size="2">
                  <strong>Tanggal:</strong> {new Date(selectedRecord.timestamp).toLocaleDateString('id-ID')}
                </Text>
                <Text size="2">
                  <strong>Status:</strong> <StatusBadge status={selectedRecord.status} />
                </Text>
              </Flex>
            </Card>
          )}

          <Flex gap="3" mt="6" justify="end">
            <Dialog.Close>
              <Button variant="soft" color="gray">
                Batal
              </Button>
            </Dialog.Close>
            <Button variant="solid" color="red" onClick={handleDeleteConfirm}>
              Hapus Record
            </Button>
          </Flex>
        </Dialog.Content>
      </Dialog.Root>
    </div>
  );
}
