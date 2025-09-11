import { useState } from "react";
import { Edit, Trash2, Eye } from "lucide-react";
import type { PesertaMagang } from "../types/index";
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
} from "@radix-ui/themes/components/index";
import { MagnifyingGlassIcon } from "@radix-ui/react-icons";

// Mock data - replace with actual API calls
const mockPesertaMagang: PesertaMagang[] = [
  {
    id: "1",
    nama: "Mamad Supratman",
    username: "Mamad",
    divisi: "IT",
    universitas: "Universitas Apa Coba",
    nomorHp: "08123456789",
    TanggalMulai: "2025-09-04",
    TanggalSelesai: "2026-01-04",
    status: "active",
    createdAt: "2025-08-01",
    updatedAt: "2025-08-01",
  },
];

const StatusBadge = ({ status }: { status: PesertaMagang["status"] }) => {
  const statusConfig = {
    active: { color: "bg-success-100 text-success-800", label: "Aktif" },
    inactive: { color: "bg-gray-100 text-gray-800", label: "Tidak Aktif" },
    completed: { color: "bg-primary-100 text-primary-800", label: "Selesai" },
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

export default function PesertaMagang() {
  const [pesertaMagang] = useState<PesertaMagang[]>(mockPesertaMagang);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("semua");
  const [showAddModal, setShowAddModal] = useState(false);

  const filteredPesertaMagang = pesertaMagang.filter((item) => {
    const matchesSearch =
      item.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.id.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "all" || item.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Manajemen peserta{" "}
          </h1>
          <p className="text-gray-600">Kelola data peserta magang/PKL</p>
        </div>
        <Dialog.Root>
          <Dialog.Trigger>
            <Button>Tambah Peserta Magang</Button>
          </Dialog.Trigger>

          <Dialog.Content maxWidth="850px">
            <Dialog.Title>Tambah Peserta Magang</Dialog.Title>
            <Dialog.Description size="2" mb="4">
              Isi data peserta magang baru dengan lengkap.
            </Dialog.Description>

            <Flex direction="column" gap="6">
              <div className="w-full">
                <label className="block mb-2 font-semibold text-gray-700">
                  Nama Lengkap
                </label>
                <TextField.Root
                  placeholder="Masukkan nama lengkap"
                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div className="w-full">
                <label className="block mb-2 font-semibold text-gray-700">
                  Username
                </label>
                <TextField.Root
                  placeholder="Masukkan Username"
                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              {/* Third Row: Nomor HP and Tanggal Mulai */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Nomor HP
                  </label>
                  <TextField.Root
                    placeholder="Masukkan Nomor HP"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Status
                  </label>
                  <Select.Root
                    size="2"
                    defaultValue="aktif"
                    // className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  >
                    <Select.Trigger
                      color="indigo"
                      variant="soft"
                      radius="large"
                    />
                    <Select.Content color="indigo">
                      <Select.Item value="aktif">Aktif</Select.Item>
                      <Select.Item value="tidak aktif">Tidak Aktif</Select.Item>
                      <Select.Item value="selesai">Selesai</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </div>
              </div>

              {/* Second Row: Divisi and Universitas */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Divisi
                  </label>
                  <TextField.Root
                    placeholder="Masukkan Divisi"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Universitas
                  </label>
                  <TextField.Root
                    placeholder="Masukkan Universitas"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
              </div>

              {/* Fourth Row: Tanggal Selesai and Status */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Tanggal Selesai
                  </label>
                  <TextField.Root
                    type="date"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>

                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Tanggal Mulai
                  </label>
                  <TextField.Root
                    type="date"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
              </div>
            </Flex>

            {/* Action Buttons */}
            <div className="mt-6 flex justify-end gap-4">
              <Dialog.Close>
                <Button
                  variant="soft"
                  color="gray"
                  className="px-6 py-2 rounded-lg"
                >
                  Batal
                </Button>
              </Dialog.Close>
              <Dialog.Close>
                <Button className="px-6 py-2 bg-indigo-600 text-white rounded-lg">
                  Simpan
                </Button>
              </Dialog.Close>
            </div>
          </Dialog.Content>
        </Dialog.Root>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 shadow-md rounded-2xl">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex items-center w-full relative">
            <TextField.Root
              color="indigo"
              variant="soft"
              placeholder="Cari Peserta Magang…"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 focus:outline-none"
            />
          </div>
          <IconButton variant="surface">
            <MagnifyingGlassIcon width="18" height="18" />
          </IconButton>
          <div className="flex items-center">
            <Select.Root
              size="2"
              defaultValue="Semua"
              value={statusFilter}
              onValueChange={(value) => setStatusFilter(value)}
            >
              <Select.Trigger color="indigo" variant="soft" radius="large" />
              <Select.Content color="indigo">
                <Select.Item value="Semua">Semua</Select.Item>
                <Select.Item value="Aktif">Aktif</Select.Item>
                <Select.Item value="Tidak Aktif">Tidak Aktif</Select.Item>
                <Select.Item value="Selesai">Selesai</Select.Item>
              </Select.Content>
            </Select.Root>
          </div>
        </div>
      </div>

      <Box>
        <Card>
          <Table.Root variant="ghost">
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeaderCell>Nama</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Divisi</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Universitas</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Nomor HP</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Periode</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Aksi</Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>

            <Table.Body>
              {filteredPesertaMagang.map((item) => (
                <Table.Row key={item.id} className="hover:bg-gray-50">
                  <Table.Cell>
                    <div className="flex items-center">
                      <div className="h-10 w-10 flex-shrink-0">
                        <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center">
                          <span className="text-sm font-medium text-primary-600">
                            {item.nama
                              .split(" ")
                              .map((n: string) => n[0])
                              .join("")}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {item.nama}
                        </div>
                        <div className="text-sm text-gray-500">
                          {item.username}
                        </div>
                      </div>
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-500">{item.divisi}</div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">
                      {item.universitas}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">{item.nomorHp}</div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">
                      {new Date(item.TanggalMulai).toLocaleDateString("id-ID")}
                    </div>
                    <div className="text-sm text-gray-900">
                      s/d{" "}
                      {new Date(item.TanggalSelesai).toLocaleDateString(
                        "id-ID"
                      )}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <StatusBadge status={item.status} />
                  </Table.Cell>
                  <Table.Cell>
                    <div className="flex items-center justify-end space-x-2">
                      <button className="text-primary-600 hover:text-primary-900">
                        <Eye className="h-4 w-4" />
                      </button>
                      <button className="text-gray-600 hover:text-gray-900">
                        <Edit className="h-4 w-4" />
                      </button>
                      <button className="text-danger-600 hover:text-danger-900">
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table.Body>
          </Table.Root>
        </Card>
      </Box>

      {/* Add pesertaMagang Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Tambah Peserta Magang
            </h3>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowAddModal(false)}
                className="btn-secondary"
              >
                Batal
              </button>
              <button className="btn-primary">Simpan</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
