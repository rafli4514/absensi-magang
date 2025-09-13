import { useState } from "react";
import {
  Button,
  Card,
  Flex,
  Avatar,
  TextField,
  Text,
  Badge,
  Separator,
} from "@radix-ui/themes";
import {
  User,
  Lock,
  Camera,
  Save,
  Shield,
  Calendar,
} from "lucide-react";

export default function ProfilPage() {
  // Profile data
  const [profileData, setProfileData] = useState({
    name: 'Admin System',
    email: 'admin@company.com',
    role: 'Super Admin',
    phone: '+62 812-3456-7890',
    department: 'IT Department',
    joinDate: '2023-01-15',
    avatar: ''
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

  const handleProfileUpdate = () => {
    // Simulate profile update
    setIsEditingProfile(false);
    alert('Profil berhasil diperbarui!');
  };

  const handlePasswordChange = () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      alert('Password baru dan konfirmasi password tidak cocok!');
      return;
    }

    if (passwordData.newPassword.length < 8) {
      alert('Password minimal 8 karakter!');
      return;
    }

    // Simulate password change
    setPasswordData({
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    });
    setIsChangingPassword(false);
    alert('Password berhasil diubah!');
  };

  const handleAvatarChange = () => {
    // Simulate avatar upload
    alert('Fitur upload avatar akan tersedia. Silakan pilih file gambar.');
  };

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
      </div>

      <div>
        {/* Profile Information */}
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <Flex direction="column" gap="4" className="p-6">
              <Flex align="center" gap="2">
                <User className="h-5 w-5" />
                <h3 className="text-lg font-semibold text-gray-900">
                  Informasi Profil
                </h3>
                <Text size="2" color="gray">
                  Informasi dasar akun pengguna
                </Text>
              </Flex>

              <div className="space-y-6">
              {/* Avatar Section */}
              <div className="flex items-center gap-6">
                <Avatar size="8" src={profileData.avatar} fallback={profileData.name.split(' ').map(n => n[0]).join('')} />
                <div>
                  <h3 className="text-xl font-semibold text-gray-900">{profileData.name}</h3>
                  <p className="text-sm text-gray-600">{profileData.email}</p>
                  <div className="flex gap-2 mt-2">
                    <Badge variant="soft" className="inline-flex items-center">
                      <Shield className="h-3 w-3 mr-1" />
                      {profileData.role}
                    </Badge>
                  </div>
                  <Button variant="outline" size="2" onClick={handleAvatarChange} className="mt-2">
                    <Camera className="h-4 w-4 mr-2" />
                    Ganti Foto
                  </Button>
                </div>
              </div>

              <Separator />

              {/* Profile Form */}
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <h4 className="text-lg font-semibold text-gray-900">Detail Profil</h4>
                  <Button
                    variant="outline"
                    size="2"
                    onClick={() => setIsEditingProfile(!isEditingProfile)}
                  >
                    {isEditingProfile ? 'Batal' : 'Edit Profil'}
                  </Button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Nama Lengkap</label>
                    <TextField.Root
                      value={profileData.name}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProfileData({...profileData, name: e.target.value})}
                      disabled={!isEditingProfile}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Email</label>
                    <TextField.Root
                      type="email"
                      value={profileData.email}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProfileData({...profileData, email: e.target.value})}
                      disabled={!isEditingProfile}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Nomor Telepon</label>
                    <TextField.Root
                      value={profileData.phone}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProfileData({...profileData, phone: e.target.value})}
                      disabled={!isEditingProfile}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">Departemen</label>
                    <TextField.Root
                      value={profileData.department}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => setProfileData({...profileData, department: e.target.value})}
                      disabled={!isEditingProfile}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="block text-sm font-medium text-gray-700">Tanggal Bergabung</label>
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Calendar className="h-4 w-4" />
                    {new Date(profileData.joinDate).toLocaleDateString('id-ID', {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}
                  </div>
                </div>

                {isEditingProfile && (
                  <div className="flex justify-end">
                    <Button onClick={handleProfileUpdate}>
                      <Save className="h-4 w-4 mr-2" />
                      Simpan Perubahan
                    </Button>
                  </div>
                )}
              </div>
              </div>
            </Flex>
          </Card>

          {/* Password Change */}
          <Card>
            <Flex direction="column" gap="4" className="p-6">
              <Flex align="center" gap="2">
                <Lock className="h-5 w-5" />
                <h3 className="text-lg font-semibold text-gray-900">
                  Keamanan Akun
                </h3>
                <Text size="2" color="gray">
                  Ubah password dan kelola keamanan akun
                </Text>
              </Flex>

              <div className="space-y-6">
                <div className="flex justify-between items-center">
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900">Password</h4>
                    <p className="text-sm text-gray-600">
                      Terakhir diubah 30 hari yang lalu
                    </p>
                  </div>
                  <Button
                    variant="outline"
                    size="2"
                    onClick={() => setIsChangingPassword(!isChangingPassword)}
                  >
                    {isChangingPassword ? 'Batal' : 'Ubah Password'}
                  </Button>
                </div>

                {isChangingPassword && (
                  <div className="space-y-4 pt-4 border-t border-gray-200">
                    <div className="space-y-2">
                      <label className="block text-sm font-medium text-gray-700">Password Saat Ini</label>
                      <TextField.Root
                        type="password"
                        value={passwordData.currentPassword}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPasswordData({...passwordData, currentPassword: e.target.value})}
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="block text-sm font-medium text-gray-700">Password Baru</label>
                      <TextField.Root
                        type="password"
                        value={passwordData.newPassword}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPasswordData({...passwordData, newPassword: e.target.value})}
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="block text-sm font-medium text-gray-700">Konfirmasi Password Baru</label>
                      <TextField.Root
                        type="password"
                        value={passwordData.confirmPassword}
                        onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPasswordData({...passwordData, confirmPassword: e.target.value})}
                      />
                    </div>
                    <div className="flex justify-end">
                      <Button onClick={handlePasswordChange}>
                        Ubah Password
                      </Button>
                    </div>
                  </div>
                )}
              </div>
            </Flex>
          </Card>
        </div>
      </div>
    </div>
  );
}