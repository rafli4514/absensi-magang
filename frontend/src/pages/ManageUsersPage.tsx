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
  Badge,
} from "@radix-ui/themes/components/index";
import {
  Pencil2Icon,
  TrashIcon,
  MixerHorizontalIcon,
  PlusIcon,
  CheckIcon,
  Cross2Icon,
} from "@radix-ui/react-icons";
import userService, { type CreateUserRequest, type UpdateUserRequest } from "../services/userService";
import type { User } from "../types";
import { roleMapping, getDisplayRole } from "../lib/enums";
import authService from "../services/authService";

const RoleBadge = ({ role }: { role: User["role"] }) => {
  const roleConfig = {
    ADMIN: { color: "bg-purple-100 text-purple-800", label: "Admin" },
    USER: { color: "bg-blue-100 text-blue-800", label: "User" },
    PEMBIMBING_MAGANG: { color: "bg-green-100 text-green-800", label: "Pembimbing Magang" },
  };

  const config = roleConfig[role] || {
    color: "bg-gray-100 text-gray-800",
    label: role,
  };

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${config.color}`}
    >
      {config.label}
    </span>
  );
};

const StatusBadge = ({ isActive }: { isActive: boolean }) => {
  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
        isActive
          ? "bg-success-100 text-success-800"
          : "bg-gray-100 text-gray-800"
      }`}
    >
      {isActive ? "Aktif" : "Tidak Aktif"}
    </span>
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
  const [currentEditingId, setCurrentEditingId] = useState<string | null>(null);

  // Form states for create/edit
  const [formData, setFormData] = useState<CreateUserRequest>({
    username: "",
    password: "",
    role: "USER",
    isActive: true,
  });

  const [updateFormData, setUpdateFormData] = useState<UpdateUserRequest>({});

  // Fetch data on component mount
  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await userService.getUsers({ limit: 1000 }); // Get all users
      if (response.success && response.data) {
        // Handle paginated response
        const usersList = Array.isArray(response.data) ? response.data : response.data.data || [];
        setUsers(usersList);
      } else {
        setError(response.message || "Failed to fetch users");
      }
    } catch (error: unknown) {
      console.error("Fetch users error:", error);
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
        setFormData({
          username: "",
          password: "",
          role: "USER",
          isActive: true,
        });
        setError(null);
      } else {
        setError(response.message || "Failed to create user");
      }
    } catch (error: unknown) {
      console.error("Create user error:", error);
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
        setCurrentEditingId(null);
        setError(null);
      } else {
        setError(response.message || "Failed to update user");
      }
    } catch (error: unknown) {
      console.error("Update user error:", error);
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
      console.error("Delete user error:", error);
      setError("Failed to delete user");
    }
  };

  const handleToggleStatus = async (id: string) => {
    try {
      const response = await userService.toggleUserStatus(id);
      if (response.success) {
        await fetchUsers();
        setError(null);
      } else {
        setError(response.message || "Failed to toggle user status");
      }
    } catch (error: unknown) {
      console.error("Toggle status error:", error);
      setError("Failed to toggle user status");
    }
  };

  const initializeUpdateForm = (user: User) => {
    setCurrentEditingId(user.id);
    setUpdateFormData({
      username: user.username,
      role: user.role,
      isActive: user.isActive,
    });
  };

  const filteredUsers = users.filter((user) => {
    const matchesSearch =
      user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.id.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRole = roleFilter === "Semua" || user.role === roleFilter;

    return matchesSearch && matchesRole;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading users...</p>
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
            Manajemen User
          </h1>
          <p className="text-gray-600">Kelola data user (Admin, User, Pembimbing Magang)</p>
        </div>
        <Dialog.Root>
          <Dialog.Trigger>
            <Button>
              <PlusIcon width="16" height="16" />
              Tambah User
            </Button>
          </Dialog.Trigger>

          <Dialog.Content maxWidth="600px">
            <Dialog.Title>Tambah User Baru</Dialog.Title>
            <Dialog.Description size="2" mb="4">
              Buat user baru dengan role yang sesuai
            </Dialog.Description>

            <Flex direction="column" gap="4">
              <div>
                <label className="block mb-2 font-semibold text-gray-700">
                  Username
                </label>
                <TextField.Root
                  placeholder="Masukkan username"
                  value={formData.username}
                  onChange={(e) =>
                    setFormData({ ...formData, username: e.target.value })
                  }
                  className="w-full"
                />
              </div>

              <div>
                <label className="block mb-2 font-semibold text-gray-700">
                  Password
                </label>
                <TextField.Root
                  type="password"
                  placeholder="Masukkan password"
                  value={formData.password}
                  onChange={(e) =>
                    setFormData({ ...formData, password: e.target.value })
                  }
                  className="w-full"
                />
              </div>

              <div>
                <label className="block mb-2 font-semibold text-gray-700">
                  Role
                </label>
                <Select.Root
                  size="2"
                  value={formData.role}
                  onValueChange={(value) =>
                    setFormData({
                      ...formData,
                      role: value as "ADMIN" | "USER" | "PEMBIMBING_MAGANG",
                    })
                  }
                >
                  <Select.Trigger className="w-full" />
                  <Select.Content>
                    <Select.Item value="USER">User</Select.Item>
                    <Select.Item value="ADMIN">Admin</Select.Item>
                    <Select.Item value="PEMBIMBING_MAGANG">Pembimbing Magang</Select.Item>
                  </Select.Content>
                </Select.Root>
              </div>

              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="isActive"
                  checked={formData.isActive}
                  onChange={(e) =>
                    setFormData({ ...formData, isActive: e.target.checked })
                  }
                  className="w-4 h-4"
                />
                <label htmlFor="isActive" className="font-semibold text-gray-700">
                  Aktif
                </label>
              </div>
            </Flex>

            {/* Action Buttons */}
            <Flex gap="3" mt="6" justify="end">
              <Dialog.Close>
                <Button variant="soft" color="gray">
                  Batal
                </Button>
              </Dialog.Close>
              <Dialog.Close>
                <Button
                  onClick={async () => {
                    await handleCreate();
                    // Dialog will close automatically via Dialog.Close
                  }}
                  disabled={isCreating}
                >
                  {isCreating ? "Menyimpan..." : "Simpan"}
                </Button>
              </Dialog.Close>
            </Flex>
          </Dialog.Content>
        </Dialog.Root>
      </div>

      {/* Filters */}
      <Box className="bg-white p-4 shadow-md rounded-2xl">
        <Flex direction="column" gap="4">
          <Flex align="center" gap="2">
            <MixerHorizontalIcon width="18" height="18" />
            <h3 className="text-lg font-semibold text-gray-900">
              Filter Users
            </h3>
          </Flex>
          <Flex gap="4" wrap="wrap">
            <Flex className="flex items-center w-full relative">
              <TextField.Root
                color="indigo"
                placeholder="Cari User…"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full"
              />
            </Flex>
            <div className="flex items-center">
              <Select.Root
                size="2"
                defaultValue="Semua"
                value={roleFilter}
                onValueChange={(value) => setRoleFilter(value)}
              >
                <Select.Trigger color="indigo" radius="large" />
                <Select.Content color="indigo">
                  <Select.Item value="Semua">Semua Role</Select.Item>
                  <Select.Item value="ADMIN">Admin</Select.Item>
                  <Select.Item value="USER">User</Select.Item>
                  <Select.Item value="PEMBIMBING_MAGANG">Pembimbing Magang</Select.Item>
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
                <Table.ColumnHeaderCell>Username</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Role</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Status</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Tanggal Dibuat</Table.ColumnHeaderCell>
                <Table.ColumnHeaderCell>Aksi</Table.ColumnHeaderCell>
              </Table.Row>
            </Table.Header>

            <Table.Body>
              {filteredUsers.map((user) => (
                <Table.Row key={user.id} className="hover:bg-gray-50">
                  <Table.Cell>
                    <div className="text-sm font-medium text-gray-900">
                      {user.username}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <RoleBadge role={user.role} />
                  </Table.Cell>
                  <Table.Cell>
                    <StatusBadge isActive={user.isActive} />
                  </Table.Cell>
                  <Table.Cell>
                    <div className="text-sm text-gray-500">
                      {new Date(user.createdAt).toLocaleDateString("id-ID")}
                    </div>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex align="center" gap="2">
                      {/* Edit User */}
                      <Dialog.Root>
                        <Dialog.Trigger>
                          <IconButton
                            color="blue"
                            variant="outline"
                            onClick={() => initializeUpdateForm(user)}
                          >
                            <Pencil2Icon width="18" height="18" />
                          </IconButton>
                        </Dialog.Trigger>
                        <Dialog.Content maxWidth="600px">
                          <Dialog.Title>Edit User</Dialog.Title>
                          <Dialog.Description size="2" mb="4">
                            Edit data user
                          </Dialog.Description>

                          <Flex direction="column" gap="4">
                            <div>
                              <label className="block mb-2 font-semibold text-gray-700">
                                Username
                              </label>
                              <TextField.Root
                                placeholder="Masukkan username"
                                value={updateFormData.username || ""}
                                onChange={(e) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    username: e.target.value,
                                  })
                                }
                                className="w-full"
                              />
                            </div>

                            <div>
                              <label className="block mb-2 font-semibold text-gray-700">
                                Password Baru (opsional)
                              </label>
                              <TextField.Root
                                type="password"
                                placeholder="Kosongkan jika tidak ingin mengubah password"
                                value={updateFormData.password || ""}
                                onChange={(e) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    password: e.target.value,
                                  })
                                }
                                className="w-full"
                              />
                            </div>

                            <div>
                              <label className="block mb-2 font-semibold text-gray-700">
                                Role
                              </label>
                              <Select.Root
                                size="2"
                                value={updateFormData.role || user.role}
                                onValueChange={(value) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    role: value as "ADMIN" | "USER" | "PEMBIMBING_MAGANG",
                                  })
                                }
                              >
                                <Select.Trigger className="w-full" />
                                <Select.Content>
                                  <Select.Item value="USER">User</Select.Item>
                                  <Select.Item value="ADMIN">Admin</Select.Item>
                                  <Select.Item value="PEMBIMBING_MAGANG">Pembimbing Magang</Select.Item>
                                </Select.Content>
                              </Select.Root>
                            </div>

                            <div className="flex items-center gap-2">
                              <input
                                type="checkbox"
                                id="updateIsActive"
                                checked={updateFormData.isActive ?? user.isActive}
                                onChange={(e) =>
                                  setUpdateFormData({
                                    ...updateFormData,
                                    isActive: e.target.checked,
                                  })
                                }
                                className="w-4 h-4"
                              />
                              <label htmlFor="updateIsActive" className="font-semibold text-gray-700">
                                Aktif
                              </label>
                            </div>
                          </Flex>

                          <Flex gap="3" mt="6" justify="end">
                            <Dialog.Close>
                              <Button variant="soft" color="gray">
                                Batal
                              </Button>
                            </Dialog.Close>
                            <Dialog.Close>
                              <Button
                                onClick={() => handleUpdate(user.id)}
                                disabled={isUpdating === user.id}
                              >
                                {isUpdating === user.id ? "Menyimpan..." : "Simpan"}
                              </Button>
                            </Dialog.Close>
                          </Flex>
                        </Dialog.Content>
                      </Dialog.Root>

                      {/* Toggle Status */}
                      <IconButton
                        color={user.isActive ? "orange" : "green"}
                        variant="outline"
                        onClick={() => handleToggleStatus(user.id)}
                        title={user.isActive ? "Nonaktifkan" : "Aktifkan"}
                      >
                        {user.isActive ? (
                          <Cross2Icon width="18" height="18" />
                        ) : (
                          <CheckIcon width="18" height="18" />
                        )}
                      </IconButton>

                      {/* Delete User */}
                      <AlertDialog.Root>
                        <AlertDialog.Trigger>
                          <IconButton color="red" variant="outline">
                            <TrashIcon width="18" height="18" />
                          </IconButton>
                        </AlertDialog.Trigger>
                        <AlertDialog.Content>
                          <AlertDialog.Title>Hapus User</AlertDialog.Title>
                          <AlertDialog.Description>
                            Apakah Anda yakin ingin menghapus user{" "}
                            <strong>{user.username}</strong>?
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
                                onClick={() => handleDelete(user.id)}
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
          {filteredUsers.length === 0 && (
            <Box className="text-center py-12">
              <Text size="3" color="gray" weight="medium">
                Tidak ada data user yang ditemukan
              </Text>
            </Box>
          )}
        </Card>
      </Box>
    </div>
  );
}

