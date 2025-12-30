import { useState, useEffect } from "react";
import {
  Button,
  Card,
  Flex,
  TextField,
  Text,
  Badge,
  Separator,
  AlertDialog,
  Spinner,
  Box,
} from "@radix-ui/themes";
import {
  User,
  Lock,
  Save,
  Shield,
  AlertTriangle,
  CheckCircle,
  RefreshCw,
  Trash2,
  Pencil,
} from "lucide-react";
import AvatarUpload from "../components/AvatarUpload";
import profilService from "../services/profilService";
import type { User as UserType } from "../types";

export default function ProfilPage() {
  // Profile data
  const [profileData, setProfileData] = useState<UserType | null>(null);
  const [originalProfileData, setOriginalProfileData] = useState<UserType | null>(null);

  // Form data
  const [formData, setFormData] = useState({
    username: '',
  });

  // Password change
  const [passwordData, setPasswordData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });

  // Form states
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false);

  // Error and success states
  const [errors, setErrors] = useState<{ [key: string]: string }>({});
  const [successMessage, setSuccessMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  // Delete account dialog
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);

  // Load profile data on component mount
  useEffect(() => {
    loadProfile();
  }, []);

  // Load profile data
  const loadProfile = async () => {
    try {
      setIsLoading(true);
      setErrorMessage('');

      const response = await profilService.getProfile();
      if (response.success && response.data) {
        setProfileData(response.data);
        setOriginalProfileData(response.data);
        setFormData({
          username: response.data.username || '',
        });
      } else {
        throw new Error(response.message || 'Failed to load profile');
      }
    } catch (error: any) {
      setErrorMessage(error.message || 'Gagal memuat profil');
      console.error('Load profile error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Handle profile update
  const handleProfileUpdate = async () => {
    try {
      setIsSaving(true);
      setErrors({});
      setErrorMessage('');
      setSuccessMessage('');

      // Validate form data
      const newErrors: { [key: string]: string } = {};

      if (!formData.username.trim()) {
        newErrors.username = 'Username tidak boleh kosong';
      } else {
        const usernameValidation = profilService.validateUsername(formData.username);
        if (!usernameValidation.isValid) {
          newErrors.username = usernameValidation.message;
        }
      }


      if (Object.keys(newErrors).length > 0) {
        setErrors(newErrors);
        return;
      }

      // Update profile
      const response = await profilService.updateProfile({
        username: formData.username,
      });

      if (response.success && response.data) {
        setProfileData(response.data);
        setOriginalProfileData(response.data);
        setIsEditingProfile(false);
        setSuccessMessage('Profil berhasil diperbarui!');

        // Clear success message after 3 seconds
        setTimeout(() => setSuccessMessage(''), 3000);
      } else {
        throw new Error(response.message || 'Failed to update profile');
      }
    } catch (error: any) {
      setErrorMessage(error.message || 'Gagal memperbarui profil');
      console.error('Update profile error:', error);
    } finally {
      setIsSaving(false);
    }
  };

  // Cancel profile editing
  const handleCancelEdit = () => {
    if (originalProfileData) {
      setFormData({
        username: originalProfileData.username || '',
      });
    }
    setIsEditingProfile(false);
    setErrors({});
    setErrorMessage('');
  };

  // Handle password change
  const handlePasswordChange = async () => {
    try {
      setIsSaving(true);
      setErrors({});
      setErrorMessage('');
      setSuccessMessage('');

      // Validate password data
      const newErrors: { [key: string]: string } = {};

      if (!passwordData.currentPassword) {
        newErrors.currentPassword = 'Password saat ini harus diisi';
      }

      if (!passwordData.newPassword) {
        newErrors.newPassword = 'Password baru harus diisi';
      } else {
        const passwordValidation = profilService.validatePassword(passwordData.newPassword);
        if (!passwordValidation.isValid) {
          newErrors.newPassword = passwordValidation.message;
        }
      }

      if (passwordData.newPassword !== passwordData.confirmPassword) {
        newErrors.confirmPassword = 'Konfirmasi password tidak cocok';
      }

      if (Object.keys(newErrors).length > 0) {
        setErrors(newErrors);
        return;
      }

      // Change password
      const response = await profilService.changePassword(
        passwordData.currentPassword,
        passwordData.newPassword
      );

      if (response.success) {
        setPasswordData({
          currentPassword: '',
          newPassword: '',
          confirmPassword: ''
        });
        setIsChangingPassword(false);
        setSuccessMessage('Password berhasil diubah!');

        // Clear success message after 3 seconds
        setTimeout(() => setSuccessMessage(''), 3000);
      } else {
        throw new Error(response.message || 'Failed to change password');
      }
    } catch (error: any) {
      setErrorMessage(error.message || 'Gagal mengubah password');
      console.error('Change password error:', error);
    } finally {
      setIsSaving(false);
    }
  };

  // Cancel password change
  const handleCancelPasswordChange = () => {
    setPasswordData({
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    });
    setIsChangingPassword(false);
    setErrors({});
    setErrorMessage('');
  };

  // Handle avatar upload
  const handleAvatarUpload = async (file: File) => {
    try {
      setIsUploadingAvatar(true);
      setErrorMessage('');
      setSuccessMessage('');

      // Validate file
      if (file.size > 5 * 1024 * 1024) { // 5MB limit
        throw new Error('Ukuran file maksimal 5MB');
      }

      if (!file.type.startsWith('image/')) {
        throw new Error('File harus berupa gambar');
      }

      // Upload avatar
      const response = await profilService.uploadAvatar(file);

      if (response.success && response.data) {
        // Update profile data with new avatar URL
        if (profileData) {
          const updatedProfile = { ...profileData, avatar: response.data.avatarUrl };
          setProfileData(updatedProfile);
          setOriginalProfileData(updatedProfile);
        }
        setSuccessMessage('Avatar berhasil diupload!');

        // Clear success message after 3 seconds
        setTimeout(() => setSuccessMessage(''), 3000);
      } else {
        throw new Error(response.message || 'Failed to upload avatar');
      }
    } catch (error: any) {
      setErrorMessage(error.message || 'Gagal mengupload avatar');
      console.error('Avatar upload error:', error);
    } finally {
      setIsUploadingAvatar(false);
    }
  };

  // Handle avatar remove
  const handleAvatarRemove = async () => {
    try {
      setIsUploadingAvatar(true);
      setErrorMessage('');
      setSuccessMessage('');

      const response = await profilService.removeAvatar();

      if (response.success) {
        // Update profile data to remove avatar
        if (profileData) {
          const updatedProfile = { ...profileData, avatar: null };
          setProfileData(updatedProfile);
          setOriginalProfileData(updatedProfile);
        }
        setSuccessMessage('Avatar berhasil dihapus!');

        // Clear success message after 3 seconds
        setTimeout(() => setSuccessMessage(''), 3000);
      } else {
        throw new Error(response.message || 'Failed to remove avatar');
      }
    } catch (error: any) {
      setErrorMessage(error.message || 'Gagal menghapus avatar');
      console.error('Avatar remove error:', error);
    } finally {
      setIsUploadingAvatar(false);
    }
  };

  // Handle account deletion (placeholder - would need backend implementation)
  const handleDeleteAccount = async () => {
    // This would require backend implementation
    alert('Fitur hapus akun belum diimplementasikan di backend');
    setShowDeleteDialog(false);
  };

  // Clear messages
  const clearMessages = () => {
    setErrorMessage('');
    setSuccessMessage('');
  };

  // Show loading spinner
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <Spinner size="3" className="mb-4" />
          <p className="text-gray-600">Memuat profil...</p>
        </div>
      </div>
    );
  }

  // Show error if failed to load
  if (!profileData) {
    return (
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Profil Pengguna</h1>
            <p className="text-gray-600">Kelola informasi akun dan pengaturan keamanan</p>
          </div>
        </div>

        <Card>
          <div className="p-6 text-center">
            <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Gagal Memuat Profil</h3>
            <p className="text-gray-600 mb-4">{errorMessage || 'Terjadi kesalahan saat memuat profil'}</p>
            <Button onClick={loadProfile} disabled={isLoading}>
              <RefreshCw className="h-4 w-4 mr-2" />
              Coba Lagi
            </Button>
          </div>
        </Card>
      </div>
    );
  }

  return (
      <div className="space-y-6">
        {/* Page header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Profil Pengguna</h1>
            <p className="text-gray-600">
              Kelola informasi akun dan pengaturan keamanan
            </p>
          </div>
          <Button
            variant="outline"
            color="red"
            onClick={() => setShowDeleteDialog(true)}
          >
            <Trash2 className="h-4 w-4 mr-2" />
            Hapus Akun
          </Button>
        </div>

        {/* Success Message */}
        {successMessage && (
          <Card>
            <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-center">
                <CheckCircle className="h-5 w-5 text-green-600 mr-2" />
                <p className="text-green-800 font-medium">{successMessage}</p>
              </div>
            </div>
          </Card>
        )}

        {/* Error Message */}
        {errorMessage && (
          <Card>
            <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <AlertTriangle className="h-5 w-5 text-red-600 mr-2" />
                  <p className="text-red-800 font-medium">{errorMessage}</p>
                </div>
                <Button variant="ghost" size="1" onClick={clearMessages}>
                  ×
                </Button>
              </div>
            </div>
          </Card>
        )}

      <div className="lg:col-span-2 space-y-6">
        {/* Profile Information Card */}
        <Card>
          <div className="p-6">
            <Flex align="center" gap="2" className="mb-6">
              <User className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Informasi Profil
              </h3>
            </Flex>

            {/* Main Layout: Side by Side on Desktop (md), Stacked on Mobile */}
            <div className="flex flex-col md:flex-row gap-8 items-start">

              {/* LEFT COLUMN: Avatar Section */}
              <div className="flex-shrink-0 flex flex-col items-center md:items-start space-y-2">
                <div className="relative">
                  <AvatarUpload
                    src={profileData.avatar}
                    alt={profileData.username}
                    name={profileData.username}
                    size="xl" // Ensure this size prop renders a large enough avatar (e.g., w-32 h-32)
                    onUpload={handleAvatarUpload}
                    onRemove={handleAvatarRemove}
                  />
                  {isUploadingAvatar && (
                    <div className="absolute inset-0 bg-black bg-opacity-50 rounded-full flex items-center justify-center">
                      <Spinner size="2" className="text-white" />
                    </div>
                  )}
                </div>
                <p className="text-xs text-gray-500 text-center w-full">
                  {isUploadingAvatar ? 'Mengupload...' : ""}
                </p>
              </div>

              {/* RIGHT COLUMN: Information & Form */}
              <div className="flex-grow w-full space-y-6">

                {/* Header: Name, Badges, and Action Buttons */}
                <div className="flex flex-col sm:flex-row justify-between items-start gap-4">
                  <div>
                    <h3 className="text-xl font-bold text-gray-900">{profileData.username}</h3>
                    <div className="flex gap-2 mt-2">
                      <Badge variant="soft" className="inline-flex items-center">
                        <Shield className="h-3 w-3 mr-1" />
                        {profileData.role}
                      </Badge>
                      <Badge
                        variant={profileData.isActive ? "soft" : "outline"}
                        color={profileData.isActive ? "green" : "red"}
                      >
                        {profileData.isActive ? 'Aktif' : 'Nonaktif'}
                      </Badge>
                    </div>
                  </div>

                  {/* Edit/Save Buttons */}
                  <div className="flex gap-2">
                    {isEditingProfile && (
                      <Button
                        variant="outline"
                        size="2"
                        onClick={handleCancelEdit}
                        disabled={isSaving}
                      >
                        Batal
                      </Button>
                    )}
                    <Button
                      variant={isEditingProfile ? "solid" : "outline"}
                      size="2"
                      onClick={() => {
                        if (isEditingProfile) {
                          handleProfileUpdate();
                        } else {
                          setIsEditingProfile(true);
                          clearMessages();
                        }
                      }}
                      disabled={isSaving}
                    >
                      {isSaving ? (
                        <>
                          <Spinner size="1" className="mr-2" />
                          Menyimpan...
                        </>
                      ) : isEditingProfile ? (
                        <>
                          <Save className="h-4 w-4 mr-2" />
                          Simpan
                        </>
                      ) : (
                        <>
                          <Pencil className="h-4 w-4 mr-2" />
                          Edit Profil
                        </>
                      )}
                    </Button>
                  </div>
                </div>

                {/* Form Inputs */}
                <div className="space-y-4">
                  <Box className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Username *</label>
                    <TextField.Root
                      value={formData.username}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                        setFormData({...formData, username: e.target.value});
                        if (errors.username) setErrors({...errors, username: ''});
                      }}
                      disabled={!isEditingProfile}
                      color={errors.username ? "red" : undefined}
                      className="w-full"
                    />
                    {errors.username && (
                      <p className="text-sm text-red-600">{errors.username}</p>
                    )}
                  </Box>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="block text-sm font-medium text-gray-700">Role</label>
                      <TextField.Root
                        value={profileData.role}
                        disabled
                        className="bg-gray-50"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="block text-sm font-medium text-gray-700">Status</label>
                      <TextField.Root
                        value={profileData.isActive ? 'Aktif' : 'Nonaktif'}
                        disabled
                        className="bg-gray-50"
                      />
                    </div>
                  </div>

                  <div className="text-xs text-gray-500 pt-2 border-t border-gray-100">
                    <p>Terakhir diperbarui: {new Date(profileData.updatedAt).toLocaleString('id-ID')}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </Card>

        {/* Password Change Card */}
        <Card>
          <Flex direction="column" gap="4" className="p-6">
            <Flex align="center" gap="2">
              <Lock className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Keamanan Akun
              </h3>
            </Flex>
            <Text size="2" color="gray" className="-mt-2">
              Ubah password dan kelola keamanan akun
            </Text>

            <div className="space-y-6 mt-2">
              <div className="flex justify-between items-center">
                <div>
                  <h4 className="text-base font-semibold text-gray-900">Password</h4>
                  <p className="text-sm text-gray-600">
                    Untuk keamanan, password tidak ditampilkan
                  </p>
                </div>
                <div className="flex gap-2">
                  {isChangingPassword && (
                    <Button
                      variant="outline"
                      size="2"
                      onClick={handleCancelPasswordChange}
                      disabled={isSaving}
                    >
                      Batal
                    </Button>
                  )}
                  <Button
                    variant={isChangingPassword ? "solid" : "outline"}
                    size="2"
                    onClick={() => {
                      if (isChangingPassword) {
                        handlePasswordChange();
                      } else {
                        setIsChangingPassword(true);
                        clearMessages();
                      }
                    }}
                    disabled={isSaving}
                  >
                    {isSaving ? (
                      <>
                        <Spinner size="1" className="mr-2" />
                        Mengubah...
                      </>
                    ) : isChangingPassword ? (
                      <>
                        <Lock className="h-4 w-4 mr-2" />
                        Ubah Password
                      </>
                    ) : (
                      <>
                        <Lock className="h-4 w-4 mr-2" />
                        Ubah Password
                      </>
                    )}
                  </Button>
                </div>
              </div>

              {isChangingPassword && (
                <div className="space-y-4 pt-4 border-t border-gray-200">
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Password Saat Ini *</label>
                    <TextField.Root
                      type="password"
                      value={passwordData.currentPassword}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                        setPasswordData({...passwordData, currentPassword: e.target.value});
                        if (errors.currentPassword) setErrors({...errors, currentPassword: ''});
                      }}
                      color={errors.currentPassword ? "red" : undefined}
                      placeholder="Masukkan password saat ini"
                    />
                    {errors.currentPassword && (
                      <p className="text-sm text-red-600">{errors.currentPassword}</p>
                    )}
                  </div>
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Password Baru *</label>
                    <TextField.Root
                      type="password"
                      value={passwordData.newPassword}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                        setPasswordData({...passwordData, newPassword: e.target.value});
                        if (errors.newPassword) setErrors({...errors, newPassword: ''});
                      }}
                      color={errors.newPassword ? "red" : undefined}
                      placeholder="Masukkan password baru"
                    />
                    {errors.newPassword && (
                      <p className="text-sm text-red-600">{errors.newPassword}</p>
                    )}
                    <p className="text-xs text-gray-500">
                      Password harus minimal 8 karakter, mengandung huruf besar, huruf kecil, dan angka
                    </p>
                  </div>
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Konfirmasi Password Baru *</label>
                    <TextField.Root
                      type="password"
                      value={passwordData.confirmPassword}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                        setPasswordData({...passwordData, confirmPassword: e.target.value});
                        if (errors.confirmPassword) setErrors({...errors, confirmPassword: ''});
                      }}
                      color={errors.confirmPassword ? "red" : undefined}
                      placeholder="Konfirmasi password baru"
                    />
                    {errors.confirmPassword && (
                      <p className="text-sm text-red-600">{errors.confirmPassword}</p>
                    )}
                  </div>
                </div>
              )}
            </div>
          </Flex>
        </Card>

        {/* Delete Account Dialog */}
        <AlertDialog.Root open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
          <AlertDialog.Content>
            <AlertDialog.Title>Hapus Akun</AlertDialog.Title>
            <AlertDialog.Description>
              Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan dan semua data akan hilang permanen.
            </AlertDialog.Description>
            <Flex gap="3" mt="4" justify="end">
              <AlertDialog.Cancel>
                <Button variant="soft" color="gray">
                  Batal
                </Button>
              </AlertDialog.Cancel>
              <AlertDialog.Action>
                <Button variant="solid" color="red" onClick={handleDeleteAccount}>
                  Hapus Akun
                </Button>
              </AlertDialog.Action>
            </Flex>
          </AlertDialog.Content>
        </AlertDialog.Root>
      </div>
    </div>
  );
}