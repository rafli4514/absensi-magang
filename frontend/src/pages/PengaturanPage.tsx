import React, { useState, useEffect } from "react";
import {
  Clock,
  MapPin,
  Calendar,
  Shield,
  CheckCircle,
  AlertTriangle,
  Loader2,
  ChevronDown,
  ChevronUp,
  Navigation,
  Target,
  Search,
  Save,
  X,
  Building2,
  Zap,
  Briefcase,
  Radio,
  ScanFace,
  Wifi,
  Globe
} from "lucide-react";
import {
  Button,
  Card,
  Flex,
  Select,
  Switch,
  TextField,
  Spinner,
  AlertDialog,
  Badge,
  Separator,
  Grid,
  Box,
  Text,
  Tooltip
} from "@radix-ui/themes";
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
          allowedIps: [],
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

  // IP Whitelist management
  const [newIpAddress, setNewIpAddress] = useState('');
  const [ipError, setIpError] = useState('');

  // Accordion states
  const [expandedSections, setExpandedSections] = useState({
    attendance: true,
    schedule: true,
    location: true,
    security: true,
  });

  // Toggle section
  const toggleSection = (section: keyof typeof expandedSections) => {
    setExpandedSections(prev => ({
      ...prev,
      [section]: !prev[section]
    }));
  };

  // --- PRESET LOCATIONS (KHUSUS ACEH - WITH ICONS) ---
  const presetLocations = [
    {
      id: "icon-aceh",
      name: "Icon Plus KP Aceh",
      address: "Jl. Teuku Umar No. 426, Banda Aceh",
      latitude: 5.5454249,
      longitude: 95.3175582,
      IconComponent: Building2,
    },
    {
      id: "pln-uid-aceh",
      name: "PLN UID Aceh",
      address: "Jl. Tgk. H. Daud Beureueh No. 172, Banda Aceh",
      latitude: 5.5645,
      longitude: 95.3389,
      IconComponent: Zap,
    },
    {
      id: "pln-up3-bna",
      name: "PLN UP3 Banda Aceh",
      address: "Jl. Tentara Pelajar No. 18, Banda Aceh",
      latitude: 5.5528,
      longitude: 95.3135,
      IconComponent: Briefcase,
    },
    {
      id: "pln-upt-bna",
      name: "PLN UPT Banda Aceh",
      address: "Jl. Tgk. H. Daud Beureueh, Banda Aceh",
      latitude: 5.5610,
      longitude: 95.3350,
      IconComponent: Radio,
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

  // IP Whitelist functions
  const validateIPAddress = (ip: string): boolean => {
    const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    return ipRegex.test(ip);
  };

  const addIPAddress = () => {
    const trimmedIP = newIpAddress.trim();
    if (!trimmedIP) {
      setIpError('Masukkan alamat IP');
      return;
    }

    if (!validateIPAddress(trimmedIP)) {
      setIpError('Format IP tidak valid (contoh: 192.168.1.100)');
      return;
    }

    if (settings.security.allowedIps.includes(trimmedIP)) {
      setIpError('IP sudah ada dalam daftar');
      return;
    }

    setSettings(prev => ({
      ...prev,
      security: {
        ...prev.security,
        allowedIps: [...prev.security.allowedIps, trimmedIP]
      }
    }));

    setNewIpAddress('');
    setIpError('');
    setSuccessMessage(`IP ${trimmedIP} berhasil ditambahkan`);
    setTimeout(() => setSuccessMessage(''), 3000);
  };

  const removeIPAddress = (ip: string) => {
    setSettings(prev => ({
      ...prev,
      security: {
        ...prev.security,
        allowedIps: prev.security.allowedIps.filter(item => item !== ip)
      }
    }));

    setSuccessMessage(`IP ${ip} berhasil dihapus`);
    setTimeout(() => setSuccessMessage(''), 3000);
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
    <div className="space-y-6 pb-20"> {/* Padding bottom extra agar aman dari fixed footer */}
      {/* Page header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            {/* Added span to protect text */}
            <span>Pengaturan Absensi</span>
          </h1>
          <p className="text-gray-600">
            <span>Kelola konfigurasi lokasi, jadwal, dan keamanan</span>
          </p>
        </div>
        {hasUnsavedChanges() && (
          <Badge color="orange" variant="soft" className="animate-pulse">
            <AlertTriangle className="h-3 w-3 mr-1" />
            <span>Ada perubahan belum disimpan</span>
          </Badge>
        )}
      </div>

      {/* Messages */}
      {(successMessage || errorMessage) && (
        <Card className="mb-6">
          <div className={`p-4 rounded-lg ${successMessage ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                {successMessage ? (
                  <CheckCircle className="h-5 w-5 text-green-600 mr-2" />
                ) : (
                  <AlertTriangle className="h-5 w-5 text-red-600 mr-2" />
                )}
                <div>
                  <p className={`font-medium ${successMessage ? 'text-green-800' : 'text-red-800'}`}>
                    {/* Added span */}
                    <span>{successMessage || errorMessage}</span>
                  </p>
                  {validationErrors.length > 0 && (
                    <ul className="text-red-700 text-sm mt-2 list-disc list-inside">
                      {validationErrors.map((error, index) => (
                        <li key={index}><span>{error}</span></li>
                      ))}
                    </ul>
                  )}
                </div>
              </div>
              <Button variant="ghost" size="1" onClick={clearMessages}>
                <X className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </Card>
      )}

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

        {/* LEFT COLUMN */}
        <div className="lg:col-span-2 space-y-6">
          <Card className="h-full shadow-sm">
            <div className="p-5">

              {/* Header */}
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <MapPin className="h-5 w-5 text-green-600" />
                  <h3 className="text-lg font-semibold text-gray-900">
                    Detail Parameter Lokasi
                  </h3>
                </div>

                <Badge
                  variant={settings.location.useRadius ? "solid" : "outline"}
                  color={settings.location.useRadius ? "green" : "gray"}
                  className="px-3 py-1.5"
                >
                  <span className="text-xs tracking-wide">
                    {settings.location.useRadius
                      ? `Radius: ${settings.location.radius} m`
                      : "Tanpa Radius"}
                  </span>
                </Badge>
              </div>

              {/* === MODIFIED: SEPARATOR WITH SPAN === */}
              <span className="block w-full my-6">
                <Separator size="4" />
              </span>
              {/* =================================== */}

              <div className="space-y-8">

                {/* --- PERUBAHAN UTAMA: SEARCH & PRESETS DIGABUNG DI SINI --- */}
                <div className="bg-blue-50/50 p-5 rounded-xl border border-blue-100 space-y-4 relative">

                  {/* Bagian Search */}
                  <div>
                    <label className="block text-sm font-semibold text-gray-800 flex items-center gap-2 mb-2">
                      <Search className="h-4 w-4 text-blue-600" />
                      Cari Lokasi / Set Otomatis
                    </label>
                    <div className="flex gap-2">
                      <TextField.Root
                        placeholder="Contoh: Kantor PLN Banda Aceh..."
                        value={locationQuery}
                        onChange={(e) => setLocationQuery(e.target.value)}
                        className="flex-1"
                        size="3"
                      />
                      <Button
                        size="3"
                        onClick={searchLocation}
                        disabled={isSearchingLocation}
                        className="bg-blue-600 hover:bg-blue-700 text-white cursor-pointer"
                      >
                        {isSearchingLocation
                          ? <Loader2 className="h-4 w-4 animate-spin" />
                          : <Search className="h-4 w-4" />}
                      </Button>
                    </div>

                    {/* Result Dropdown */}
                    {showLocationResults && locationResults.length > 0 && (
                       <div className="absolute top-[80px] left-5 right-5 z-50 bg-white border border-gray-200 rounded-md shadow-lg max-h-60 overflow-y-auto">
                          {locationResults.map((result, idx) => (
                             <div
                                key={idx}
                                className="p-3 hover:bg-gray-50 cursor-pointer text-sm border-b border-gray-100 last:border-0"
                                onClick={() => selectLocation(result)}
                             >
                                <div className="font-medium text-gray-900">{result.address}</div>
                                <div className="text-xs text-gray-500 mt-0.5">
                                  Lat: {result.latitude.toFixed(6)}, Lng: {result.longitude.toFixed(6)}
                                </div>
                             </div>
                          ))}
                       </div>
                    )}
                  </div>

                  {/* Bagian Presets (Digabung ke dalam blok yang sama) */}
                  <div className="pt-2 border-t border-blue-100/50">
                    <p className="text-xs font-semibold text-blue-800 mb-2 uppercase tracking-wider flex items-center gap-1">
                      <Zap className="h-3 w-3" /> Lokasi Cepat (Aceh)
                    </p>
                    <div className="flex flex-wrap gap-2">
                      {presetLocations.map((preset) => (
                        <Button
                          key={preset.id}
                          variant="surface"
                          color="blue"
                          size="1"
                          onClick={() => selectPresetLocation(preset)}
                          className="text-xs cursor-pointer hover:bg-blue-100 transition-colors"
                        >
                          <preset.IconComponent className="h-3 w-3 mr-1" />
                          {preset.name}
                        </Button>
                      ))}
                    </div>
                  </div>
                </div>

                 {/* === SEPARATOR SETELAH SEARCH === */}
                <span className="block w-full my-6">
                  <Separator size="4" />
                </span>


                {/* 1. DETAIL LOKASI (INPUT MANUAL) */}
                {/* Note: Bagian Preset dihapus dari sini karena sudah pindah ke atas */}
                <div>
                  <h4 className="font-medium text-gray-900 mb-4 flex items-center gap-2">
                    <MapPin className="h-4 w-4 text-blue-500" />
                    <span>Konfigurasi Manual</span>
                  </h4>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-xs font-medium text-gray-500 mb-1">
                        Alamat Lengkap Kantor
                      </label>
                      <TextField.Root
                        placeholder="Masukkan alamat lengkap..."
                        value={settings.location.officeAddress}
                        onChange={(e) =>
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

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      {/* latitude */}
                      <div>
                        <label className="block text-xs font-medium text-gray-500 mb-1">
                          Latitude
                        </label>
                        <TextField.Root
                          type="number"
                          step="0.000001"
                          value={settings.location.latitude.toString()}
                          onChange={(e) =>
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

                      {/* longitude */}
                      <div>
                        <label className="block text-xs font-medium text-gray-500 mb-1">
                          Longitude
                        </label>
                        <TextField.Root
                          type="number"
                          step="0.000001"
                          value={settings.location.longitude.toString()}
                          onChange={(e) =>
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

                      {/* radius */}
                      <div>
                        <label className="block text-xs font-medium text-gray-500 mb-1">
                          Radius (Meter)
                        </label>
                        <Select.Root
                          value={settings.location.radius.toString()}
                          onValueChange={(value) =>
                            setSettings({
                              ...settings,
                              location: {
                                ...settings.location,
                                radius: parseInt(value),
                                useRadius: parseInt(value) > 0,
                              },
                            })
                          }
                        >
                          <Select.Trigger className="w-full" />
                          <Select.Content>
                            <Select.Item value="0">Nonaktif</Select.Item>
                            <Select.Item value="25">25 meter</Select.Item>
                            <Select.Item value="50">50 meter</Select.Item>
                            <Select.Item value="100">100 meter</Select.Item>
                            <Select.Item value="200">200 meter</Select.Item>
                            <Select.Item value="500">500 meter</Select.Item>
                          </Select.Content>
                        </Select.Root>
                      </div>
                    </div>
                  </div>
                </div>

                {/* 2. MAP */}
                <div className="relative rounded-xl overflow-hidden border border-gray-200 shadow-inner">
                  <InteractiveMap
                    latitude={settings.location.latitude}
                    longitude={settings.location.longitude}
                    onLocationChange={handleMapLocationChange}
                    height="450px"
                    useRadius={settings.location.useRadius}
                    radius={settings.location.radius}
                  />

                  <div className="absolute bottom-4 right-4 bg-white/90 backdrop-blur-sm px-3 py-2 rounded-lg shadow-lg border">
                    <p className="text-xs text-gray-500 mb-0.5">
                      Koordinat
                    </p>
                    <p className="text-gray-900 font-mono text-xs leading-relaxed">
                      {settings.location.latitude.toFixed(6)},{" "}
                      {settings.location.longitude.toFixed(6)}
                    </p>
                  </div>
                </div>

                {/* 3. ACTION BUTTONS */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                  <Button variant="outline" onClick={getCurrentLocation} disabled={isGettingLocation}>
                    {isGettingLocation
                      ? <Loader2 className="h-4 w-4 animate-spin mr-2" />
                      : <Navigation className="h-4 w-4 mr-2" />}
                    Lokasi Saya
                  </Button>

                  <Button variant="outline" onClick={validateCoordinates}>
                    <CheckCircle className="h-4 w-4 mr-2" />
                    Validasi
                  </Button>

                  <Button variant="outline" onClick={testLocation} disabled={isTestingLocation}>
                    {isTestingLocation
                      ? <Loader2 className="h-4 w-4 animate-spin mr-2" />
                      : <Target className="h-4 w-4 mr-2" />}
                    Test Jarak
                  </Button>
                </div>

                {/* 4. RESULT */}
                {locationTestResult && (
                  <div className={`p-4 rounded-lg border ${
                    locationTestResult.isWithinRange
                      ? "bg-green-50 border-green-200"
                      : "bg-red-50 border-red-200"
                  }`}>
                    <div className="flex items-start gap-2">
                      {locationTestResult.isWithinRange
                        ? <CheckCircle className="h-5 w-5 text-green-600 mt-0.5" />
                        : <AlertTriangle className="h-5 w-5 text-red-600 mt-0.5" />}

                      <div>
                        <p className="font-bold leading-relaxed">
                          {locationTestResult.isWithinRange
                            ? "Dalam Jangkauan"
                            : "Di Luar Jangkauan"}
                        </p>

                        <p className="text-sm text-gray-600 mt-2 leading-relaxed">
                          Jarak{" "}
                          <span className="font-mono font-medium">
                            {locationTestResult.distance} m
                          </span>{" "}
                          dari titik pusat (Radius {settings.location.radius} m)
                        </p>
                      </div>
                    </div>
                  </div>
                )}

                {/* === MODIFIED: SEPARATOR WITH SPAN === */}
                <span className="block w-full my-6">
                  <Separator size="4" />
                </span>
                {/* =================================== */}

                {/* 6. QUICK STATS */}
                <div>
                  <h4 className="font-medium text-gray-900 mb-4 flex items-center gap-2">
                    <CheckCircle className="h-4 w-4 text-purple-500" />
                    <span>Ringkasan Status</span>
                  </h4>

                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">

                    {/* Card 1: Jam Kerja (Blue Theme) */}
                    <div className="group bg-white py-5 px-3 rounded-xl border border-gray-200 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 flex flex-col items-center justify-center text-center gap-3">
                      <div className="p-3 bg-blue-50 text-blue-600 rounded-full group-hover:scale-110 transition-transform duration-200">
                        <Clock className="h-5 w-5" />
                      </div>
                      <div>
                        <p className="text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Jam Operasional</p>
                        <p className="text-sm font-bold text-gray-900">
                          {settings.schedule.workStartTime} - {settings.schedule.workEndTime}
                        </p>
                      </div>
                    </div>

                    {/* Card 2: Radius (Green/Gray Theme) */}
                    <div className="group bg-white py-5 px-3 rounded-xl border border-gray-200 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 flex flex-col items-center justify-center text-center gap-3">
                      <div className={`p-3 rounded-full transition-transform duration-200 group-hover:scale-110 ${
                          settings.location.useRadius
                            ? "bg-green-50 text-green-600"
                            : "bg-gray-100 text-gray-400"
                        }`}>
                        <MapPin className="h-5 w-5" />
                      </div>
                      <div>
                        <p className="text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Radius Absen</p>
                        <p className={`text-sm font-bold ${settings.location.useRadius ? "text-gray-900" : "text-gray-400"}`}>
                          {settings.location.useRadius ? `${settings.location.radius} Meter` : "Nonaktif"}
                        </p>
                      </div>
                    </div>

                    {/* Card 3: Hari Kerja (Purple Theme) */}
                    <div className="group bg-white py-5 px-3 rounded-xl border border-gray-200 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 flex flex-col items-center justify-center text-center gap-3">
                      <div className="p-3 bg-purple-50 text-purple-600 rounded-full group-hover:scale-110 transition-transform duration-200">
                        <Calendar className="h-5 w-5" />
                      </div>
                      <div>
                        <p className="text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Total Hari Kerja</p>
                        <p className="text-sm font-bold text-gray-900">
                          {settings.schedule.workDays.length} Hari <span className="text-xs font-normal text-gray-400">/minggu</span>
                        </p>
                      </div>
                    </div>

                    {/* Card 4: Keamanan (Orange/Red Theme) */}
                    <div className="group bg-white py-5 px-3 rounded-xl border border-gray-200 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 flex flex-col items-center justify-center text-center gap-3">
                      <div className={`p-3 rounded-full transition-transform duration-200 group-hover:scale-110 ${
                           (settings.security.faceVerification || settings.security.ipWhitelist)
                            ? "bg-orange-50 text-orange-600"
                            : "bg-gray-100 text-gray-400"
                        }`}>
                        <Shield className="h-5 w-5" />
                      </div>
                      <div>
                        <p className="text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Level Proteksi</p>
                        <p className="text-sm font-bold text-gray-900">
                          {settings.security.faceVerification && settings.security.ipWhitelist
                            ? "Maksimal"
                            : settings.security.faceVerification || settings.security.ipWhitelist
                              ? "Tingkat Lanjut"
                              : "Standar"}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </Card>
        </div>

        {/* RIGHT COLUMN - All Settings Accordions */}
        <div className="lg:col-span-1 space-y-4">

          {/* Attendance Settings */}
          <Card className="hover:shadow-md transition-shadow">
            <div className="p-4">
              <div
                className="flex items-center justify-between cursor-pointer"
                onClick={() => toggleSection('attendance')}
              >
                <div className="flex items-center gap-2">
                  <Clock className="h-5 w-5 text-blue-600" />
                  <h3 className="font-semibold text-gray-900">Aturan Absensi</h3>
                </div>
                {expandedSections.attendance ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
              </div>

              {expandedSections.attendance && (
                <div key="attendance-content" className="mt-4 space-y-4 animate-fadeIn">

                  {/* === MODIFIED: SEPARATOR WITH SPAN === */}
                  <span className="block w-full my-6">
                    <Separator size="4" />
                  </span>
                  {/* =================================== */}

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <p className="text-sm font-medium">Telat Check-in</p>
                      <p className="text-xs text-gray-500">Izinkan absen meski terlambat</p>
                    </div>
                    <Switch
                      checked={settings.attendance.allowLateCheckIn}
                      onCheckedChange={(checked) =>
                        setSettings({ ...settings, attendance: { ...settings.attendance, allowLateCheckIn: checked } })
                      }
                    />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <p className="text-sm font-medium">Wajib Lokasi</p>
                      <p className="text-xs text-gray-500">Harus menyalakan GPS</p>
                    </div>
                    <Switch
                      checked={settings.attendance.requireLocation}
                      onCheckedChange={(checked) =>
                        setSettings({ ...settings, attendance: { ...settings.attendance, requireLocation: checked } })
                      }
                    />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <p className="text-sm font-medium">Remote Work</p>
                      <p className="text-xs text-gray-500">Absen dari mana saja</p>
                    </div>
                    <Switch
                      checked={settings.attendance.allowRemoteCheckIn}
                      onCheckedChange={(checked) =>
                        setSettings({ ...settings, attendance: { ...settings.attendance, allowRemoteCheckIn: checked } })
                      }
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Toleransi Keterlambatan</label>
                    <Select.Root
                      value={settings.attendance.lateThreshold.toString()}
                      onValueChange={(value) =>
                        setSettings({ ...settings, attendance: { ...settings.attendance, lateThreshold: parseInt(value) } })
                      }
                    >
                      <Select.Trigger className="w-full" />
                      <Select.Content>
                        <Select.Item value="5">5 menit</Select.Item>
                        <Select.Item value="10">10 menit</Select.Item>
                        <Select.Item value="15">15 menit</Select.Item>
                        <Select.Item value="30">30 menit</Select.Item>
                      </Select.Content>
                    </Select.Root>
                  </div>
                </div>
              )}
            </div>
          </Card>

          {/* Schedule Settings */}
          <Card className="hover:shadow-md transition-shadow">
            <div className="p-4">
              <div
                className="flex items-center justify-between cursor-pointer"
                onClick={() => toggleSection('schedule')}
              >
                <div className="flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-purple-600" />
                  <h3 className="font-semibold text-gray-900">Jadwal Kerja</h3>
                </div>
                {expandedSections.schedule ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
              </div>

              {expandedSections.schedule && (
                <div key="schedule-content" className="mt-4 space-y-4 animate-fadeIn">

                  {/* === MODIFIED: SEPARATOR WITH SPAN === */}
                  <span className="block w-full my-6">
                    <Separator size="4" />
                  </span>
                  {/* =================================== */}

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Jam Masuk</label>
                      <TextField.Root type="time" value={settings.schedule.workStartTime} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSettings({...settings, schedule: {...settings.schedule, workStartTime: e.target.value}})} />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Jam Pulang</label>
                      <TextField.Root type="time" value={settings.schedule.workEndTime} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSettings({...settings, schedule: {...settings.schedule, workEndTime: e.target.value}})} />
                    </div>
                     <div>
                      <label className="block text-xs text-gray-500 mb-1">Break Mulai</label>
                      <TextField.Root type="time" value={settings.schedule.breakStartTime} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSettings({...settings, schedule: {...settings.schedule, breakStartTime: e.target.value}})} />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Break Selesai</label>
                      <TextField.Root type="time" value={settings.schedule.breakEndTime} onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSettings({...settings, schedule: {...settings.schedule, breakEndTime: e.target.value}})} />
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-2">Hari Kerja Aktif</label>
                    <div className="flex flex-wrap gap-1.5">
                      {[
                        { key: "monday", label: "Sen" },
                        { key: "tuesday", label: "Sel" },
                        { key: "wednesday", label: "Rab" },
                        { key: "thursday", label: "Kam" },
                        { key: "friday", label: "Jum" },
                        { key: "saturday", label: "Sab" },
                        { key: "sunday", label: "Min" },
                      ].map((day) => (
                        <Button
                          key={day.key}
                          variant={settings.schedule.workDays.includes(day.key) ? "solid" : "outline"}
                          size="1"
                          onClick={() => {
                            const currentDays = settings.schedule.workDays;
                            const newDays = currentDays.includes(day.key)
                              ? currentDays.filter(d => d !== day.key)
                              : [...currentDays, day.key];
                            setSettings({...settings, schedule: {...settings.schedule, workDays: newDays}});
                          }}
                          className={`w-9 h-9 p-0 ${settings.schedule.workDays.includes(day.key) ? 'bg-purple-600' : ''}`}
                        >
                          {day.label}
                        </Button>
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </Card>

          {/* Security Settings */}
          <Card className="hover:shadow-md transition-shadow">
            <div className="p-4">
              <div
                className="flex items-center justify-between cursor-pointer"
                onClick={() => toggleSection('security')}
              >
                <div className="flex items-center gap-2">
                  <Shield className="h-5 w-5 text-red-600" />
                  <h3 className="font-semibold text-gray-900">Keamanan</h3>
                </div>
                {expandedSections.security ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
              </div>

              {expandedSections.security && (
                <div key="security-content" className="mt-4 space-y-4 animate-fadeIn">

                  {/* === MODIFIED: SEPARATOR WITH SPAN === */}
                  <span className="block w-full my-6">
                    <Separator size="4" />
                  </span>
                  {/* =================================== */}

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <p className="text-sm font-medium">
                        {/* Added icon */}
                        <span className="flex items-center gap-2"><ScanFace className="h-3 w-3" /> Face Recognition</span>
                      </p>
                      <p className="text-xs text-gray-500">Verifikasi wajah saat absen</p>
                    </div>
                    <Switch
                      checked={settings.security.faceVerification}
                      onCheckedChange={(checked) =>
                        setSettings({ ...settings, security: { ...settings.security, faceVerification: checked } })
                      }
                    />
                  </div>

                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <p className="text-sm font-medium">
                           {/* Added icon */}
                           <span className="flex items-center gap-2"><Wifi className="h-3 w-3" /> IP Whitelist</span>
                        </p>
                        <p className="text-xs text-gray-500">Batasi jaringan WiFi kantor</p>
                      </div>
                      <Switch
                        checked={settings.security.ipWhitelist}
                        onCheckedChange={(checked) =>
                          setSettings({ ...settings, security: { ...settings.security, ipWhitelist: checked } })
                        }
                      />
                    </div>

                    {settings.security.ipWhitelist && (
                      <div className="bg-gray-50 p-3 rounded-md space-y-2">
                        <div className="flex gap-2">
                          <TextField.Root
                            placeholder="192.168.1.xxx"
                            size="1"
                            value={newIpAddress}
                            onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
                              setNewIpAddress(e.target.value);
                              setIpError('');
                            }}
                            className="flex-1"
                          />
                          <Button size="1" onClick={addIPAddress}>Tambah</Button>
                        </div>
                        {ipError && <p className="text-xs text-red-500">{ipError}</p>}

                        <div className="max-h-[100px] overflow-y-auto space-y-1 mt-2">
                          {settings.security.allowedIps.map((ip, idx) => (
                            <div key={idx} className="flex justify-between items-center bg-white px-2 py-1 rounded border border-gray-200 text-xs">
                              <span className="font-mono flex items-center gap-1"><Globe className="h-3 w-3 text-gray-400"/> {ip}</span>
                              <Button variant="ghost" color="red" size="1" onClick={() => removeIPAddress(ip)} className="h-5 w-5 p-0">
                                <X className="h-3 w-3" />
                              </Button>
                            </div>
                          ))}
                          {settings.security.allowedIps.length === 0 && <p className="text-xs text-gray-400 italic text-center">Belum ada IP terdaftar</p>}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>
          </Card>
        </div>
      </div>

      {/* STATIC SAVE ACTIONS (NOT FLOATING) */}
      <div className="mt-8 pt-4 border-t border-gray-200">
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
           <div className="text-sm text-gray-500">
              {hasUnsavedChanges() ? (
                <span className="text-orange-600 font-medium flex items-center">
                  <div className="w-2 h-2 bg-orange-500 rounded-full mr-2 animate-pulse"></div>
                  <span>Konfigurasi belum disimpan</span>
                </span>
              ) : (
                "Semua perubahan telah tersimpan"
              )}
           </div>

           <div className="flex gap-3 w-full md:w-auto">
              <Button
                size="3"
                variant="soft"
                color="gray"
                onClick={handleCancel}
                disabled={isSaving || !hasUnsavedChanges()}
                className="flex-1 md:flex-none"
              >
                {/* Wrapped in span to protect text */}
                <span>Batal</span>
              </Button>
              <Button
                size="3"
                onClick={saveSettings}
                disabled={isSaving || !hasUnsavedChanges()}
                className="flex-1 md:flex-none bg-blue-600 hover:bg-blue-700 text-white"
              >
                {isSaving ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    {/* Wrapped in span */}
                    <span>Menyimpan...</span>
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4 mr-2" />
                    {/* Wrapped in span */}
                    <span>Simpan Pengaturan</span>
                  </>
                )}
              </Button>
           </div>
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
            Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin membatalkan perubahan?
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