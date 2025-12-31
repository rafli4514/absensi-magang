import { useState, useEffect } from "react";
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
  Switch,
  Badge,
  Grid,
} from "@radix-ui/themes";
import {
  Pencil2Icon,
  TrashIcon,
  MixerHorizontalIcon,
  PlusIcon,
  PersonIcon,
  LockClosedIcon,
} from "@radix-ui/react-icons";
import userService, { type CreateUserRequest, type UpdateUserRequest } from "../services/userService";
import type { User } from "../types";

// --- OPSI BIDANG / DIVISI ---
const BIDANG_OPSI = [
  "Bidang Pemasaran & Penjualan",
  "Retail SBU",
  "Pembangunan & Aktivasi",
  "Operasi Pemeliharaan & Aset",
];

const RoleBadge = ({ role }: { role: User["role"] }) => {
  const roleConfig = {
    ADMIN: { color: "purple", label: "Admin" },
    PESERTA_MAGANG: { color: "blue", label: "Peserta" },
    PEMBIMBING_MAGANG: { color: "green", label: "Pembimbing" },
  };

  const config = roleConfig[role] || { color: "gray", label: role };

  return (
    <Badge color={config.color as any} variant="soft">
      {config.label}
    </Badge>
  );
};

const StatusBadge = ({ isActive }: { isActive: boolean }) => {
  return (
    <Badge color={isActive ? "green" : "gray"} variant={isActive ? "surface" : "outline"}>
      {isActive ? "Aktif" : "Nonaktif"}
    </Badge>
  );
};

export default function ManageUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("Semua");
  const [isCreating, setIsCreating] = useState(false);
  const [isUpdating, setIsUpdating] = useState<string | null>(null);

  // State untuk Form Tambah
  const [formData, setFormData] = useState<any>({
    username: "",
    password: "",
    role: "ADMIN",
    isActive: true,
    divisi: "",
  });

  // State untuk Form Edit
  const [updateFormData, setUpdateFormData] = useState<any>({});

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await userService.getUsers({ limit: 1000 });
      if (response.success && response.data) {
        const usersList = Array.isArray(response.data) ? response.data : response.data.data || [];
        setUsers(usersList);
      } else {
        setError(response.message || "Failed to fetch users");
      }
    } catch (error: unknown) {
      setError("Failed to fetch users");
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async () => {
    try {
      setIsCreating(true);
      const response = await userService.createUser(formData);
      if (response.success) {
        await fetchUsers();
        setFormData({ username: "", password: "", role: "ADMIN", isActive: true, divisi: "" });
        setError(null);
      } else {
        setError(response.message || "Failed to create user");
      }
    } catch (error: unknown) {
      setError("Failed to create user");
    } finally {
      setIsCreating(false);
    }
  };

  const handleUpdate = async (id: string) => {
    try {
      setIsUpdating(id);
      const response = await userService.updateUser(id, updateFormData);
      if (response.success) {
        await fetchUsers();
        setUpdateFormData({});
        setError(null);
      } else {
        setError(response.message || "Failed to update user");
      }
    } catch (error: unknown) {
      setError("Failed to update user");
    } finally {
      setIsUpdating(null);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const response = await userService.deleteUser(id);
      if (response.success) {
        await fetchUsers();
        setError(null);
      } else {
        setError(response.message || "Failed to delete user");
      }
    } catch (error: unknown) {
      setError("Failed to delete user");
    }
  };

  const initializeUpdateForm = (user: User) => {
    const userAny = user as any;
    setUpdateFormData({
      username: user.username,
      role: user.role,
      isActive: user.isActive,
      divisi: userAny.divisi || "",
    });
  };

  const filteredUsers = users.filter((user) => {
    const matchesSearch = user.username.toLowerCase().includes(searchTerm.toLowerCase()) || user.id.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRole = roleFilter === "Semua" || user.role === roleFilter;
    return matchesSearch && matchesRole;
  });

  if (loading) return <div className="flex justify-center h-40 items-center"><div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div></div>;

  return (
    <Flex direction="column" gap="4">
      {error && <div className="bg-red-50 text-red-700 px-4 py-2 rounded-md text-sm border border-red-200">{error}</div>}

      <div className="flex justify-between items-end">
        <div>
          <h2 className="text-lg font-bold text-gray-900">User Sistem</h2>
          <p className="text-xs text-gray-500">Kelola akun Admin dan Pembimbing</p>
        </div>
        <Dialog.Root>
          <Dialog.Trigger>
            <Button size="2"><PlusIcon width="16" height="16" /> Tambah User</Button>
          </Dialog.Trigger>

          {/* --- DIALOG TAMBAH USER --- */}
          <Dialog.Content maxWidth="500px">
            <Dialog.Title>Tambah User Baru</Dialog.Title>
            <Dialog.Description size="2" mb="4" color="gray">
              Buat akun akses untuk Admin atau Pembimbing Magang.
            </Dialog.Description>

            <Flex direction="column" gap="4">
              <Box>
                <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Username</Text>
                <TextField.Root
                  placeholder="Contoh: admin_utama"
                  value={formData.username}
                  onChange={e => setFormData({...formData, username: e.target.value})}
                >
                  <TextField.Slot><PersonIcon height="16" width="16" /></TextField.Slot>
                </TextField.Root>
              </Box>

              <Box>
                <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Password</Text>
                <TextField.Root
                  type="password"
                  placeholder="••••••••"
                  value={formData.password}
                  onChange={e => setFormData({...formData, password: e.target.value})}
                >
                  <TextField.Slot><LockClosedIcon height="16" width="16" /></TextField.Slot>
                </TextField.Root>
              </Box>

              <Grid columns="2" gap="4">
                <Box>
                  <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Role Akses</Text>
                  <Select.Root value={formData.role} onValueChange={v => setFormData({...formData, role: v})}>
                    <Select.Trigger className="w-full" placeholder="Pilih Role" />
                    <Select.Content>
                      <Select.Item value="ADMIN">Admin</Select.Item>
                      <Select.Item value="PEMBIMBING_MAGANG">Pembimbing Magang</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </Box>

                <Box>
                  <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Bidang / Divisi</Text>
                  <Select.Root value={formData.divisi} onValueChange={v => setFormData({...formData, divisi: v})}>
                    <Select.Trigger className="w-full" placeholder="Pilih Bidang" />
                    <Select.Content>
                      {BIDANG_OPSI.map(bidang => (
                        <Select.Item key={bidang} value={bidang}>{bidang}</Select.Item>
                      ))}
                    </Select.Content>
                  </Select.Root>
                </Box>
              </Grid>

              <Flex justify="between" align="center" className="bg-gray-50 p-3 rounded-lg border border-gray-200 mt-1">
                <Box>
                  <Text as="div" size="2" weight="bold" className="text-gray-800">Status Akun</Text>
                  <Text as="div" size="1" color="gray">Aktifkan agar user bisa login</Text>
                </Box>
                <Switch
                  checked={formData.isActive}
                  onCheckedChange={checked => setFormData({...formData, isActive: checked})}
                />
              </Flex>
            </Flex>

            <Flex gap="3" mt="6" justify="end">
              <Dialog.Close>
                <Button variant="soft" color="gray">Batal</Button>
              </Dialog.Close>
              <Button onClick={handleCreate} disabled={isCreating}>
                {isCreating ? "Menyimpan..." : "Simpan"}
              </Button>
            </Flex>
          </Dialog.Content>
        </Dialog.Root>
      </div>

      {/* FILTER SEARCH & ROLE */}
      <Card className="shadow-sm">
        <Box p="3">
          <Flex direction="column" gap="3">
            <Flex gap="3" wrap="wrap" align="center" justify="between">
              <div className="flex-1 min-w-[200px]">
                <TextField.Root size="2" color="indigo" placeholder="Cari username..." value={searchTerm} onChange={e => setSearchTerm(e.target.value)} className="w-full" radius="large">
                  <TextField.Slot><MixerHorizontalIcon height="14" width="14" /></TextField.Slot>
                </TextField.Root>
              </div>
              <Select.Root size="2" defaultValue="Semua" value={roleFilter} onValueChange={setRoleFilter}>
                <Select.Trigger color="indigo" radius="large" className="min-w-[120px]" placeholder="Role" />
                <Select.Content color="indigo">
                  <Select.Item value="Semua">Semua</Select.Item>
                  <Select.Item value="ADMIN">Admin</Select.Item>
                  <Select.Item value="PEMBIMBING_MAGANG">Pembimbing</Select.Item>
                  <Select.Item value="PESERTA_MAGANG">Peserta</Select.Item>
                </Select.Content>
              </Select.Root>
            </Flex>
          </Flex>
        </Box>
      </Card>

      {/* TABEL USER */}
      <Card className="shadow-sm overflow-hidden">
        <Flex direction="row" justify="between" align="center" className="border-b border-gray-100 bg-gray-50/50" p="3">
          <Flex align="center" gap="2">
            <PersonIcon width="16" height="16" className="text-gray-700"/>
            <Text weight="bold" size="2" className="text-gray-900">Daftar Akun</Text>
          </Flex>
          <Text size="1" color="gray">{filteredUsers.length} akun</Text>
        </Flex>

        <Table.Root variant="surface" size="1">
          <Table.Header>
            <Table.Row className="bg-gray-50/80">
              <Table.ColumnHeaderCell className="p-3">Username</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Role</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Bidang</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Status</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3">Dibuat</Table.ColumnHeaderCell>
              <Table.ColumnHeaderCell className="p-3" align="center">Aksi</Table.ColumnHeaderCell>
            </Table.Row>
          </Table.Header>

          <Table.Body>
            {filteredUsers.map((user) => (
              <Table.Row key={user.id} className="hover:bg-blue-50/30 transition-colors">
                <Table.Cell className="p-3"><Text size="2" weight="medium">{user.username}</Text></Table.Cell>
                <Table.Cell className="p-3"><RoleBadge role={user.role} /></Table.Cell>
                <Table.Cell className="p-3"><Text size="1" color="gray">{(user as any).divisi || "-"}</Text></Table.Cell>
                <Table.Cell className="p-3"><StatusBadge isActive={user.isActive} /></Table.Cell>
                <Table.Cell className="p-3"><Text size="1" color="gray">{new Date(user.createdAt).toLocaleDateString("id-ID")}</Text></Table.Cell>
                <Table.Cell className="p-3" align="center">
                  <Flex align="center" justify="center" gap="2">

                    {/* --- DIALOG EDIT USER --- */}
                    <Dialog.Root>
                      <Dialog.Trigger>
                        <IconButton size="1" color="blue" variant="outline" onClick={() => initializeUpdateForm(user)}><Pencil2Icon width="14" height="14" /></IconButton>
                      </Dialog.Trigger>
                      <Dialog.Content maxWidth="500px">
                        <Dialog.Title>Edit User</Dialog.Title>

                        <Flex direction="column" gap="4" mt="2">
                          <Box>
                            <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Username</Text>
                            <TextField.Root value={updateFormData.username} onChange={e => setUpdateFormData({...updateFormData, username: e.target.value})} placeholder="Username" />
                          </Box>

                          <Box>
                            <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Password</Text>
                            <TextField.Root type="password" value={updateFormData.password} onChange={e => setUpdateFormData({...updateFormData, password: e.target.value})} placeholder="Password Baru (Kosongkan jika tetap)" />
                          </Box>

                          <Grid columns="2" gap="4">
                            <Box>
                              <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Role</Text>
                              <Select.Root value={updateFormData.role} onValueChange={v => setUpdateFormData({...updateFormData, role: v})}>
                                <Select.Trigger className="w-full" />
                                <Select.Content>
                                  <Select.Item value="ADMIN">Admin</Select.Item>
                                  <Select.Item value="PEMBIMBING_MAGANG">Pembimbing Magang</Select.Item>
                                  {user.role === 'PESERTA_MAGANG' && <Select.Item value="PESERTA_MAGANG">Peserta Magang</Select.Item>}
                                </Select.Content>
                              </Select.Root>
                            </Box>

                            <Box>
                              <Text as="div" size="2" weight="bold" mb="1" className="text-gray-700">Bidang / Divisi</Text>
                              <Select.Root value={updateFormData.divisi} onValueChange={v => setUpdateFormData({...updateFormData, divisi: v})}>
                                <Select.Trigger className="w-full" placeholder="Pilih Bidang" />
                                <Select.Content>
                                  {BIDANG_OPSI.map(bidang => (
                                    <Select.Item key={bidang} value={bidang}>{bidang}</Select.Item>
                                  ))}
                                </Select.Content>
                              </Select.Root>
                            </Box>
                          </Grid>

                          <Flex justify="between" align="center" className="bg-gray-50 p-3 rounded-lg border border-gray-200 mt-1">
                            <Box>
                              <Text as="div" size="2" weight="bold" className="text-gray-800">Status Akun</Text>
                              <Text as="div" size="1" color="gray">Izin login user</Text>
                            </Box>
                            <Switch
                              checked={updateFormData.isActive}
                              onCheckedChange={checked => setUpdateFormData({...updateFormData, isActive: checked})}
                            />
                          </Flex>
                        </Flex>

                        <Flex gap="3" mt="6" justify="end">
                          <Dialog.Close><Button variant="soft" color="gray">Batal</Button></Dialog.Close>
                          <Button onClick={() => handleUpdate(user.id)} disabled={isUpdating === user.id}>Simpan Perubahan</Button>
                        </Flex>
                      </Dialog.Content>
                    </Dialog.Root>

                    <AlertDialog.Root>
                      <AlertDialog.Trigger>
                        <IconButton size="1" color="red" variant="outline"><TrashIcon width="14" height="14" /></IconButton>
                      </AlertDialog.Trigger>
                      <AlertDialog.Content maxWidth="450px">
                        <AlertDialog.Title>Hapus User</AlertDialog.Title>
                        <AlertDialog.Description>Yakin hapus akun <strong>{user.username}</strong>?</AlertDialog.Description>
                        <Flex gap="3" mt="4" justify="end">
                          <AlertDialog.Cancel><Button variant="soft" color="gray">Batal</Button></AlertDialog.Cancel>
                          <AlertDialog.Action><Button variant="solid" color="red" onClick={() => handleDelete(user.id)}>Hapus</Button></AlertDialog.Action>
                        </Flex>
                      </AlertDialog.Content>
                    </AlertDialog.Root>
                  </Flex>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table.Body>
        </Table.Root>
        {filteredUsers.length === 0 && <Box className="text-center py-10"><Text size="2" color="gray">Tidak ada data</Text></Box>}
      </Card>
    </Flex>
  );
}