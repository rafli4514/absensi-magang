import { useState, useEffect } from "react";
import { QrCode, Clock, MapPin, Calendar, Shield, CheckCircle, AlertTriangle, Loader2 } from "lucide-react";
import {
  Box,
  Button,
  Card,
  Flex,
  IconButton,
  Select,
  Switch,
  TextField,
  Spinner,
  AlertDialog,
} from "@radix-ui/themes";
import { MagnifyingGlassIcon } from "@radix-ui/react-icons";
import pengaturanService, { type AppSettings } from "../services/pengaturanService";

export default function PengaturanPage() {
  // Main settings state
  const [settings, setSettings] = useState<AppSettings>(pengaturanService.getLocalSettings());
  const [originalSettings, setOriginalSettings] = useState<AppSettings>(pengaturanService.getLocalSettings());
  
  // UI states
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isGeneratingQR, setIsGeneratingQR] = useState(false);
  const [isTestingLocation, setIsTestingLocation] = useState(false);
  const [isGettingLocation, setIsGettingLocation] = useState(false);
  const [isSearchingLocation, setIsSearchingLocation] = useState(false);
  
  // Messages
  const [successMessage, setSuccessMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  
  // Location search
  const [locationQuery, setLocationQuery] = useState('');
  const [locationResults, setLocationResults] = useState<Array<{ address: string; latitude: number; longitude: number }>>([]);
  const [showLocationResults, setShowLocationResults] = useState(false);
  
  // QR Code
  const [currentQRCode, setCurrentQRCode] = useState<string>('');
  const [qrExpiresAt, setQrExpiresAt] = useState<string>('');
  const [qrImageError, setQrImageError] = useState<boolean>(false);
  
  // Location test results
  const [locationTestResult, setLocationTestResult] = useState<{ distance: number; isWithinRange: boolean } | null>(null);
  const [showUnsavedDialog, setShowUnsavedDialog] = useState(false);

  // Load settings on component mount
  useEffect(() => {
    loadSettings();
  }, []);

  // Load settings from server
  const loadSettings = async () => {
    try {
      setIsLoading(true);
      setErrorMessage('');
      
      const response = await pengaturanService.getSettings();
      if (response.success && response.data) {
        setSettings(response.data);
        setOriginalSettings(response.data);
        pengaturanService.saveLocalSettings(response.data);
      }
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || 'Gagal memuat pengaturan');
      console.error('Load settings error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Save settings
  const saveSettings = async () => {
    try {
      setIsSaving(true);
      setErrorMessage('');
      setSuccessMessage('');
      
      const response = await pengaturanService.updateSettings(settings);
      if (response.success) {
        setOriginalSettings(settings);
        pengaturanService.saveLocalSettings(settings);
        setSuccessMessage('Pengaturan berhasil disimpan!');
        setTimeout(() => setSuccessMessage(''), 3000);
      } else {
        throw new Error(response.message || 'Failed to save settings');
      }
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || 'Gagal menyimpan pengaturan');
      console.error('Save settings error:', error);
    } finally {
      setIsSaving(false);
    }
  };

  // Generate QR Code
  const generateQRCode = async () => {
    try {
      setIsGeneratingQR(true);
      setErrorMessage('');
      
      const response = await pengaturanService.generateQRCode();
      if (response.success && response.data) {
        setCurrentQRCode(response.data.qrCode);
        setQrExpiresAt(response.data.expiresAt);
        setQrImageError(false);
        setSuccessMessage('QR Code baru berhasil dibuat!');
        setTimeout(() => setSuccessMessage(''), 3000);
      }
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || 'Gagal membuat QR Code');
      console.error('Generate QR error:', error);
    } finally {
      setIsGeneratingQR(false);
    }
  };

  // Get current location
  const getCurrentLocation = async () => {
    try {
      setIsGettingLocation(true);
      setErrorMessage('');
      
      const location = await pengaturanService.getCurrentLocation();
      setSettings({
        ...settings,
        location: {
          ...settings.location,
          latitude: location.latitude,
          longitude: location.longitude
        }
      });
      setSuccessMessage('Lokasi berhasil diambil!');
      setTimeout(() => setSuccessMessage(''), 3000);
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || 'Gagal mengambil lokasi');
      console.error('Get location error:', error);
    } finally {
      setIsGettingLocation(false);
    }
  };

  // Test location
  const testLocation = async () => {
    try {
      setIsTestingLocation(true);
      setErrorMessage('');
      setLocationTestResult(null);
      
      const response = await pengaturanService.testLocation(
        settings.location.latitude,
        settings.location.longitude,
        settings.location.radius
      );
      
      if (response.success && response.data) {
        setLocationTestResult(response.data);
        if (response.data.isWithinRange) {
          setSuccessMessage(`Test lokasi berhasil! Jarak: ${response.data.distance}m`);
        } else {
          setErrorMessage(`Test lokasi gagal! Jarak: ${response.data.distance}m (melebihi radius ${settings.location.radius}m)`);
        }
        setTimeout(() => {
          setSuccessMessage('');
          setErrorMessage('');
        }, 5000);
      }
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || 'Gagal melakukan test lokasi');
      console.error('Test location error:', error);
    } finally {
      setIsTestingLocation(false);
    }
  };

  // Search location
  const searchLocation = async () => {
    if (!locationQuery.trim()) return;
    
    try {
      setIsSearchingLocation(true);
      setErrorMessage('');
      
      const results = await pengaturanService.searchLocation(locationQuery);
      setLocationResults(results);
      setShowLocationResults(true);
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || 'Gagal mencari lokasi');
      console.error('Search location error:', error);
    } finally {
      setIsSearchingLocation(false);
    }
  };

  // Select location from search results
  const selectLocation = (result: { address: string; latitude: number; longitude: number }) => {
    setSettings({
      ...settings,
      location: {
        ...settings.location,
        officeAddress: result.address,
        latitude: result.latitude,
        longitude: result.longitude
      }
    });
    setShowLocationResults(false);
    setLocationQuery('');
    setLocationResults([]);
  };

  // Validate coordinates
  const validateCoordinates = () => {
    const validation = pengaturanService.validateCoordinates(
      settings.location.latitude,
      settings.location.longitude
    );
    
    if (validation.isValid) {
      setSuccessMessage('Koordinat valid!');
    } else {
      setErrorMessage(validation.message);
    }
    
    setTimeout(() => {
      setSuccessMessage('');
      setErrorMessage('');
    }, 3000);
  };

  // Check if settings have changed
  const hasUnsavedChanges = () => {
    return JSON.stringify(settings) !== JSON.stringify(originalSettings);
  };

  // Handle cancel
  const handleCancel = () => {
    if (hasUnsavedChanges()) {
      setShowUnsavedDialog(true);
    } else {
      // No changes, just reload original settings
      setSettings(originalSettings);
    }
  };

  // Confirm cancel
  const confirmCancel = () => {
    setSettings(originalSettings);
    setShowUnsavedDialog(false);
    setSuccessMessage('Perubahan dibatalkan');
    setTimeout(() => setSuccessMessage(''), 3000);
  };

  // Clear messages
  const clearMessages = () => {
    setSuccessMessage('');
    setErrorMessage('');
  };

  // Show loading spinner
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <Spinner size="3" className="mb-4" />
          <p className="text-gray-600">Memuat pengaturan...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Pengaturan Absensi
          </h1>
          <p className="text-gray-600">
            Kelola pengaturan sistem absensi dan kehadiran
          </p>
        </div>
        {hasUnsavedChanges() && (
          <div className="flex items-center gap-2 text-orange-600">
            <AlertTriangle className="h-4 w-4" />
            <span className="text-sm">Ada perubahan yang belum disimpan</span>
          </div>
        )}
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
                    checked={settings.qr.autoGenerate}
                    onCheckedChange={(checked) =>
                      setSettings({
                        ...settings,
                        qr: { ...settings.qr, autoGenerate: checked },
                      })
                    }
                  />
                </div>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Periode Validitas QR (menit)
                  </label>
                  <Select.Root
                    value={settings.qr.validityPeriod.toString()}
                    onValueChange={(value) =>
                      setSettings({
                        ...settings,
                        qr: { ...settings.qr, validityPeriod: parseInt(value) },
                      })
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
            <div className="flex justify-end">
              <Button
                variant="outline"
                onClick={generateQRCode}
                disabled={isGeneratingQR}
              >
                {isGeneratingQR ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Membuat QR...
                  </>
                ) : (
                  "Generate QR Code Baru"
                )}
              </Button>
            </div>
            {currentQRCode && (
              <div className="mt-4 p-4 bg-gray-50 rounded-lg border">
                <div className="text-center">
                  <div className="mb-2">
                    {!qrImageError ? (
                      <img
                        src={`data:image/png;base64,${currentQRCode}`}
                        alt="QR Code"
                        className="mx-auto border-2 border-gray-300 rounded-lg shadow-sm bg-white"
                        style={{ width: "200px", height: "200px" }}
                        onError={(e) => {
                          console.error("QR Code image failed to load:", e);
                          console.log(
                            "QR Code data length:",
                            currentQRCode.length
                          );
                          console.log(
                            "QR Code data preview:",
                            currentQRCode.substring(0, 100) + "..."
                          );
                          setQrImageError(true);
                        }}
                        onLoad={() => {
                          console.log("QR Code image loaded successfully");
                        }}
                      />
                    ) : (
                      <div
                        className="mx-auto border-2 border-dashed border-gray-300 rounded-lg bg-white flex items-center justify-center"
                        style={{ width: "200px", height: "200px" }}
                      >
                        <div className="text-center text-gray-500">
                          <QrCode className="h-12 w-12 mx-auto mb-2" />
                          <p className="text-xs">QR Code gagal dimuat</p>
                          <p className="text-xs">Coba generate ulang</p>
                        </div>
                      </div>
                    )}
                  </div>
                  <p className="text-sm text-gray-600">
                    QR Code berlaku hingga:{" "}
                    {new Date(qrExpiresAt).toLocaleString("id-ID")}
                  </p>
                  {qrImageError && (
                    <p className="text-xs text-red-600 mt-1">
                      Gambar QR Code tidak dapat ditampilkan. Silakan generate
                      ulang.
                    </p>
                  )}
                </div>
              </div>
            )}
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
                  checked={settings.attendance.allowLateCheckIn}
                  onCheckedChange={(checked) =>
                    setSettings({
                      ...settings,
                      attendance: {
                        ...settings.attendance,
                        allowLateCheckIn: checked,
                      },
                    })
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
                  checked={settings.attendance.requireLocation}
                  onCheckedChange={(checked) =>
                    setSettings({
                      ...settings,
                      attendance: {
                        ...settings.attendance,
                        requireLocation: checked,
                      },
                    })
                  }
                />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Batas Keterlambatan (menit)
                  </label>
                  <Select.Root
                    value={settings.attendance.lateThreshold.toString()}
                    onValueChange={(value) =>
                      setSettings({
                        ...settings,
                        attendance: {
                          ...settings.attendance,
                          lateThreshold: parseInt(value),
                        },
                      })
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
                    value={settings.schedule.workStartTime}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                      setSettings({
                        ...settings,
                        schedule: {
                          ...settings.schedule,
                          workStartTime: e.target.value,
                        },
                      })
                    }
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Jam Istirahat Mulai
                  </label>
                  <TextField.Root
                    type="time"
                    value={settings.schedule.breakStartTime}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                      setSettings({
                        ...settings,
                        schedule: {
                          ...settings.schedule,
                          breakStartTime: e.target.value,
                        },
                      })
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
                    value={settings.schedule.workEndTime}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                      setSettings({
                        ...settings,
                        schedule: {
                          ...settings.schedule,
                          workEndTime: e.target.value,
                        },
                      })
                    }
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Jam Istirahat Selesai
                  </label>
                  <TextField.Root
                    type="time"
                    value={settings.schedule.breakEndTime}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                      setSettings({
                        ...settings,
                        schedule: {
                          ...settings.schedule,
                          breakEndTime: e.target.value,
                        },
                      })
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
                      checked={settings.schedule.workDays.includes(day.key)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSettings({
                            ...settings,
                            schedule: {
                              ...settings.schedule,
                              workDays: [
                                ...settings.schedule.workDays,
                                day.key,
                              ],
                            },
                          });
                        } else {
                          setSettings({
                            ...settings,
                            schedule: {
                              ...settings.schedule,
                              workDays: settings.schedule.workDays.filter(
                                (d) => d !== day.key
                              ),
                            },
                          });
                        }
                      }}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">
                      {day.label}
                    </span>
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
                  Klik pada peta OpenStreetMap untuk mendapatkan koordinat yang
                  tepat, atau gunakan form di bawah ini.
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
                    value={locationQuery}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                      setLocationQuery(e.target.value)
                    }
                    onKeyPress={(e) => e.key === "Enter" && searchLocation()}
                  />
                  <IconButton
                    onClick={searchLocation}
                    disabled={isSearchingLocation}
                  >
                    {isSearchingLocation ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <MagnifyingGlassIcon />
                    )}
                  </IconButton>
                </div>
                {/* Location Search Results */}
                {showLocationResults && locationResults.length > 0 && (
                  <div className="mt-2 border border-gray-200 rounded-lg bg-white shadow-lg max-h-60 overflow-y-auto">
                    {locationResults.map((result, index) => (
                      <div
                        key={index}
                        className="p-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                        onClick={() => selectLocation(result)}
                      >
                        <p className="text-sm text-gray-900 truncate">
                          {result.address}
                        </p>
                        <p className="text-xs text-gray-500">
                          {result.latitude.toFixed(6)},{" "}
                          {result.longitude.toFixed(6)}
                        </p>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Coordinates Input */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Lokasi Kantor Utama
                  </label>
                  <TextField.Root
                    placeholder="Masukkan alamat lengkap kantor"
                    value={settings.location.officeAddress}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                      setSettings({
                        ...settings,
                        location: {
                          ...settings.location,
                          officeAddress: e.target.value,
                        },
                      })
                    }
                  />
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
                      value={settings.location.latitude.toString()}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                        setSettings({
                          ...settings,
                          location: {
                            ...settings.location,
                            latitude: parseFloat(e.target.value) || 0,
                          },
                        })
                      }
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
                      value={settings.location.longitude.toString()}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                        setSettings({
                          ...settings,
                          location: {
                            ...settings.location,
                            longitude: parseFloat(e.target.value) || 0,
                          },
                        })
                      }
                    />
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="2"
                    onClick={getCurrentLocation}
                    disabled={isGettingLocation}
                  >
                    {isGettingLocation ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Mengambil...
                      </>
                    ) : (
                      "Dapatkan Lokasi Saat Ini"
                    )}
                  </Button>
                  <Button
                    variant="outline"
                    size="2"
                    onClick={validateCoordinates}
                  >
                    Validasi Koordinat
                  </Button>
                </div>
              </div>

              {/* Radius and Actions */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Radius Lokasi (meter)
                  </label>
                  <Select.Root
                    value={settings.location.radius.toString()}
                    onValueChange={(value) =>
                      setSettings({
                        ...settings,
                        location: {
                          ...settings.location,
                          radius: parseInt(value),
                        },
                      })
                    }
                  >
                    <Select.Trigger />
                    <Select.Content>
                      <Select.Item value="50">
                        50 meter (Sangat ketat)
                      </Select.Item>
                      <Select.Item value="100">
                        100 meter (Direkomendasikan)
                      </Select.Item>
                      <Select.Item value="200">200 meter (Longgar)</Select.Item>
                      <Select.Item value="500">
                        500 meter (Sangat longgar)
                      </Select.Item>
                    </Select.Content>
                  </Select.Root>
                  <p className="text-xs text-gray-500 mt-1">
                    Radius menentukan jarak maksimal untuk check-in valid
                  </p>
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-blue-800 mb-2">
                    Tips Pengaturan Lokasi
                  </h4>
                  <ul className="text-xs text-blue-700 space-y-1">
                    <li>
                      • Pastikan koordinat akurat untuk menghindari check-in
                      tidak valid
                    </li>
                    <li>• Radius 100 meter direkomendasikan untuk kantor</li>
                    <li>
                      • Gunakan OpenStreetMap untuk mencari koordinat tepat
                    </li>
                    <li>• Test lokasi setelah menyimpan pengaturan</li>
                  </ul>
                </div>

                <div className="flex justify-between items-center">
                  <Button
                    variant="outline"
                    onClick={testLocation}
                    disabled={isTestingLocation}
                  >
                    {isTestingLocation ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Testing...
                      </>
                    ) : (
                      "Test Lokasi"
                    )}
                  </Button>
                  <Button onClick={saveSettings} disabled={isSaving}>
                    {isSaving ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Menyimpan...
                      </>
                    ) : (
                      "Simpan Lokasi"
                    )}
                  </Button>
                </div>
                {/* Location Test Result */}
                {locationTestResult && (
                  <div
                    className={`mt-4 p-4 rounded-lg ${
                      locationTestResult.isWithinRange
                        ? "bg-green-50 border border-green-200"
                        : "bg-red-50 border border-red-200"
                    }`}
                  >
                    <div className="flex items-center">
                      {locationTestResult.isWithinRange ? (
                        <CheckCircle className="h-5 w-5 text-green-600 mr-2" />
                      ) : (
                        <AlertTriangle className="h-5 w-5 text-red-600 mr-2" />
                      )}
                      <div>
                        <p
                          className={`font-medium ${
                            locationTestResult.isWithinRange
                              ? "text-green-800"
                              : "text-red-800"
                          }`}
                        >
                          {locationTestResult.isWithinRange
                            ? "Test Lokasi Berhasil!"
                            : "Test Lokasi Gagal!"}
                        </p>
                        <p
                          className={`text-sm ${
                            locationTestResult.isWithinRange
                              ? "text-green-700"
                              : "text-red-700"
                          }`}
                        >
                          Jarak dari kantor: {locationTestResult.distance}m
                          (Radius: {settings.location.radius}m)
                        </p>
                      </div>
                    </div>
                  </div>
                )}
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
                <Switch
                  checked={settings.security.faceVerification}
                  onCheckedChange={(checked) =>
                    setSettings({
                      ...settings,
                      security: {
                        ...settings.security,
                        faceVerification: checked,
                      },
                    })
                  }
                />
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
                <Switch
                  checked={settings.security.ipWhitelist}
                  onCheckedChange={(checked) =>
                    setSettings({
                      ...settings,
                      security: { ...settings.security, ipWhitelist: checked },
                    })
                  }
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Session Timeout (menit)
                </label>
                <Select.Root
                  value={settings.security.sessionTimeout.toString()}
                  onValueChange={(value) =>
                    setSettings({
                      ...settings,
                      security: {
                        ...settings.security,
                        sessionTimeout: parseInt(value),
                      },
                    })
                  }
                >
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
        <Button variant="outline" onClick={handleCancel} disabled={isSaving}>
          Batal
        </Button>
        <Button
          onClick={saveSettings}
          disabled={isSaving || !hasUnsavedChanges()}
        >
          {isSaving ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Menyimpan...
            </>
          ) : (
            "Simpan Pengaturan"
          )}
        </Button>
      </div>

      {/* Unsaved Changes Dialog */}
      <AlertDialog.Root
        open={showUnsavedDialog}
        onOpenChange={setShowUnsavedDialog}
      >
        <AlertDialog.Content>
          <AlertDialog.Title>Perubahan Belum Disimpan</AlertDialog.Title>
          <AlertDialog.Description>
            Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin
            membatalkan perubahan?
          </AlertDialog.Description>
          <Flex gap="3" mt="4" justify="end">
            <AlertDialog.Cancel>
              <Button variant="soft" color="gray">
                Kembali
              </Button>
            </AlertDialog.Cancel>
            <AlertDialog.Action>
              <Button variant="solid" color="red" onClick={confirmCancel}>
                Ya, Batalkan
              </Button>
            </AlertDialog.Action>
          </Flex>
        </AlertDialog.Content>
      </AlertDialog.Root>
    </div>
  );
}
