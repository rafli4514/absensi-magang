import React, { useState, useEffect, Fragment } from "react";
import {
  Clock,
  MapPin,
  Calendar,
  Shield,
  CheckCircle,
  AlertTriangle,
  Loader2,
} from "lucide-react";
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
import pengaturanService, {
  type AppSettings,
} from "../services/pengaturanService";
import InteractiveMap from "../components/InteractiveMap";

// Error Boundary Component
const PengaturanPageContent = () => {
  // Main settings state
  const [settings, setSettings] = useState<AppSettings>(() => {
    try {
      return pengaturanService.getLocalSettings();
    } catch (error) {
      console.error("Failed to load local settings:", error);
      // Return default settings if local settings fail
      return {
        attendance: {
          allowLateCheckIn: true,
          lateThreshold: 15,
          requireLocation: true,
          allowRemoteCheckIn: false,
        },
        schedule: {
          workStartTime: "08:00",
          workEndTime: "17:00",
          breakStartTime: "12:00",
          breakEndTime: "13:00",
          workDays: ["monday", "tuesday", "wednesday", "thursday", "friday"],
        },
        location: {
          officeAddress:
            "PT PLN Icon Plus Kantor Perwakilan Aceh, Jl. Teuku Umar, Banda Aceh",
          latitude: 5.5454249,
          longitude: 95.3175582,
          radius: 100,
          useRadius: true,
        },
        security: {
          faceVerification: false,
          ipWhitelist: false,
          sessionTimeout: 60,
        },
      };
    }
  });
  const [originalSettings, setOriginalSettings] =
    useState<AppSettings>(settings);
  
  // UI states
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isTestingLocation, setIsTestingLocation] = useState(false);
  const [isGettingLocation, setIsGettingLocation] = useState(false);
  const [isSearchingLocation, setIsSearchingLocation] = useState(false);
  
  // Messages
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [validationErrors, setValidationErrors] = useState<string[]>([]);
  
  // Location search
  const [locationQuery, setLocationQuery] = useState("");
  const [locationResults, setLocationResults] = useState<
    Array<{ address: string; latitude: number; longitude: number }>
  >([]);
  const [showLocationResults, setShowLocationResults] = useState(false);
  
  // Quick location presets
  const [showPresetLocations, setShowPresetLocations] = useState(false);

  // Preset locations for easy selection (with stable IDs)
  const presetLocations = [
    {
      id: "pln-aceh",
      name: "PLN Icon Plus Aceh",
      address:
        "PT PLN Icon Plus Kantor Perwakilan Aceh, Jl. Teuku Umar, Banda Aceh",
      latitude: 5.5454249,
      longitude: 95.3175582,
      icon: "🏢",
    },
    {
      id: "pln-jakarta",
      name: "PLN Pusat Jakarta",
      address: "PT PLN (Persero) Kantor Pusat, Jl. Trunojoyo, Jakarta Selatan",
      latitude: -6.2088,
      longitude: 106.8456,
      icon: "🏛️",
    },
    {
      id: "pln-medan",
      name: "PLN Medan",
      address: "PT PLN Wilayah Sumatera Utara, Medan",
      latitude: 3.5952,
      longitude: 98.6722,
      icon: "⚡",
    },
    {
      id: "pln-surabaya",
      name: "PLN Surabaya",
      address: "PT PLN Wilayah Jawa Timur, Surabaya",
      latitude: -7.2575,
      longitude: 112.7521,
      icon: "🔌",
    },
    {
      id: "pln-makassar",
      name: "PLN Makassar",
      address: "PT PLN Wilayah Sulawesi Selatan, Makassar",
      latitude: -5.1477,
      longitude: 119.4327,
      icon: "💡",
    },
    {
      id: "pln-denpasar",
      name: "PLN Denpasar",
      address: "PT PLN Wilayah Bali, Denpasar",
      latitude: -8.6705,
      longitude: 115.2126,
      icon: "🌴",
    },
  ];
  
  // Location test results
  const [locationTestResult, setLocationTestResult] = useState<{
    distance: number;
    isWithinRange: boolean;
  } | null>(null);
  const [showUnsavedDialog, setShowUnsavedDialog] = useState(false);

  // Load settings on component mount
  useEffect(() => {
    let isMounted = true;
    
    const initializeSettings = async () => {
      try {
        if (isMounted) {
          await loadSettings();
        }
      } catch (error) {
        if (isMounted) {
          console.error("Failed to initialize settings:", error);
          setErrorMessage("Gagal memuat pengaturan awal");
        }
      }
    };
    
    initializeSettings();
    
    return () => {
      isMounted = false;
    };
  }, []);

  // Load settings from server
  const loadSettings = async () => {
    try {
      setIsLoading(true);
      setErrorMessage("");
      
      const response = await pengaturanService.getSettings();
      if (response && response.success && response.data) {
        setSettings(response.data);
        setOriginalSettings(response.data);
        pengaturanService.saveLocalSettings(response.data);
      } else {
        throw new Error(response?.message || "Failed to load settings");
      }
    } catch (error: unknown) {
      const errorMessage =
        error instanceof Error ? error.message : "Gagal memuat pengaturan";
      setErrorMessage(errorMessage);
      console.error("Load settings error:", error);
      
      // Use local settings as fallback
      const localSettings = pengaturanService.getLocalSettings();
      setSettings(localSettings);
      setOriginalSettings(localSettings);
    } finally {
      setIsLoading(false);
    }
  };

  // Save settings
  const saveSettings = async () => {
    try {
      setIsSaving(true);
      setErrorMessage("");
      setSuccessMessage("");
      setValidationErrors([]);

      // Validate settings before saving
      const validation = pengaturanService.validateSettings(settings);
      if (!validation.isValid) {
        setValidationErrors(validation.errors);
        setErrorMessage(
          "Terdapat kesalahan pada pengaturan. Silakan periksa kembali."
        );
        return;
      }
      
      const response = await pengaturanService.updateSettings(settings);
      if (response.success) {
        setOriginalSettings(settings);
        pengaturanService.saveLocalSettings(settings);
        setSuccessMessage("Pengaturan berhasil disimpan!");
        setTimeout(() => setSuccessMessage(""), 3000);
      } else {
        throw new Error(response.message || "Failed to save settings");
      }
    } catch (error: unknown) {
      setErrorMessage((error as Error).message || "Gagal menyimpan pengaturan");
      console.error("Save settings error:", error);
    } finally {
      setIsSaving(false);
    }
  };

  // Get current location
  const getCurrentLocation = async () => {
    try {
      setIsGettingLocation(true);
      setErrorMessage("");
      
      // Check if geolocation is supported
      if (!navigator.geolocation) {
        throw new Error("Geolocation is not supported by this browser");
      }
      
      const location = await pengaturanService.getCurrentLocation();
      
      if (
        location &&
        typeof location.latitude === "number" &&
        typeof location.longitude === "number"
      ) {
        setSettings((prevSettings) => ({
          ...prevSettings,
          location: {
            ...prevSettings.location,
            latitude: location.latitude,
            longitude: location.longitude,
          },
        }));
        setSuccessMessage("Lokasi berhasil diambil!");
        setTimeout(() => setSuccessMessage(""), 3000);
      } else {
        throw new Error("Invalid location data received");
      }
    } catch (error: unknown) {
      const errorMessage =
        error instanceof Error ? error.message : "Gagal mengambil lokasi";
      setErrorMessage(errorMessage);
      console.error("Get location error:", error);
    } finally {
      setIsGettingLocation(false);
    }
  };

  // Test location
  const testLocation = async () => {
    try {
      setIsTestingLocation(true);
      setErrorMessage("");
      setLocationTestResult(null);

      if (!settings.location.useRadius) {
        // If radius is disabled, always return success
        setLocationTestResult({
          distance: 0,
          isWithinRange: true,
        });
        setSuccessMessage(
          "Test lokasi berhasil! (Radius tidak digunakan - absensi bisa dari mana saja)"
        );
        setTimeout(() => {
          setSuccessMessage("");
        }, 4000);
        return;
      }
      
      const response = await pengaturanService.testLocation(
        settings.location.latitude,
        settings.location.longitude,
        settings.location.radius
      );
      
      if (response.success && response.data) {
        setLocationTestResult(response.data);
        if (response.data.isWithinRange) {
          setSuccessMessage(
            `Test lokasi berhasil! Jarak: ${response.data.distance}m (dalam radius ${settings.location.radius}m)`
          );
        } else {
          setErrorMessage(
            `Test lokasi gagal! Jarak: ${response.data.distance}m (melebihi radius ${settings.location.radius}m)`
          );
        }
        setTimeout(() => {
          setSuccessMessage("");
          setErrorMessage("");
        }, 5000);
      }
    } catch (error: unknown) {
      setErrorMessage(
        (error as Error).message || "Gagal melakukan test lokasi"
      );
      console.error("Test location error:", error);
    } finally {
      setIsTestingLocation(false);
    }
  };

  // Search location
  const searchLocation = async () => {
    if (!locationQuery.trim()) {
      setErrorMessage("Masukkan query pencarian lokasi");
      return;
    }
    
    try {
      setIsSearchingLocation(true);
      setErrorMessage("");
      setLocationResults([]);
      
      const results = await pengaturanService.searchLocation(locationQuery);
      
      if (Array.isArray(results)) {
        setLocationResults(results);
        setShowLocationResults(true);
        
        if (results.length === 0) {
          setErrorMessage("Tidak ada lokasi yang ditemukan");
        }
      } else {
        throw new Error("Invalid search results format");
      }
    } catch (error: unknown) {
      const errorMessage =
        error instanceof Error ? error.message : "Gagal mencari lokasi";
      setErrorMessage(errorMessage);
      console.error("Search location error:", error);
      setLocationResults([]);
      setShowLocationResults(false);
    } finally {
      setIsSearchingLocation(false);
    }
  };

  // Select location from search results
  const selectLocation = (result: {
    address: string;
    latitude: number;
    longitude: number;
  }) => {
    try {
      setSettings((prevSettings) => ({
        ...prevSettings,
        location: {
          ...prevSettings.location,
          officeAddress: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
        },
      }));
      setShowLocationResults(false);
      setLocationQuery("");
      setLocationResults([]);
      setSuccessMessage("Lokasi berhasil dipilih!");
      setTimeout(() => setSuccessMessage(""), 3000);
    } catch (error) {
      console.error("Select location error:", error);
      setErrorMessage("Gagal memilih lokasi");
    }
  };

  // Select preset location
  const selectPresetLocation = (location: {
    id: string;
    name: string;
    address: string;
    latitude: number;
    longitude: number;
    icon: string;
  }) => {
    try {
      setSettings((prevSettings) => ({
        ...prevSettings,
        location: {
          ...prevSettings.location,
          officeAddress: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
        },
      }));
      setShowPresetLocations(false);
      setSuccessMessage(`Lokasi ${location.name} berhasil dipilih!`);
      setTimeout(() => setSuccessMessage(""), 3000);
    } catch (error) {
      console.error("Select preset location error:", error);
      setErrorMessage("Gagal memilih lokasi preset");
    }
  };

  // Handle map click/drag to set coordinates
  const handleMapLocationChange = (lat: number, lng: number) => {
    try {
      setSettings((prevSettings) => ({
        ...prevSettings,
        location: {
          ...prevSettings.location,
          latitude: lat,
          longitude: lng,
        },
      }));
      setSuccessMessage(
        `Koordinat diupdate: ${lat.toFixed(6)}, ${lng.toFixed(6)}`
      );
      setTimeout(() => setSuccessMessage(""), 2000);
    } catch (error) {
      console.error("Map location change error:", error);
      setErrorMessage("Gagal mengupdate koordinat dari peta");
    }
  };

  // Validate coordinates
  const validateCoordinates = () => {
    const validation = pengaturanService.validateCoordinates(
      settings.location.latitude,
      settings.location.longitude
    );
    
    if (validation.isValid) {
      setSuccessMessage("Koordinat valid!");
    } else {
      setErrorMessage(validation.message);
    }
    
    setTimeout(() => {
      setSuccessMessage("");
      setErrorMessage("");
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
    setSuccessMessage("Perubahan dibatalkan");
    setTimeout(() => setSuccessMessage(""), 3000);
  };

  // Clear messages
  const clearMessages = () => {
    setSuccessMessage("");
    setErrorMessage("");
    setValidationErrors([]);
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
                <div>
                <p className="text-red-800 font-medium">{errorMessage}</p>
                  {validationErrors.length > 0 && (
                    <ul className="text-red-700 text-sm mt-2 list-disc list-inside">
                      {validationErrors.map((error, index) => (
                        <li key={index}>{error}</li>
                      ))}
                    </ul>
                  )}
                </div>
              </div>
              <Button variant="ghost" size="1" onClick={clearMessages}>
                ×
              </Button>
            </div>
          </div>
        </Card>
      )}

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
              {/* Interactive Map Display */}
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-700">
                  Peta Interaktif - Klik untuk Set Lokasi
                </label>
                <InteractiveMap
                  latitude={settings.location.latitude}
                  longitude={settings.location.longitude}
                  onLocationChange={handleMapLocationChange}
                  height="350px"
                  useRadius={settings.location.useRadius}
                  radius={settings.location.radius}
                />
                </div>

              {/* Quick Location Selection */}
              <div>
                <div className="flex justify-between items-center mb-3">
                  <Button
                    variant="ghost"
                    size="1"
                    onClick={() => setShowPresetLocations(!showPresetLocations)}
                  >
                    {showPresetLocations ? "Sembunyikan" : "Tampilkan Pilihan"}
                  </Button>
                </div>

                <Fragment>
                  {showPresetLocations && (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 mb-4 p-4 bg-gray-50 rounded-lg border">
                      {presetLocations.map((location) => (
                        <div
                          key={location.id}
                          className="p-3 bg-white rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 cursor-pointer transition-all duration-200 group"
                          onClick={() => selectPresetLocation(location)}
                        >
                          <div className="flex items-center space-x-3">
                            <div className="text-2xl group-hover:scale-110 transition-transform">
                              {location.icon}
                            </div>
                            <div className="flex-1 min-w-0">
                              <h4 className="text-sm font-medium text-gray-900 truncate">
                                {location.name}
                              </h4>
                              <p className="text-xs text-gray-500 truncate">
                                {location.address.split(",")[0]}
                              </p>
                              <div className="flex items-center text-xs text-gray-400 mt-1">
                                <MapPin className="h-3 w-3 mr-1" />
                                {location.latitude.toFixed(4)},{" "}
                                {location.longitude.toFixed(4)}
                              </div>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </Fragment>
              </div>

              {/* Address Search */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cari Lokasi Manual
                </label>
                <div className="flex gap-2">
                  <TextField.Root
                    placeholder="Cari lokasi (contoh: PLN Icon Plus Aceh)"
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
                <Fragment>
                {showLocationResults && locationResults.length > 0 && (
                  <div className="mt-2 border border-gray-200 rounded-lg bg-white shadow-lg max-h-60 overflow-y-auto">
                    {locationResults.map((result, index) => (
                      <div
                          key={`${result.latitude.toFixed(
                            6
                          )}-${result.longitude.toFixed(6)}-${index}`}
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
                </Fragment>
              </div>

              {/* Coordinates Input */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Alamat
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
                      placeholder="Masukkan latitude (contoh: 5.5454249)"
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
                      placeholder="Masukkan longitude (contoh: 95.3175582)"
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
                    variant="solid"
                    size="2"
                    onClick={getCurrentLocation}
                    disabled={isGettingLocation}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    {isGettingLocation ? (
                      <>
                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                        Mendeteksi Lokasi...
                      </>
                    ) : (
                      <>
                        <MapPin className="h-4 w-4 mr-2" />
                        Gunakan Lokasi Saya
                      </>
                    )}
                  </Button>
                  <Button
                    variant="outline"
                    size="2"
                    onClick={validateCoordinates}
                  >
                    ✓ Validasi Koordinat
                  </Button>
                </div>
              </div>

              {/* Radius and Actions */}
              <div className="space-y-4">
                {/* Toggle Radius Usage */}
                <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                  <div>
                    <h4 className="text-sm font-medium text-gray-900">
                      Gunakan Pembatasan Radius
                    </h4>
                    <p className="text-sm text-gray-600">
                      Batasi absensi hanya dalam radius tertentu dari kantor
                    </p>
                  </div>
                  <Switch
                    checked={settings.location.useRadius}
                    onCheckedChange={(checked) =>
                      setSettings({
                        ...settings,
                        location: {
                          ...settings.location,
                          useRadius: checked,
                        },
                      })
                    }
                  />
                </div>

                {/* Radius Setting - Only show if useRadius is enabled */}
                {settings.location.useRadius && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                      Radius Area PLN (meter)
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
                        <Select.Item value="25">25 meter</Select.Item>
                        <Select.Item value="50">50 meter</Select.Item>
                      <Select.Item value="100">
                        100 meter (Direkomendasikan)
                      </Select.Item>
                        <Select.Item value="200">
                          200 meter
                      </Select.Item>
                        <Select.Item value="500">500 meter</Select.Item>
                        <Select.Item value="1000">1000 meter</Select.Item>
                    </Select.Content>
                  </Select.Root>
                  <p className="text-xs text-gray-500 mt-1">
                      Radius menentukan jarak maksimal dari kantor PLN untuk
                      absensi valid
                  </p>
                </div>
                )}

                {/* Radius Status Info */}
                <div
                  className={`p-3 rounded-lg border ${
                    settings.location.useRadius
                      ? "bg-blue-50 border-blue-200"
                      : "bg-gray-50 border-gray-200"
                  }`}
                >
                  <div className="flex items-center text-sm">
                    <div className="mr-2">
                      {settings.location.useRadius ? "🎯" : "🌍"}
                    </div>
                    <div>
                      <p
                        className={`font-medium ${
                          settings.location.useRadius
                            ? "text-blue-800"
                            : "text-gray-700"
                        }`}
                      >
                        {settings.location.useRadius
                          ? `Radius Aktif: ${settings.location.radius}m`
                          : "Radius Tidak Digunakan"}
                      </p>
                      <p
                        className={`text-xs ${
                          settings.location.useRadius
                            ? "text-blue-600"
                            : "text-gray-500"
                        }`}
                      >
                        {settings.location.useRadius
                          ? "Absensi hanya bisa dilakukan dalam radius yang ditentukan"
                          : "Absensi bisa dilakukan dari mana saja (tidak ada pembatasan lokasi)"}
                      </p>
                    </div>
                  </div>
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
                      "Simpan Lokasi PLN"
                    )}
                  </Button>
                </div>
                {/* Location Test Result */}
                <Fragment>
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
                            {settings.location.useRadius
                              ? `Jarak dari kantor: ${locationTestResult.distance}m (Radius: ${settings.location.radius}m)`
                              : "Radius tidak digunakan - absensi diizinkan dari mana saja"}
                        </p>
                      </div>
                    </div>
                  </div>
                )}
                </Fragment>
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
      <div className="flex justify-between items-center">
        <div className="text-sm text-gray-500">
          {hasUnsavedChanges() && (
            <span className="text-orange-600">
              ⚠️ Ada perubahan yang belum disimpan
            </span>
          )}
        </div>
        <div className="flex gap-4">
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
};

// Error Boundary Component
class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error(
      "PengaturanPage Error Boundary caught an error:",
      error,
      errorInfo
    );
  }

  render() {
    if (this.state.hasError) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center max-w-md mx-auto p-6">
          <AlertTriangle className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-xl font-bold text-gray-900 mb-2">
            Terjadi Kesalahan
          </h2>
          <p className="text-gray-600 mb-4">
              {this.state.error?.message ||
                "Terjadi kesalahan yang tidak terduga di halaman pengaturan."}
          </p>
          <div className="space-y-2">
              <button
                onClick={() => window.location.reload()}
                className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Muat Ulang Halaman
              </button>
              <button
                onClick={() => this.setState({ hasError: false, error: null })}
                className="w-full px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
            >
              Coba Lagi
              </button>
          </div>
        </div>
      </div>
    );
  }

    return this.props.children;
  }
}

// Main component with error boundary
export default function PengaturanPage() {
  return (
    <ErrorBoundary>
      <PengaturanPageContent />
    </ErrorBoundary>
  );
}
