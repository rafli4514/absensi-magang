import { useState } from "react";
import type { PesertaMagang } from "../types/index";
import {
  AlertDialog,
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
import {
  EyeOpenIcon,
  MagnifyingGlassIcon,
  Pencil2Icon,
  TrashIcon,
} from "@radix-ui/react-icons";

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
    status: "Aktif",
    createdAt: "2025-08-01",
    updatedAt: "2025-08-01",
  },
];

const StatusBadge = ({ status }: { status: PesertaMagang["status"] }) => {
  const statusConfig = {
    Aktif: { color: "bg-success-100 text-success-800", label: "Aktif" },
    Nonaktif: { color: "bg-gray-100 text-gray-800", label: "Tidak Aktif" },
    Selesai: { color: "bg-primary-100 text-primary-800", label: "Selesai" },
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
  const [statusFilter, setStatusFilter] = useState<string>("Semua");

  const filteredPesertaMagang = pesertaMagang.filter((item) => {
    const matchesSearch =
      item.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.id.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || item.status === statusFilter;

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
                <div>
                  <label className="block mb-2 font-semibold text-gray-700">
                    Status
                  </label>
                  <Select.Root size="2" defaultValue="Aktif">
                    <Select.Trigger
                      className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      color="indigo"
                      // variant="soft"
                      radius="large"
                    />
                    <Select.Content color="indigo">
                      <Select.Item value="Aktif">Aktif</Select.Item>
                      <Select.Item value="Nonaktif">Tidak Aktif</Select.Item>
                      <Select.Item value="Selesai">Selesai</Select.Item>
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
                    Tanggal Mulai
                  </label>
                  <TextField.Root
                    type="date"
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Tanggal Selesai
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
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex className="flex flex-col sm:flex-row gap-4">
          <Flex className="flex items-center w-full relative">
            <TextField.Root
              color="indigo"
              placeholder="Cari Peserta Magang…"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full"
            />
          </Flex>
          <IconButton variant="surface" color="gray">
            <MagnifyingGlassIcon width="18" height="18" />
          </IconButton>
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
                <Select.Item value="Nonaktif">Tidak Aktif</Select.Item>
                <Select.Item value="Selesai">Selesai</Select.Item>
              </Select.Content>
            </Select.Root>
          </div>
        </Flex>
      </Box>

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
                    <Flex align="center" gap="2">
                      {/* Detail User */}
                      <IconButton color="blue" variant="outline" highContrast>
                        <EyeOpenIcon width="18" height="18" />
                      </IconButton>

                      {/* Edit User */}
                      <Dialog.Root>
                        {/* Dialog Trigger  */}
                        <Dialog.Trigger>
                          <IconButton
                            color="blue"
                            variant="outline"
                          >
                            <Pencil2Icon width="18" height="18" />
                          </IconButton>
                        </Dialog.Trigger>
                        {/* Dialog Content */}
                        <Dialog.Content maxWidth="850px">
                          <Dialog.Title>Edit Peserta Magang</Dialog.Title>
                          <Dialog.Description size="2" mb="4">
                            Edit data peserta magang dengan lengkap.
                          </Dialog.Description>
                          {/* Form Fields*/}
                          <Flex direction="column" gap="6">
                            {/* row 1: Nama Lengkap */}
                            <div className="w-full">
                              <label className="block mb-2 font-semibold text-gray-700">
                                Nama Lengkap
                              </label>
                              <TextField.Root
                                placeholder="Masukkan nama lengkap"
                                defaultValue={item.nama}
                                className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                              />
                            </div>
                            {/* row 2: Username */}
                            <div className="w-full">
                              <label className="block mb-2 font-semibold text-gray-700">
                                Username
                              </label>
                              <TextField.Root
                                placeholder="Masukkan Username"
                                defaultValue={item.username}
                                className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                              />
                            </div>

                            {/* row 3: Nomor HP and Status */}
                            <div className="flex flex-col sm:flex-row gap-4">
                              <div className="w-full">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Nomor HP
                                </label>
                                <TextField.Root
                                  placeholder="Masukkan Nomor HP"
                                  defaultValue={item.nomorHp}
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                              <div>
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Status
                                </label>
                                <Select.Root
                                  size="2"
                                  defaultValue={item.status}
                                >
                                  <Select.Trigger
                                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                    color="indigo"
                                    // variant="soft"
                                    radius="large"
                                  />
                                  <Select.Content color="indigo">
                                    <Select.Item value="Aktif">
                                      Aktif
                                    </Select.Item>
                                    <Select.Item value="Nonaktif">
                                      Tidak Aktif
                                    </Select.Item>
                                    <Select.Item value="Selesai">
                                      Selesai
                                    </Select.Item>
                                  </Select.Content>
                                </Select.Root>  
                              </div>
                            </div>

                            {/* row 4: Divisi and Universitas */}
                            <div className="flex flex-col sm:flex-row gap-4">
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Divisi
                                </label>
                                <TextField.Root
                                  placeholder="Masukkan Divisi"
                                  defaultValue={item.divisi}
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Universitas
                                </label>
                                <TextField.Root
                                  placeholder="Masukkan Universitas"
                                  defaultValue={item.universitas}
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                            </div>

                            {/* row 5: Tanggal Mulai dan Tanggal Selesai */}
                            <div className="flex flex-col sm:flex-row gap-4">
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Tanggal Mulai
                                </label>
                                <TextField.Root
                                  type="date"
                                  defaultValue={item.TanggalMulai}
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Tanggal Selesai
                                </label>
                                <TextField.Root
                                  type="date"
                                  defaultValue={item.TanggalSelesai}
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                            </div>
                          </Flex>

                          {/* Action Buttons */}
                          <div className="mt-6 flex justify-end gap-4">
                            {/* Batal */}
                            <Dialog.Close>
                              <Button
                                variant="soft"
                                color="gray"
                                className="px-6 py-2 rounded-lg"
                              >
                                Batal
                              </Button>
                            </Dialog.Close>
                            {/* Simpan */}
                            <Dialog.Close>
                              <Button className="px-6 py-2 bg-indigo-600 text-white rounded-lg">
                                Simpan
                              </Button>
                            </Dialog.Close>
                          </div>
                        </Dialog.Content>
                      </Dialog.Root>

                      {/* Delete User */}
                      <AlertDialog.Root>
                        {/* AlertDialog.Trigger */}
                        <AlertDialog.Trigger>
                          {/* icon button */}
                          <IconButton color="red" variant="outline">
                            <TrashIcon width="18" height="18" color="red" />
                          </IconButton>
                        </AlertDialog.Trigger>
                        <AlertDialog.Content>
                          <AlertDialog.Title>Hapus Pengguna</AlertDialog.Title>
                          <AlertDialog.Description>
                            Apakah Anda yakin ingin menghapus peserta magang{" "}
                            <strong>{item.nama}</strong>?
                          </AlertDialog.Description>
                          <Flex gap="3" mt="4" justify="end">
                            <AlertDialog.Cancel>
                              <Button variant="soft" color="gray">
                                Batal
                              </Button>
                            </AlertDialog.Cancel>
                            <AlertDialog.Action>
                              <Button variant="solid" color="red">
                                Hapus
                              </Button>
                            </AlertDialog.Action>
                          </Flex>
                        </AlertDialog.Content>
                      </AlertDialog.Root>
                    </Flex>
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
