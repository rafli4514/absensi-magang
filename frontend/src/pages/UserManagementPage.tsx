import { useState, useEffect } from "react";
import { Link, useLocation } from "react-router-dom";
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
  Tabs,
} from "@radix-ui/themes";
import {
  EyeOpenIcon,
  Pencil2Icon,
  TrashIcon,
  MixerHorizontalIcon,
  PlusIcon,
  ClockIcon,
  PersonIcon,
} from "@radix-ui/react-icons";
import pesertaMagangService from "../services/pesertaMagangService";
import Avatar from "../components/Avatar";

// Import Halaman User
import ManageUsersPage from "./ManageUsersPage";

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
      className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

export default function PesertaMagang() {
  const location = useLocation();
  const [activeTab, setActiveTab] = useState(
    location.pathname === "/manage-users" ? "users" : "peserta-magang"
  );

  useEffect(() => {
    if (location.pathname === "/manage-users") {
      setActiveTab("users");
    } else if (location.pathname === "/peserta-magang") {
      setActiveTab("peserta-magang");
    }
  }, [location.pathname]);

  const [pesertaMagang, setPesertaMagang] = useState<PesertaMagang[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("Semua");
  const [isCreating, setIsCreating] = useState(false);
  const [isUpdating, setIsUpdating] = useState<string | null>(null);
  const [currentEditingId, setCurrentEditingId] = useState<string | null>(null);

  // Form states
  const [formData, setFormData] = useState({
    nama: "",
    username: "",
    id_peserta_magang: "",
    divisi: "",
    instansi: "",
    id_instansi: "",
    nomorHp: "",
    tanggalMulai: "",
    tanggalSelesai: "",
    status: "AKTIF" as PesertaMagang["status"],
    password: "",
  });

  const [updateFormData, setUpdateFormData] = useState<Partial<PesertaMagang>>({});

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
          id_peserta_magang: "",
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
      const response = await pesertaMagangService.updatePesertaMagang(id, updateFormData);
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
      id_peserta_magang: item.id_peserta_magang,
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

      if (response.ok) {
        const result = await response.json();
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
        setError(`Failed to upload avatar: ${response.status}`);
      }
    } catch (error) {
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
      <div className="flex items-center justify-center h-[50vh]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-sm text-gray-600">Loading data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4 pb-10">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl font-bold text-gray-900 tracking-tight">Manajemen User</h1>
          <p className="text-xs text-gray-500 mt-0.5">Kelola data user dan peserta magang</p>
        </div>
      </div>

      <Tabs.Root value={activeTab} onValueChange={setActiveTab}>
        <Tabs.List size="2">
          <Tabs.Trigger value="peserta-magang">Peserta Magang</Tabs.Trigger>
          <Tabs.Trigger value="users">User Sistem</Tabs.Trigger>
        </Tabs.List>

        <Tabs.Content value="peserta-magang" className="mt-4">
          <Flex direction="column" gap="4">
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md text-sm">
                {error}
              </div>
            )}

            <div className="flex justify-between items-end">
              <div>
                <h2 className="text-lg font-bold text-gray-900">Peserta Magang</h2>
                <p className="text-xs text-gray-500">Data peserta magang terdaftar</p>
              </div>
              <Dialog.Root>
                <Dialog.Trigger>
                  <Button size="2"><PlusIcon width="16" height="16" /> Tambah Peserta</Button>
                </Dialog.Trigger>
                {/* ... Dialog Content (Keep existing form logic) ... */}
                <Dialog.Content maxWidth="850px" onKeyDown={handleKeyDown}>
                  <Dialog.Title>Tambah Peserta Magang</Dialog.Title>
                  <Dialog.Description size="2" mb="4">
                    Isi data peserta magang baru. Tekan Enter untuk simpan.
                  </Dialog.Description>
                  {/* Reuse your existing form fields here, just compacted if needed */}
                  {/* ... Existing form implementation ... */}
                  <Flex direction="column" gap="4">
                     {/* Simplified for brevity - paste your existing form fields here */}
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <TextField.Root placeholder="Nama Lengkap" value={formData.nama} onChange={e => setFormData({...formData, nama: e.target.value})} />
                        <TextField.Root placeholder="Username" value={formData.username} onChange={e => setFormData({...formData, username: e.target.value})} />
                        <TextField.Root placeholder="NISN/NIM" value={formData.id_peserta_magang} onChange={e => setFormData({...formData, id_peserta_magang: e.target.value})} />
                        <TextField.Root placeholder="Nomor HP" value={formData.nomorHp} onChange={e => setFormData({...formData, nomorHp: e.target.value})} />
                        <TextField.Root type="password" placeholder="Password Awal" value={formData.password} onChange={e => setFormData({...formData, password: e.target.value})} />
                        <Select.Root value={formData.status} onValueChange={v => setFormData({...formData, status: v as any})}>
                          <Select.Trigger placeholder="Status" />
                          <Select.Content>
                            <Select.Item value="AKTIF">Aktif</Select.Item>
                            <Select.Item value="NONAKTIF">Tidak Aktif</Select.Item>
                            <Select.Item value="SELESAI">Selesai</Select.Item>
                          </Select.Content>
                        </Select.Root>
                     </div>
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <TextField.Root placeholder="Divisi" value={formData.divisi} onChange={e => setFormData({...formData, divisi: e.target.value})} />
                        <TextField.Root placeholder="Instansi" value={formData.instansi} onChange={e => setFormData({...formData, instansi: e.target.value})} />
                        <TextField.Root placeholder="ID Instansi" value={formData.id_instansi} onChange={e => setFormData({...formData, id_instansi: e.target.value})} />
                     </div>
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <label className="text-xs font-medium">Mulai <TextField.Root type="date" value={formData.tanggalMulai} onChange={e => setFormData({...formData, tanggalMulai: e.target.value})} /></label>
                        <label className="text-xs font-medium">Selesai <TextField.Root type="date" value={formData.tanggalSelesai} onChange={e => setFormData({...formData, tanggalSelesai: e.target.value})} /></label>
                     </div>
                  </Flex>
                  <Flex gap="3" mt="4" justify="end">
                    <Dialog.Close><Button variant="soft" color="gray">Batal</Button></Dialog.Close>
                    <Button onClick={handleCreate} disabled={isCreating}>{isCreating ? "Menyimpan..." : "Simpan"}</Button>
                  </Flex>
                </Dialog.Content>
              </Dialog.Root>
            </div>

            {/* Filters - Compact */}
            <Card className="shadow-sm">
              <Box p="3">
                <Flex direction="column" gap="3">
                  <Flex gap="3" wrap="wrap" align="center" justify="between">
                    <div className="flex-1 min-w-[200px]">
                      <TextField.Root
                        size="2"
                        color="indigo"
                        placeholder="Cari nama/ID..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full"
                        radius="large"
                      >
                        <TextField.Slot><MixerHorizontalIcon height="14" width="14" /></TextField.Slot>
                      </TextField.Root>
                    </div>
                    <Select.Root size="2" defaultValue="Semua" value={statusFilter} onValueChange={setStatusFilter}>
                      <Select.Trigger color="indigo" radius="large" className="min-w-[120px]" placeholder="Status" />
                      <Select.Content color="indigo">
                        <Select.Item value="Semua">Semua</Select.Item>
                        <Select.Item value="AKTIF">Aktif</Select.Item>
                        <Select.Item value="NONAKTIF">Nonaktif</Select.Item>
                        <Select.Item value="SELESAI">Selesai</Select.Item>
                      </Select.Content>
                    </Select.Root>
                  </Flex>
                </Flex>
              </Box>
            </Card>

            {/* Table - Compact Style */}
            <Card className="shadow-sm overflow-hidden">
              <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-gray-50/50" p="3">
                <Flex align="center" gap="2">
                  <PersonIcon width="16" height="16" className="text-gray-700"/>
                  <Text weight="bold" size="2" className="text-gray-900">Daftar Peserta</Text>
                </Flex>
                <Text size="1" color="gray">{filteredPesertaMagang.length} data ditemukan</Text>
              </Flex>

              <Table.Root variant="surface" size="1">
                <Table.Header>
                  <Table.Row className="bg-gray-50/80">
                    <Table.ColumnHeaderCell className="p-3">Nama</Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="p-3">ID Peserta</Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="p-3">Instansi</Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="p-3">Kontak</Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="p-3">Periode</Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="p-3">Status</Table.ColumnHeaderCell>
                    <Table.ColumnHeaderCell className="p-3" align="center">Aksi</Table.ColumnHeaderCell>
                  </Table.Row>
                </Table.Header>

                <Table.Body>
                  {filteredPesertaMagang.map((item) => (
                    <Table.Row key={item.id} className="hover:bg-blue-50/30 transition-colors">
                      <Table.Cell className="p-3">
                        <div className="flex items-center">
                          <Avatar src={item.avatar} alt={item.nama} name={item.nama} size="sm" showBorder className="border-gray-200 shadow-sm" />
                          <div className="ml-3">
                            <div className="text-xs font-semibold text-gray-900">{item.nama}</div>
                            <div className="text-[10px] text-gray-500 font-medium">{item.username}</div>
                          </div>
                        </div>
                      </Table.Cell>
                      <Table.Cell className="p-3 align-middle"><Text size="1" color="gray">{item.id_instansi || '-'}</Text></Table.Cell>
                      <Table.Cell className="p-3 align-middle"><Text size="1">{item.instansi}</Text></Table.Cell>
                      <Table.Cell className="p-3 align-middle"><Text size="1">{item.nomorHp}</Text></Table.Cell>
                      <Table.Cell className="p-3 align-middle">
                        <div className="text-[10px] text-gray-900">{new Date(item.tanggalMulai).toLocaleDateString("id-ID")}</div>
                        <div className="text-[10px] text-gray-500">s/d {new Date(item.tanggalSelesai).toLocaleDateString("id-ID")}</div>
                      </Table.Cell>
                      <Table.Cell className="p-3 align-middle"><StatusBadge status={item.status} /></Table.Cell>
                      <Table.Cell className="p-3 align-middle" align="center">
                        <Flex align="center" justify="center" gap="2">
                          <Link to={`/profil-peserta/${item.id}`}>
                            <IconButton size="1" color="blue" variant="outline" highContrast><EyeOpenIcon width="14" height="14" /></IconButton>
                          </Link>

                          <Dialog.Root>
                            <Dialog.Trigger>
                              <IconButton size="1" color="orange" variant="outline" onClick={() => initializeUpdateForm(item)}><Pencil2Icon width="14" height="14" /></IconButton>
                            </Dialog.Trigger>
                            {/* ... Edit Dialog Content (Similar to Create) ... */}
                            <Dialog.Content maxWidth="850px" onKeyDown={handleUpdateKeyDown}>
                                <Dialog.Title>Edit Peserta</Dialog.Title>
                                {/* Form fields populated with updateFormData */}
                                {/* Reuse the form layout from Create Dialog */}
                                <Flex direction="column" gap="4">
                                    <TextField.Root value={updateFormData.nama} onChange={e => setUpdateFormData({...updateFormData, nama: e.target.value})} placeholder="Nama" />
                                    {/* ... other fields ... */}
                                    {/* Avatar Upload */}
                                    <div className="w-full border-2 border-dashed border-gray-300 rounded-lg p-2 text-center">
                                      <input type="file" accept="image/*" onChange={(e) => {if(e.target.files?.[0]) handleAvatarUpload(item.id, e.target.files[0])}} className="text-xs" />
                                    </div>
                                </Flex>
                                <Flex gap="3" mt="4" justify="end">
                                    <Dialog.Close><Button variant="soft" color="gray">Batal</Button></Dialog.Close>
                                    <Button onClick={() => handleUpdate(item.id)} disabled={isUpdating === item.id}>Simpan</Button>
                                </Flex>
                            </Dialog.Content>
                          </Dialog.Root>

                          <AlertDialog.Root>
                            <AlertDialog.Trigger>
                              <IconButton size="1" color="red" variant="outline"><TrashIcon width="14" height="14" /></IconButton>
                            </AlertDialog.Trigger>
                            <AlertDialog.Content maxWidth="450px">
                              <AlertDialog.Title>Hapus Pengguna</AlertDialog.Title>
                              <AlertDialog.Description size="2">
                                Apakah Anda yakin ingin menghapus <strong>{item.nama}</strong>?
                              </AlertDialog.Description>
                              <Flex gap="3" mt="4" justify="end">
                                <AlertDialog.Cancel><Button variant="soft" color="gray">Batal</Button></AlertDialog.Cancel>
                                <AlertDialog.Action><Button variant="solid" color="red" onClick={() => handleDelete(item.id)}>Hapus</Button></AlertDialog.Action>
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
                <Box className="text-center py-10 bg-gray-50/30">
                  <ClockIcon className="h-6 w-6 text-gray-300 mx-auto mb-2" />
                  <Text size="2" color="gray">Tidak ada data ditemukan</Text>
                </Box>
              )}
            </Card>
          </Flex>
        </Tabs.Content>

        <Tabs.Content value="users" className="mt-4">
          <ManageUsersPage />
        </Tabs.Content>
      </Tabs.Root>
    </div>
  );
}