import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
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
  Text,
  TextField,
} from "@radix-ui/themes/components/index";
import {
  EyeOpenIcon,
  Pencil2Icon,
  TrashIcon,
  MixerHorizontalIcon,
  ClockIcon,
} from "@radix-ui/react-icons";
import pesertaMagangService from "../services/pesertaMagangService";
import Avatar from "../components/Avatar";

const StatusBadge = ({ status }: { status: PesertaMagang["status"] }) => {
  const statusConfig = {
    AKTIF: { color: "bg-success-100 text-success-800", label: "Aktif" },
    NONAKTIF: { color: "bg-gray-100 text-gray-800", label: "Tidak Aktif" },
    SELESAI: { color: "bg-primary-100 text-primary-800", label: "Selesai" },
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

export default function PesertaMagang() {
  const [pesertaMagang, setPesertaMagang] = useState<PesertaMagang[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [isCreating, setIsCreating] = useState(false);
  const [isUpdating, setIsUpdating] = useState<string | null>(null);
  const [currentEditingId, setCurrentEditingId] = useState<string | null>(null);

  // Form states for create/edit
  const [formData, setFormData] = useState({
    nama: "",
    username: "",
    divisi: "",
    instansi: "",
    id_instansi: "",
    nomorHp: "",
    tanggalMulai: "",
    tanggalSelesai: "",
    status: "AKTIF" as PesertaMagang["status"],
    password: "",
  });

  const [updateFormData, setUpdateFormData] = useState<Partial<PesertaMagang>>(
    {}
  );

  // Fetch data on component mount
  useEffect(() => {
    fetchPesertaMagang();
  }, []);

  const fetchPesertaMagang = async () => {
    try {
      setLoading(true);
      const response = await pesertaMagangService.getPesertaMagang();
      if (response.success && response.data) {
        setPesertaMagang(response.data);
      } else {
        setError(response.message || "Failed to fetch peserta magang");
      }
    } catch (error: unknown) {
      console.error("Fetch peserta magang error:", error);
      setError("Failed to fetch peserta magang");
    } finally {
      setLoading(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !isCreating) {
      e.preventDefault();
      handleCreate();
    }
  };

  const handleUpdateKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !isUpdating && currentEditingId) {
      e.preventDefault();
      handleUpdate(currentEditingId);
    }
  };

  const handleCreate = async () => {
    try {
      setIsCreating(true);
      const response = await pesertaMagangService.createPesertaMagang(formData);
      if (response.success) {
        await fetchPesertaMagang();
        setFormData({
          nama: "",
          username: "",
          divisi: "",
          instansi: "",
          id_instansi: "",
          nomorHp: "",
          tanggalMulai: "",
          tanggalSelesai: "",
          status: "AKTIF",
          password: "",
        });
      } else {
        setError(response.message || "Failed to create peserta magang");
      }
    } catch (error: unknown) {
      console.error("Create peserta magang error:", error);
      setError("Failed to create peserta magang");
    } finally {
      setIsCreating(false);
    }
  };

  const handleUpdate = async (id: string) => {
    try {
      setIsUpdating(id);
      const response = await pesertaMagangService.updatePesertaMagang(
        id,
        updateFormData
      );
      if (response.success) {
        await fetchPesertaMagang();
        setUpdateFormData({});
      } else {
        setError(response.message || "Failed to update peserta magang");
      }
    } catch (error: unknown) {
      console.error("Update peserta magang error:", error);
      setError("Failed to update peserta magang");
    } finally {
      setIsUpdating(null);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const response = await pesertaMagangService.deletePesertaMagang(id);
      if (response.success) {
        await fetchPesertaMagang();
      } else {
        setError(response.message || "Failed to delete peserta magang");
      }
    } catch (error: unknown) {
      console.error("Delete peserta magang error:", error);
      setError("Failed to delete peserta magang");
    }
  };

  const initializeUpdateForm = (item: PesertaMagang) => {
    setCurrentEditingId(item.id);
    setUpdateFormData({
      nama: item.nama,
      username: item.username,
      divisi: item.divisi,
      instansi: item.instansi,
      id_instansi: item.id_instansi,
      nomorHp: item.nomorHp,
      tanggalMulai: item.tanggalMulai,
      tanggalSelesai: item.tanggalSelesai,
      status: item.status,
      avatar: item.avatar,
    });
  };

  const handleAvatarUpload = async (id: string, file: File) => {
    try {
      console.log("Uploading avatar for ID:", id);
      console.log("File:", file);

      const formData = new FormData();
      formData.append("avatar", file);

      const response = await fetch(
        `http://localhost:3000/api/peserta-magang/${id}/upload-avatar`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          body: formData,
        }
      );

      console.log("Response status:", response.status);

      if (response.ok) {
        const result = await response.json();
        console.log("Upload result:", result);
        if (result.success) {
          await fetchPesertaMagang();
          setUpdateFormData({
            ...updateFormData,
            avatar: result.data.avatarUrl,
          });
        } else {
          setError(result.message || "Failed to upload avatar");
        }
      } else {
        const errorText = await response.text();
        console.error("Upload error response:", errorText);
        setError(
          `Failed to upload avatar: ${response.status} ${response.statusText}`
        );
      }
    } catch (error) {
      console.error("Avatar upload error:", error);
      setError("Failed to upload avatar: " + (error as Error).message);
    }
  };

  const filteredPesertaMagang = pesertaMagang.filter((item) => {
    const matchesSearch =
      item.nama.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.id.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "Semua" || item.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading peserta magang...</p>
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

          <Dialog.Content maxWidth="850px" onKeyDown={handleKeyDown}>
            <Dialog.Title>Tambah Peserta Magang</Dialog.Title>
            <Dialog.Description size="2" mb="4">
              Isi data peserta magang baru dengan lengkap. Tekan <kbd className="px-2 py-1 bg-gray-100 rounded text-sm">Enter</kbd> untuk menyimpan.
            </Dialog.Description>

            <Flex direction="column" gap="6">
              <div className="w-full">
                <label className="block mb-2 font-semibold text-gray-700">
                  Nama Lengkap
                </label>
                <TextField.Root
                  placeholder="Masukkan nama lengkap"
                  value={formData.nama}
                  onChange={(e) =>
                    setFormData({ ...formData, nama: e.target.value })
                  }
                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div className="w-full">
                <label className="block mb-2 font-semibold text-gray-700">
                  Username
                </label>
                <TextField.Root
                  placeholder="Masukkan Username"
                  value={formData.username}
                  onChange={(e) =>
                    setFormData({ ...formData, username: e.target.value })
                  }
                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              {/* Third Row: Nomor HP and Status */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Nomor HP
                  </label>
                  <TextField.Root
                    placeholder="Masukkan Nomor HP"
                    value={formData.nomorHp}
                    onChange={(e) =>
                      setFormData({ ...formData, nomorHp: e.target.value })
                    }
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Status
                  </label>
                  <Select.Root
                    size="2"
                    value={formData.status}
                    onValueChange={(value) =>
                      setFormData({
                        ...formData,
                        status: value as PesertaMagang["status"],
                      })
                    }
                  >
                    <Select.Trigger
                      className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      color="indigo"
                      radius="large"
                    />
                    <Select.Content color="indigo">
                      <Select.Item value="AKTIF">Aktif</Select.Item>
                      <Select.Item value="NONAKTIF">Tidak Aktif</Select.Item>
                      <Select.Item value="SELESAI">Selesai</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </div>
              </div>

              {/* Second Row: Password */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Password Awal
                  </label>
                  <TextField.Root
                    type="password"
                    placeholder="Masukkan Password Awal"
                    value={formData.password}
                    onChange={(e) =>
                      setFormData({ ...formData, password: e.target.value })
                    }
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                  <p className="text-sm text-gray-500 mt-1">
                    Password ini akan digunakan peserta magang untuk login pertama kali
                  </p>
                </div>
              </div>

              {/* Third Row: Divisi and Instansi */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Divisi
                  </label>
                  <TextField.Root
                    placeholder="Masukkan Divisi"
                    value={formData.divisi}
                    onChange={(e) =>
                      setFormData({ ...formData, divisi: e.target.value })
                    }
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Instansi
                  </label>
                  <TextField.Root
                    placeholder="Masukkan Instansi"
                    value={formData.instansi}
                    onChange={(e) =>
                      setFormData({ ...formData, instansi: e.target.value })
                    }
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
              </div>

              {/* ID Instansi */}
              <div className="w-full">
                <label className="block mb-2 font-semibold text-gray-700">
                  ID Peserta/Student ID
                </label>
                <TextField.Root
                  placeholder="Masukkan ID Peserta"
                  value={formData.id_instansi}
                  onChange={(e) =>
                    setFormData({ ...formData, id_instansi: e.target.value })
                  }
                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
                <p className="text-sm text-gray-500 mt-1">
                  ID unik peserta magang (NIM/NIS/ID lainnya)
                </p>
              </div>

              {/* Fourth Row: Tanggal Selesai and Status */}
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Tanggal Mulai
                  </label>
                  <TextField.Root
                    type="date"
                    value={formData.tanggalMulai}
                    onChange={(e) =>
                      setFormData({ ...formData, tanggalMulai: e.target.value })
                    }
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
                <div className="w-full sm:w-1/2">
                  <label className="block mb-2 font-semibold text-gray-700">
                    Tanggal Selesai
                  </label>
                  <TextField.Root
                    type="date"
                    value={formData.tanggalSelesai}
                    onChange={(e) =>
                      setFormData({
                        ...formData,
                        tanggalSelesai: e.target.value,
                      })
                    }
                    className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                </div>
              </div>
            </Flex>

            {/* Avatar Upload - placed at bottom */}
            <div className="mt-4 w-full">
              <label className="block mb-2 font-semibold text-gray-700">
                Avatar
              </label>
              <div className="w-full border-2 border-dashed border-gray-300 rounded-xl p-4">
                <input
                  type="file"
                  accept="image/*"
                  className="block w-full text-base file:mr-4 file:py-3 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100"
                />
                <p className="mt-2 text-xs text-gray-500">
                  PNG, JPG, atau JPEG.
                </p>
              </div>
            </div>

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
                <Button
                  className="px-6 py-2 bg-indigo-600 text-white rounded-lg"
                  onClick={handleCreate}
                  disabled={isCreating}
                >
                  {isCreating ? (
                    <div className="flex items-center">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Menyimpan...
                    </div>
                  ) : (
                    "Simpan"
                  )}
                </Button>
              </Dialog.Close>
            </div>
          </Dialog.Content>
        </Dialog.Root>
      </div>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <h3 className="text-lg font-semibold text-gray-900">
              Filter Peserta Magang
            </h3>
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
                  <Select.Item value="NONAKTIF">Tidak Aktif</Select.Item>
                  <Select.Item value="SELESAI">Selesai</Select.Item>
                </Select.Content>
              </Select.Root>
            </div>
          </Flex>
        </Flex>
      </Box>

      <Box>
        <Card>
          <Table.Root variant="ghost">
            <Table.Header>
              <Table.Row>
                <Table.ColumnHeaderCell>Nama</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>ID Peserta</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Instansi</Table.ColumnHeaderCell>
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
                      <Avatar
                        src={item.avatar}
                        alt={item.nama}
                        name={item.nama}
                        size="lg"
                        showBorder={true}
                        showHover={true}
                        className="border-gray-200"
                      />
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
                    <div className="text-sm text-gray-500">{item.id_instansi || '-'}</div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">{item.instansi}</div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">{item.nomorHp}</div>
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-900">
                      {new Date(item.tanggalMulai).toLocaleDateString("id-ID")}
                    </div>
                    <div className="text-sm text-gray-900">
                      s/d{" "}
                      {new Date(item.tanggalSelesai).toLocaleDateString(
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
                      <Link to={`/profil-peserta/${item.id}`}>
                        <IconButton color="blue" variant="outline" highContrast>
                          <EyeOpenIcon width="18" height="18" />
                        </IconButton>
                      </Link>

                      {/* Edit User */}
                      <Dialog.Root>
                        {/* Dialog Trigger  */}
                        <Dialog.Trigger>
                          <IconButton
                            color="blue"
                            variant="outline"
                            onClick={() => initializeUpdateForm(item)}
                          >
                            <Pencil2Icon width="18" height="18" />
                          </IconButton>
                        </Dialog.Trigger>
                        {/* Dialog Content */}
                        <Dialog.Content maxWidth="850px" onKeyDown={handleUpdateKeyDown}>
                          <Dialog.Title>Edit Peserta Magang</Dialog.Title>
                          <Dialog.Description size="2" mb="4">
                            Edit data peserta magang dengan lengkap. Tekan <kbd className="px-2 py-1 bg-gray-100 rounded text-sm">Enter</kbd> untuk menyimpan.
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
                                value={updateFormData.nama || ""}
                                onChange={(e) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    nama: e.target.value,
                                  })
                                }
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
                                value={updateFormData.username || ""}
                                onChange={(e) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    username: e.target.value,
                                  })
                                }
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
                                  value={updateFormData.nomorHp || ""}
                                  onChange={(e) =>
                                    setUpdateFormData({
                                      ...updateFormData,
                                      nomorHp: e.target.value,
                                    })
                                  }
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                              <div>
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Status
                                </label>
                                <Select.Root
                                  size="2"
                                  value={updateFormData.status || "AKTIF"}
                                  onValueChange={(value) =>
                                    setUpdateFormData({
                                      ...updateFormData,
                                      status: value as PesertaMagang["status"],
                                    })
                                  }
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

                            {/* row 4: Divisi and Instansi */}
                            <div className="flex flex-col sm:flex-row gap-4">
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Divisi
                                </label>
                                <TextField.Root
                                  placeholder="Masukkan Divisi"
                                  value={updateFormData.divisi || ""}
                                  onChange={(e) =>
                                    setUpdateFormData({
                                      ...updateFormData,
                                      divisi: e.target.value,
                                    })
                                  }
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Instansi
                                </label>
                                <TextField.Root
                                  placeholder="Masukkan Instansi"
                                  value={updateFormData.instansi || ""}
                                  onChange={(e) =>
                                    setUpdateFormData({
                                      ...updateFormData,
                                      instansi: e.target.value,
                                    })
                                  }
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                            </div>

                            {/* ID Instansi */}
                            <div className="w-full">
                              <label className="block mb-2 font-semibold text-gray-700">
                                ID Peserta/Student ID
                              </label>
                              <TextField.Root
                                placeholder="Masukkan ID Peserta"
                                value={updateFormData.id_instansi || ""}
                                onChange={(e) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    id_instansi: e.target.value,
                                  })
                                }
                                className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                              />
                            </div>

                            {/* row 5: Tanggal Mulai dan Tanggal Selesai */}
                            <div className="flex flex-col sm:flex-row gap-4">
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Tanggal Mulai
                                </label>
                                <TextField.Root
                                  type="date"
                                  value={updateFormData.tanggalMulai || ""}
                                  onChange={(e) =>
                                    setUpdateFormData({
                                      ...updateFormData,
                                      tanggalMulai: e.target.value,
                                    })
                                  }
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                              <div className="w-full sm:w-1/2">
                                <label className="block mb-2 font-semibold text-gray-700">
                                  Tanggal Selesai
                                </label>
                                <TextField.Root
                                  type="date"
                                  value={updateFormData.tanggalSelesai || ""}
                                  onChange={(e) =>
                                    setUpdateFormData({
                                      ...updateFormData,
                                      tanggalSelesai: e.target.value,
                                    })
                                  }
                                  className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                                />
                              </div>
                            </div>
                          </Flex>

                          {/* Avatar Upload - placed at bottom */}
                          <div className="mt-2 w-full">
                            <label className="block mb-2 font-semibold text-gray-700">
                              Avatar
                            </label>
                            <div className="w-full border-2 border-dashed border-gray-300 rounded-xl p-4">
                              <input
                                type="file"
                                accept="image/*"
                                onChange={(e) => {
                                  const file = e.target.files?.[0];
                                  if (file) {
                                    handleAvatarUpload(item.id, file);
                                  }
                                }}
                                className="block w-full text-base file:mr-4 file:py-3 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100"
                              />
                              <p className="mt-2 text-xs text-gray-500">
                                PNG, JPG, atau JPEG.
                              </p>
                            </div>
                          </div>

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
                              <Button
                                className="px-6 py-2 bg-indigo-600 text-white rounded-lg"
                                onClick={() => handleUpdate(item.id)}
                                disabled={isUpdating === item.id}
                              >
                                {isUpdating === item.id ? (
                                  <div className="flex items-center">
                                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                                    Menyimpan...
                                  </div>
                                ) : (
                                  "Simpan"
                                )}
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
                              <Button
                                variant="solid"
                                color="red"
                                onClick={() => handleDelete(item.id)}
                              >
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
          {filteredPesertaMagang.length === 0 && (
            <Box className="text-center py-12">
              <ClockIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <Flex direction="column" justify="center">
                <Text size="3" color="gray" weight="medium">
                  Tidak ada data Peserta Magang yang ditemukan
                </Text>
                <Text size="3" color="gray" mt="2">
                  {searchTerm
                    ? "Coba ubah kata kunci pencarian"
                    : "Belum ada riwayat Peserta Magang"}
                </Text>
              </Flex>
            </Box>
          )}
        </Card>
      </Box>
    </div>
  );
}
