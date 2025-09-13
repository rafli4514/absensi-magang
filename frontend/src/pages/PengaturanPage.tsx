import { useState } from "react";
import { QrCode, Clock, MapPin, Calendar, Shield } from "lucide-react";
import {
  Box,
  Button,
  Card,
  Flex,
  Select,
  Switch,
  TextField,
} from "@radix-ui/themes";

export default function PengaturanPage() {
  const [qrSettings, setQrSettings] = useState({
    autoGenerate: true,
    validityPeriod: 5, // minutes
    size: "medium",
  });

  const [attendanceSettings, setAttendanceSettings] = useState({
    allowLateCheckIn: true,
    lateThreshold: 15, // minutes
    requireLocation: true,
    allowRemoteCheckIn: false,
  });

  const [scheduleSettings, setScheduleSettings] = useState({
    workStartTime: "08:00",
    workEndTime: "17:00",
    breakStartTime: "12:00",
    breakEndTime: "13:00",
    workDays: ["monday", "tuesday", "wednesday", "thursday", "friday"],
  });

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Pengaturan Absensi</h1>
          <p className="text-gray-600">
            Kelola pengaturan sistem absensi dan kehadiran
          </p>
        </div>
      </div>

      {/* QR Code Settings */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="4">
            <Flex align="center" gap="2">
              <QrCode className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Pengaturan QR Code
              </h3>
            </Flex>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                  <div>
                    <h4 className="text-sm font-medium text-gray-900">
                      Generate QR Otomatis
                    </h4>
                    <p className="text-sm text-gray-600">
                      QR code dihasilkan secara otomatis untuk setiap sesi
                    </p>
                  </div>
                  <Switch
                    checked={qrSettings.autoGenerate}
                    onCheckedChange={(checked) =>
                      setQrSettings({ ...qrSettings, autoGenerate: checked })
                    }
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Ukuran QR Code
                  </label>
                  <Select.Root
                    value={qrSettings.size}
                    onValueChange={(value) =>
                      setQrSettings({ ...qrSettings, size: value })
                    }
                  >
                    <Select.Trigger />
                    <Select.Content>
                      <Select.Item value="small">Kecil</Select.Item>
                      <Select.Item value="medium">Sedang</Select.Item>
                      <Select.Item value="large">Besar</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </div>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Periode Validitas QR (menit)
                  </label>
                  <Select.Root
                    value={qrSettings.validityPeriod.toString()}
                    onValueChange={(value) =>
                      setQrSettings({ ...qrSettings, validityPeriod: parseInt(value) })
                    }
                  >
                    <Select.Trigger />
                    <Select.Content>
                      <Select.Item value="5">5 menit</Select.Item>
                      <Select.Item value="10">10 menit</Select.Item>
                      <Select.Item value="15">15 menit</Select.Item>
                      <Select.Item value="30">30 menit</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </div>
                <div className="flex justify-end">
                  <Button variant="outline">
                    Generate QR Code Baru
                  </Button>
                </div>
              </div>
            </div>
          </Flex>
        </Card>
      </Box>

      {/* Attendance Settings */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="4">
            <Flex align="center" gap="2">
              <Clock className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Pengaturan Absensi
              </h3>
            </Flex>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div>
                  <h4 className="text-sm font-medium text-gray-900">
                    Izinkan Check-in Terlambat
                  </h4>
                  <p className="text-sm text-gray-600">
                    Peserta masih bisa check-in meskipun terlambat
                  </p>
                </div>
                <Switch
                  checked={attendanceSettings.allowLateCheckIn}
                  onCheckedChange={(checked) =>
                    setAttendanceSettings({ ...attendanceSettings, allowLateCheckIn: checked })
                  }
                />
              </div>
              <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div>
                  <h4 className="text-sm font-medium text-gray-900">
                    Wajibkan Lokasi
                  </h4>
                  <p className="text-sm text-gray-600">
                    Check-in memerlukan verifikasi lokasi GPS
                  </p>
                </div>
                <Switch
                  checked={attendanceSettings.requireLocation}
                  onCheckedChange={(checked) =>
                    setAttendanceSettings({ ...attendanceSettings, requireLocation: checked })
                  }
                />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Batas Keterlambatan (menit)
                  </label>
                  <Select.Root
                    value={attendanceSettings.lateThreshold.toString()}
                    onValueChange={(value) =>
                      setAttendanceSettings({ ...attendanceSettings, lateThreshold: parseInt(value) })
                    }
                  >
                    <Select.Trigger />
                    <Select.Content>
                      <Select.Item value="5">5 menit</Select.Item>
                      <Select.Item value="10">10 menit</Select.Item>
                      <Select.Item value="15">15 menit</Select.Item>
                      <Select.Item value="30">30 menit</Select.Item>
                    </Select.Content>
                  </Select.Root>
                </div>
              </div>
            </div>
          </Flex>
        </Card>
      </Box>

      {/* Work Schedule Settings */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="4">
            <Flex align="center" gap="2">
              <Calendar className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Jadwal Kerja
              </h3>
            </Flex>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Jam Masuk
                  </label>
                  <TextField.Root
                    type="time"
                    value={scheduleSettings.workStartTime}
                    onChange={(e) =>
                      setScheduleSettings({ ...scheduleSettings, workStartTime: e.target.value })
                    }
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Jam Istirahat Mulai
                  </label>
                  <TextField.Root
                    type="time"
                    value={scheduleSettings.breakStartTime}
                    onChange={(e) =>
                      setScheduleSettings({ ...scheduleSettings, breakStartTime: e.target.value })
                    }
                  />
                </div>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Jam Pulang
                  </label>
                  <TextField.Root
                    type="time"
                    value={scheduleSettings.workEndTime}
                    onChange={(e) =>
                      setScheduleSettings({ ...scheduleSettings, workEndTime: e.target.value })
                    }
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Jam Istirahat Selesai
                  </label>
                  <TextField.Root
                    type="time"
                    value={scheduleSettings.breakEndTime}
                    onChange={(e) =>
                      setScheduleSettings({ ...scheduleSettings, breakEndTime: e.target.value })
                    }
                  />
                </div>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Hari Kerja
              </label>
              <div className="flex flex-wrap gap-2">
                {[
                  { key: "monday", label: "Senin" },
                  { key: "tuesday", label: "Selasa" },
                  { key: "wednesday", label: "Rabu" },
                  { key: "thursday", label: "Kamis" },
                  { key: "friday", label: "Jumat" },
                  { key: "saturday", label: "Sabtu" },
                  { key: "sunday", label: "Minggu" },
                ].map((day) => (
                  <label key={day.key} className="flex items-center">
                    <input
                      type="checkbox"
                      checked={scheduleSettings.workDays.includes(day.key)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setScheduleSettings({
                            ...scheduleSettings,
                            workDays: [...scheduleSettings.workDays, day.key],
                          });
                        } else {
                          setScheduleSettings({
                            ...scheduleSettings,
                            workDays: scheduleSettings.workDays.filter(d => d !== day.key),
                          });
                        }
                      }}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">{day.label}</span>
                  </label>
                ))}
              </div>
            </div>
          </Flex>
        </Card>
      </Box>

      {/* Location Settings */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="4">
            <Flex align="center" gap="2">
              <MapPin className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Pengaturan Lokasi
              </h3>
            </Flex>
            <div className="space-y-6">
              {/* Map Display */}
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-700">
                  Peta Lokasi Kantor
                </label>
                <div className="border border-gray-200 rounded-lg overflow-hidden">
                  <iframe
                    src="https://www.openstreetmap.org/export/embed.html?bbox=106.8456%2C-6.2088%2C106.8456%2C-6.2088&layer=mapnik&marker=-6.2088%2C106.8456"
                    width="100%"
                    height="300"
                    style={{ border: 0 }}
                    title="OpenStreetMap"
                  ></iframe>
                </div>
                <p className="text-xs text-gray-500">
                  Klik pada peta OpenStreetMap untuk mendapatkan koordinat yang tepat, atau gunakan form di bawah ini.
                </p>
              </div>

              {/* Address Search */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cari Lokasi
                </label>
                <div className="flex gap-2">
                  <TextField.Root
                    placeholder="Masukkan nama tempat atau alamat..."
                    className="flex-1"
                  />
                  <Button variant="outline">
                    Cari
                  </Button>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  Contoh: "Jl. Sudirman, Jakarta" atau "Monas Jakarta"
                </p>
              </div>

              {/* Coordinates Input */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Lokasi Kantor Utama
                  </label>
                  <TextField.Root placeholder="Masukkan alamat lengkap kantor" />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Latitude
                    </label>
                    <TextField.Root
                      placeholder="-6.2088"
                      type="number"
                      step="0.000001"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Longitude
                    </label>
                    <TextField.Root
                      placeholder="106.8456"
                      type="number"
                      step="0.000001"
                    />
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button variant="outline" size="2">
                    📍 Dapatkan Lokasi Saat Ini
                  </Button>
                  <Button variant="outline" size="2">
                    🔍 Validasi Koordinat
                  </Button>
                </div>
              </div>

              {/* Radius and Actions */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Radius Lokasi (meter)
                  </label>
                  <Select.Root defaultValue="100">
                    <Select.Trigger />
                    <Select.Content>
                      <Select.Item value="50">50 meter (Sangat ketat)</Select.Item>
                      <Select.Item value="100">100 meter (Direkomendasikan)</Select.Item>
                      <Select.Item value="200">200 meter (Longgar)</Select.Item>
                      <Select.Item value="500">500 meter (Sangat longgar)</Select.Item>
                    </Select.Content>
                  </Select.Root>
                  <p className="text-xs text-gray-500 mt-1">
                    Radius menentukan jarak maksimal untuk check-in valid
                  </p>
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-blue-800 mb-2">
                    💡 Tips Pengaturan Lokasi
                  </h4>
                  <ul className="text-xs text-blue-700 space-y-1">
                    <li>• Pastikan koordinat akurat untuk menghindari check-in tidak valid</li>
                    <li>• Radius 100 meter direkomendasikan untuk kantor</li>
                    <li>• Gunakan OpenStreetMap untuk mencari koordinat tepat</li>
                    <li>• Test lokasi setelah menyimpan pengaturan</li>
                  </ul>
                </div>

                <div className="flex justify-between items-center">
                  <Button variant="outline">
                    Test Lokasi
                  </Button>
                  <Button>
                    Simpan Lokasi
                  </Button>
                </div>
              </div>
            </div>
          </Flex>
        </Card>
      </Box>

      {/* Security Settings */}
      <Box>
        <Card>
          <Flex direction="column" p="4" gap="4">
            <Flex align="center" gap="2">
              <Shield className="h-5 w-5" />
              <h3 className="text-lg font-semibold text-gray-900">
                Pengaturan Keamanan
              </h3>
            </Flex>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div>
                  <h4 className="text-sm font-medium text-gray-900">
                    Verifikasi Wajah
                  </h4>
                  <p className="text-sm text-gray-600">
                    Aktifkan verifikasi wajah untuk check-in yang lebih aman
                  </p>
                </div>
                <Switch defaultChecked />
              </div>
              <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                <div>
                  <h4 className="text-sm font-medium text-gray-900">
                    IP Whitelist
                  </h4>
                  <p className="text-sm text-gray-600">
                    Batasi akses hanya dari IP tertentu
                  </p>
                </div>
                <Switch />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Session Timeout (menit)
                </label>
                <Select.Root defaultValue="60">
                  <Select.Trigger />
                  <Select.Content>
                    <Select.Item value="15">15 menit</Select.Item>
                    <Select.Item value="30">30 menit</Select.Item>
                    <Select.Item value="60">1 jam</Select.Item>
                    <Select.Item value="120">2 jam</Select.Item>
                  </Select.Content>
                </Select.Root>
              </div>
            </div>
          </Flex>
        </Card>
      </Box>

      {/* Save Settings */}
      <div className="flex justify-end gap-4">
        <Button variant="outline">Batal</Button>
        <Button>Simpan Pengaturan</Button>
      </div>
    </div>
  );
}
